extends RefCounted
## LOCK 18: dates in the fixed lunar cycle, indexed from the arrival day.

var data: Dictionary
var year_days := 0
var rest_days: Array[int] = []
var _month_offsets: Array[int] = []
var _arrival_offset: int
var _night_cost: int


func _init(source: Dictionary, night_cost: int) -> void:
	data = source
	_night_cost = night_cost
	for duration: float in data.numbers.rest_days:
		rest_days.append(int(duration))
	for month: Array in data.months:
		_month_offsets.append(year_days)
		year_days += int(month[1])
	_arrival_offset = _offset(int(data.numbers.start_month), int(data.numbers.start_day))


func date(on_day: int) -> Dictionary:
	var offset := posmod(_arrival_offset + on_day, year_days)
	for index in range(_month_offsets.size() - 1, -1, -1):
		if offset >= _month_offsets[index]:
			return {"d": offset - _month_offsets[index] + 1, "m": data.months[index][0]}
	return {}


func rest_cost(days: int) -> int:
	return days * _night_cost


func coming_dates(on_day: int) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for event: Array in data.panel.events:
		var event_day := _offset(int(event[1]), int(event[2])) - _arrival_offset
		var days_until := posmod(event_day - on_day, year_days)
		rows.append(_event_row(event[0], on_day, days_until))
	var until_zakat := posmod(-on_day, year_days) if on_day > 0 else year_days - on_day
	rows.append(_event_row(data.panel.zakat, on_day, until_zakat))
	return rows


func _offset(month: int, day_of_month: int) -> int:
	return _month_offsets[month] + day_of_month - 1


func _event_row(label: String, on_day: int, days_until: int) -> Dictionary:
	if days_until == 0:
		return {"label": label, "value": data.panel.today_tag}
	var fields := date(on_day + days_until)
	fields.n = days_until
	return {"label": label, "value": str(data.panel.in_days).format(fields)}
