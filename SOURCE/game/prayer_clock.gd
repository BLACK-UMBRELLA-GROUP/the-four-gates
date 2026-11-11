extends RefCounted
## LOCK 2: each scheduled prayer belongs to the day it begins, including Isha.

signal adhan_started(toast: String)

const MINUTES_PER_HOUR := 60
const MINUTES_PER_DAY := 24 * MINUTES_PER_HOUR

var day: int:
	get:
		return floori(float(_time) / MINUTES_PER_DAY) + 1
var minute_of_day: int:
	get:
		return posmod(_time, MINUTES_PER_DAY)
var night: bool:
	get:
		return minute_of_day < _night_until or minute_of_day >= _night_from

var _data: Dictionary
var _prayers: Array[Dictionary] = []
var _start: int
var _night_until: int
var _night_from: int
var _congregation_grace: int
var _duration_formats: PackedStringArray
var _minutes_per_second: float
var _time: int
var _fraction := 0.0
var _first_counted: int
var _oldest_unfinished: int
var _completed: Dictionary = {}
var _alone_at_masjid: Dictionary = {}


func _init(source: Dictionary) -> void:
	_data = source
	var start_parts: PackedStringArray = str(source.start).split(" on day ")
	_start = _at(int(start_parts[1]), _parse_time(start_parts[0]))
	var night_parts: PackedStringArray = str(source.night).split(" ")
	_night_until = _parse_time(night_parts[1])
	_night_from = _parse_time(night_parts[4])
	var grace: String = str(source.congregation_rule).get_slice(" until ", 1)
	_congregation_grace = grace.get_slice(" ", 0).to_int()
	_duration_formats = str(source.duration_format).split('"')
	_minutes_per_second = float(MINUTES_PER_DAY) / (float(source.day_length_real_minutes) * MINUTES_PER_HOUR)
	for prayer: Dictionary in source.prayers:
		var begins := _parse_time(prayer.begins)
		var ends := _parse_time(prayer.ends)
		if ends < begins:
			ends += MINUTES_PER_DAY
		_prayers.append({
			"name": prayer.name,
			"begins": begins,
			"ends": ends,
			"iqamah": int(prayer.iqamah_minutes_after_adhan),
		})
	reset()


func reset() -> void:
	_time = _start
	_fraction = 0.0
	_completed.clear()
	_alone_at_masjid.clear()
	_first_counted = _latest_started()
	if _ends(_first_counted) < _start:
		_first_counted += 1
	_oldest_unfinished = _first_counted


func advance_seconds(seconds: float) -> void:
	_fraction += maxf(seconds, 0.0) * _minutes_per_second
	# Keep sub-minute precision across frames, including a floating-point sum
	# that lands just below a whole minute.
	var whole_minutes := floori(_fraction + 0.000000001)
	if whole_minutes > 0:
		_fraction = maxf(_fraction - whole_minutes, 0.0)
		_advance(_time + whole_minutes, true)


func advance_to(target_day: int, target_minute: int, announce: bool = true) -> void:
	var target := _at(target_day, target_minute)
	if target >= _time:
		_fraction = 0.0
		_advance(target, announce)


func skip_to(target_day: int, target_minute: int) -> void:
	var target := _at(target_day, target_minute)
	if target <= _time:
		return
	# Keep earlier misses and completed prayers. Only windows ending during
	# this jump are excluded from the record and from make-up.
	var prayer := maxi(_latest_started(), _first_counted)
	while _ends(prayer) <= target:
		if _ends(prayer) > _time and not _completed.has(prayer):
			_completed[prayer] = "not_counted"
		prayer += 1
	_advance_oldest_unfinished()
	advance_to(target_day, target_minute, false)


func has_prayed_in_congregation() -> bool:
	return _completed.values().has("jamaah")


func wait_until_next_prayer() -> void:
	_fraction = 0.0
	_advance(_begins(_latest_started() + 1), true)


func prayer_label(at_masjid: bool) -> String:
	var prayer := _latest_started()
	if not _is_active(prayer) or _completed.has(prayer):
		return ""
	if _can_join(prayer, at_masjid):
		return _data.pray_friday if _is_friday_slot(prayer) else _data.pray_congregation
	if _is_friday_slot(prayer):
		return _data.pray_here_friday
	return str(_data.pray_here).format({"prayer": _prayer(prayer).name})


