extends RefCounted
## LOCK 30 V1 (DOC-TFG-0099). Solar events are calculated in UTC.
## The selected city's system IANA zone supplies local dates and display times.

const SECONDS_PER_DAY := 86400
const MINUTES_PER_DAY := 1440.0


static func local_date(unix_seconds: int, zone: String) -> Dictionary:
	var parts := _mac_date(unix_seconds, zone, "+%Y-%m-%d").split("-")
	if parts.size() != 3:
		return {}
	return {"year": int(parts[0]), "month": int(parts[1]), "day": int(parts[2])}


static func local_time(unix_seconds: int, zone: String) -> String:
	# Round the label to the nearest minute. Keep seconds for reminder timing.
	return _mac_date(unix_seconds + 30, zone, "+%H:%M")


static func times(date: Dictionary, city: Array, numbers: Dictionary, hanafi: bool) -> Array[int]:
	if date.is_empty():
		return []
	var midnight := Time.get_unix_time_from_datetime_dict(date)
	var latitude := deg_to_rad(float(city[1]))
	var longitude := float(city[2])
	var horizon := -float(numbers["sun_angle"])
	var fajr_angle := float(numbers["fajr_angle"])
	var isha_angle := float(numbers["isha_angle"])

	var sunrise := _event_minutes_utc(midnight, latitude, longitude, horizon, -1)
	var sunset := _event_minutes_utc(midnight, latitude, longitude, horizon, 1)
	var previous_sunset := _event_minutes_utc(
		midnight - SECONDS_PER_DAY, latitude, longitude, horizon, 1
	) - MINUTES_PER_DAY
	var next_sunrise := _event_minutes_utc(
		midnight + SECONDS_PER_DAY, latitude, longitude, horizon, -1
	) + MINUTES_PER_DAY

	var fajr := _event_minutes_utc(midnight, latitude, longitude, -fajr_angle, -1)
	var isha := _event_minutes_utc(midnight, latitude, longitude, -isha_angle, 1)
	var fajr_limit := sunrise - (sunrise - previous_sunset) * fajr_angle / 60.0
	var isha_limit := sunset + (next_sunrise - sunset) * isha_angle / 60.0
	if is_nan(fajr) or fajr < fajr_limit:
		fajr = fajr_limit
	if is_nan(isha) or isha > isha_limit:
		isha = isha_limit

	var dhuhr := _event_minutes_utc(midnight, latitude, longitude, 0.0, 0)
	var shadow_factor := 2.0 if hanafi else 1.0
	var asr := _event_minutes_utc(midnight, latitude, longitude, 0.0, 1, shadow_factor)
	var prayer_times: Array[int] = []
	for minute: float in [fajr, dhuhr, asr, sunset, isha]:
		if is_nan(minute):
			return []
		prayer_times.append(midnight + roundi(minute * 60.0))
	return prayer_times


static func _event_minutes_utc(
	midnight: int, latitude: float, longitude: float, altitude: float,
	direction: int, shadow_factor: float = 0.0
) -> float:
	var minute := 720.0 - 4.0 * longitude
	# Re-evaluate the equation of time and declination at the event itself.
	for _iteration in range(5):
		var julian_day := float(midnight) / SECONDS_PER_DAY + minute / MINUTES_PER_DAY + 2440587.5
		var century := (julian_day - 2451545.0) / 36525.0
		var mean_longitude := deg_to_rad(fposmod(
			280.46646 + century * (36000.76983 + 0.0003032 * century), 360.0
		))
		var anomaly := deg_to_rad(357.52911 + century * (35999.05029 - 0.0001537 * century))
		var eccentricity := 0.016708634 - century * (0.000042037 + 0.0000001267 * century)
		var correction := (1.914602 - century * (0.004817 + 0.000014 * century)) * sin(anomaly)
		correction += (0.019993 - 0.000101 * century) * sin(2.0 * anomaly)
		correction += 0.000289 * sin(3.0 * anomaly)
		var node_longitude := deg_to_rad(125.04 - 1934.136 * century)
		var apparent_longitude := mean_longitude + deg_to_rad(
			correction - 0.00569 - 0.00478 * sin(node_longitude)
		)
		var obliquity_arcseconds := 21.448 - century * (
			46.8150 + century * (0.00059 - 0.001813 * century)
		)
		var mean_obliquity := 23.0 + (26.0 + obliquity_arcseconds / 60.0) / 60.0
		var obliquity := deg_to_rad(mean_obliquity + 0.00256 * cos(node_longitude))
		var declination := asin(sin(obliquity) * sin(apparent_longitude))
		var obliquity_term := pow(tan(obliquity / 2.0), 2.0)
		var equation := obliquity_term * sin(2.0 * mean_longitude) - 2.0 * eccentricity * sin(anomaly)
		equation += 4.0 * eccentricity * obliquity_term * sin(anomaly) * cos(2.0 * mean_longitude)
		equation -= obliquity_term * obliquity_term * sin(4.0 * mean_longitude) / 2.0
		equation -= 1.25 * eccentricity * eccentricity * sin(2.0 * anomaly)
		var noon := 720.0 - 4.0 * longitude - 4.0 * rad_to_deg(equation)
		if direction == 0:
			minute = noon
			continue
		var event_altitude := deg_to_rad(altitude)
		if shadow_factor > 0.0:
			event_altitude = atan(1.0 / (shadow_factor + tan(absf(latitude - declination))))
		var hour_angle_cosine := (sin(event_altitude) - sin(latitude) * sin(declination)) / (
			cos(latitude) * cos(declination)
		)
		if absf(hour_angle_cosine) > 1.0:
			return NAN
		minute = noon + direction * 4.0 * rad_to_deg(acos(hour_angle_cosine))
	return minute


static func _mac_date(unix_seconds: int, zone: String, format: String) -> String:
	# BSD date uses macOS's local zone database, including future DST rules.
	# TZ is confined to the child process and comes from the locked city list.
	if not FileAccess.file_exists("/usr/share/zoneinfo/" + zone):
		push_error("Prayer reminder time zone is unavailable: " + zone)
		return ""
	var output: Array = []
	var status := OS.execute("/usr/bin/env", [
		"LC_ALL=C", "TZ=" + zone, "/bin/date", "-r", str(unix_seconds), format
	], output)
	if status != 0 or output.is_empty():
		push_error("Prayer reminder could not convert time for " + zone)
		return ""
	return str(output[0]).strip_edges()