func pray(at_masjid: bool) -> String:
	var prayer := _latest_started()
	if not _is_active(prayer) or _completed.has(prayer):
		return ""
	var congregation := _can_join(prayer, at_masjid)
	var status := "jamaah" if congregation else "alone"
	var toast: String = _data.toast_congregation if congregation else _data.toast_alone
	if _is_friday_slot(prayer) and not congregation:
		status = "dhuhr_fri"
		toast = _data.toast_alone_friday
	if not congregation:
		_alone_at_masjid[prayer] = at_masjid
	var name: String = _scheduled_name(prayer) if congregation else _prayer(prayer).name
	_complete(prayer, status)
	return toast.format({"prayer": name})


func make_up_label() -> String:
	var prayer := _makeup_target()
	if prayer < _first_counted:
		return ""
	return str(_data.make_up).format({"prayer": _prayer(prayer).name})


func make_up() -> String:
	var prayer := _makeup_target()
	if prayer < _first_counted:
		return ""
	_complete(prayer, "madeup")
	return str(_data.toast_madeup).format({"prayer": _prayer(prayer).name})


func masjid_line() -> String:
	var prayer := _latest_started()
	if not _is_active(prayer) or not _completed.has(prayer):
		return ""
	return str(_data.masjid_after_prayed).format({"prayer": _completed_name(prayer)})


func hud(at_masjid: bool = false) -> Dictionary:
	var time_label: String = str(_data.hud_line1).format({
		"weekday": _weekday(day),
		"hh:mm": _format_time(minute_of_day),
	})
	var prayer := _latest_started()
	var prayer_label_text: String
	if not _is_active(prayer):
		prayer += 1
		var name: String = _scheduled_name(prayer) if at_masjid else _prayer(prayer).name
		prayer_label_text = _hud_duration(_data.hud_next, name, _begins(prayer) - _time)
	elif _completed.has(prayer):
		prayer_label_text = str(_data.hud_done).format({
			"prayer": _completed_name(prayer), "status": _data.status[_completed[prayer]],
		})
	else:
		var name: String = _scheduled_name(prayer) if _can_join(prayer, at_masjid) else _prayer(prayer).name
		prayer_label_text = _hud_duration(_data.hud_now, name, _ends(prayer) - _time)
	return {"time": time_label, "prayer": prayer_label_text}


func record() -> Dictionary:
	var rows: Array[Dictionary] = []
	var first_prayer := (day - 1) * _prayers.size()
	for prayer in range(first_prayer, first_prayer + _prayers.size()):
		var starts: String = _format_time(_begins(prayer))
		var status := _record_status(prayer)
		var name := _scheduled_name(prayer)
		if status == "madeup":
			name = _prayer(prayer).name
		rows.append({
			"name": name,
			"text": str(_data.record.row).format({"hh:mm": starts, "status": _record_detail(prayer, status, starts)}),
			"status": status,
		})
	return {
		"kicker": str(_data.record.kicker).format({"weekday": _weekday(day), "n": day}),
		"rows": rows,
	}


func totals() -> Dictionary:
	var counts := {
		"on_time": 0, "jamaah": 0, "alone_masjid": 0, "alone_elsewhere": 0,
		"friday": 0, "dhuhr_fri": 0, "madeup": 0, "missed": 0,
	}
	for prayer in range(_first_counted, _latest_started() + 1):
		var status := _record_status(prayer)
		match status:
			"jamaah":
				counts.jamaah += 1
				if _is_friday_slot(prayer):
					counts.friday += 1
			"alone", "dhuhr_fri":
				var row := "alone_masjid" if _alone_at_masjid.get(prayer, false) else "alone_elsewhere"
				counts[row] += 1
				if status == "dhuhr_fri":
					counts.dhuhr_fri += 1
			"madeup", "missed":
				counts[status] += 1
	counts.on_time = counts.jamaah + counts.alone_masjid + counts.alone_elsewhere
	return counts


func _advance(target: int, announce: bool) -> void:
	var previous := _time
	_time = target
	if announce:
		var prayer := _latest_started()
		# A jump announces the most recent start reached in that jump.
		if _begins(prayer) > previous:
			adhan_started.emit(str(_data.adhan_toast).format({"prayer": _scheduled_name(prayer)}))


func _complete(prayer: int, status: String) -> void:
	_completed[prayer] = status
	_advance_oldest_unfinished()
	_advance(_time + int(_data.prayer_takes_minutes), true)


func _advance_oldest_unfinished() -> void:
	while _completed.has(_oldest_unfinished):
		_oldest_unfinished += 1


func _makeup_target() -> int:
	var first_today := (day - 1) * _prayers.size()
	# Prefer today's record, then allow every earlier missed prayer to be made up.
	for prayer in range(maxi(first_today, _oldest_unfinished), first_today + _prayers.size()):
		if _is_missed(prayer):
			return prayer
	if _is_missed(_oldest_unfinished):
		return _oldest_unfinished
	return _first_counted - 1


func _record_status(prayer: int) -> String:
	if prayer < _first_counted:
		return "not_counted"
	if _completed.has(prayer):
		return _completed[prayer]
	if _time < _begins(prayer):
		return "later"
	return "missed" if _is_missed(prayer) else "now"


func _record_detail(prayer: int, status: String, starts: String) -> String:
	match status:
		"not_counted":
			return _data.record.not_counted
		"later":
			return str(_data.record.later).format({"hh:mm": starts})
		"now":
			return str(_data.record.now).format({"duration": _format_duration(_ends(prayer) - _time)})
		_:
			return _data.status[status]


func _is_missed(prayer: int) -> bool:
	return prayer >= _first_counted and _time >= _ends(prayer) and not _completed.has(prayer)


func _is_active(prayer: int) -> bool:
	return prayer >= _first_counted and _time < _ends(prayer)


func _can_join(prayer: int, at_masjid: bool) -> bool:
	var iqamah: int = int(_data.friday.iqamah_minutes_after_adhan) if _is_friday_slot(prayer) else _prayer(prayer).iqamah
	return at_masjid and _time <= _begins(prayer) + iqamah + _congregation_grace


func _latest_started() -> int:
	var first_today := (day - 1) * _prayers.size()
	for index in range(_prayers.size() - 1, -1, -1):
		if minute_of_day >= int(_prayers[index].begins):
			return first_today + index
	return first_today - 1


func _prayer(prayer: int) -> Dictionary:
	return _prayers[posmod(prayer, _prayers.size())]


func _prayer_day(prayer: int) -> int:
	return floori(float(prayer) / _prayers.size()) + 1


func _begins(prayer: int) -> int:
	return _at(_prayer_day(prayer), _prayer(prayer).begins)


func _ends(prayer: int) -> int:
	return _at(_prayer_day(prayer), _prayer(prayer).ends)


func _is_friday_slot(prayer: int) -> bool:
	return _weekday(_prayer_day(prayer)) == "Friday" and _prayer(prayer).name == _data.friday.replaces


func is_friday() -> bool:
	return _weekday(day) == "Friday"


func is_friday_prayer_window(minutes_after_iqamah: int) -> bool:
	if not is_friday():
		return false
	for prayer: Dictionary in _prayers:
		if prayer.name == _data.friday.replaces:
			var adhan := int(prayer.begins)
			var reopens := adhan + int(_data.friday.iqamah_minutes_after_adhan) + minutes_after_iqamah
			return minute_of_day >= adhan and minute_of_day < reopens
	return false


func _scheduled_name(prayer: int) -> String:
	return _data.friday.name if _is_friday_slot(prayer) else _prayer(prayer).name


func _completed_name(prayer: int) -> String:
	return _prayer(prayer).name if _completed[prayer] == "dhuhr_fri" else _scheduled_name(prayer)


func _weekday(value: int) -> String:
	var weekdays: Array = _data.weekdays_from_day1
	return weekdays[posmod(value - 1, weekdays.size())]


func _hud_duration(template: String, name: String, minutes: int) -> String:
	return template.replace(_duration_formats[1], _format_duration(minutes)).format({"prayer": name})


func _format_duration(minutes: int) -> String:
	var template := _duration_formats[1] if minutes >= MINUTES_PER_HOUR else _duration_formats[3]
	return template.format({
		"h": floori(float(minutes) / MINUTES_PER_HOUR),
		"m": minutes % MINUTES_PER_HOUR,
	})


func _at(on_day: int, minutes: int) -> int:
	return (on_day - 1) * MINUTES_PER_DAY + minutes


func _parse_time(value: String) -> int:
	return value.get_slice(":", 0).to_int() * MINUTES_PER_HOUR + value.get_slice(":", 1).to_int()


func _format_time(value: int) -> String:
	var minutes := posmod(value, MINUTES_PER_DAY)
	return "%02d:%02d" % [floori(float(minutes) / MINUTES_PER_HOUR), minutes % MINUTES_PER_HOUR]
