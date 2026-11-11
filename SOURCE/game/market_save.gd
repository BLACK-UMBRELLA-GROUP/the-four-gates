extends RefCounted
## DOC-TFG-0096: the single River Market save slot, independent of settings.

const VERSION := 1
const CHECKSUM_BYTES := 32

# Persist gameplay values only. The live components retain their dependencies,
# signals and locked data when a new game or a reload changes their state.
const MARKET_FIELDS := [
	"destination", "route", "arrival_beat", "arrival_reply", "arrival_fair",
	"idris_beat", "known_words", "idris_met", "paid_nights", "_daily_job_day",
	"_arrival_sunset", "_idris_reply", "_idris_new_word",
]
const COMPONENT_FIELDS := {
	"player": ["position", "velocity", "yaw", "pitch", "stepped_last_frame"],
	"progress": [
		"coins", "trust", "tasks", "daily_count", "boat_job_done", "lesson_done",
		"tried_weight", "gate_open",
	],
	"clock": [
		"_time", "_fraction", "_first_counted", "_oldest_unfinished",
		"_completed", "_rested", "_alone_at_masjid",
	],
	"open_purse": ["salma_asked", "page_read", "done", "_gifts"],
	"bread_grab": ["answer_id", "_seen_day"],
	"market_stall": [
		"change_state", "stall_notice", "worn_clothes", "_kept_day", "fed_faris", "_bag",
	],
	"talking": ["person", "greeted", "reply"],
	"feeding": ["secret_selected", "message", "_last_public_day"],
	"iftar_giving": ["secret_selected", "message", "_last_public_day"],
	"sealed_purse": ["state"],
	"dice_house": ["invited", "nights", "last_result", "_last_visit_night"],
	"qasims_jars": ["runs", "_last_run_night"],
	"jabirs_goats": ["deals", "last_deal_day", "told"],
	"idris_recovery": ["cool", "cool_point", "_trust_tally", "_has_cooled"],
	"dry_fountain": ["paid", "named", "finished_day"],
	"rashids_loan": ["outcome", "_state", "_since_day"],
	"partnership": ["_partner_day", "_weeks_collected", "_refused"],
	"gate_of_trust": ["in_jisra", "jisra_trust", "toll_choice"],
	"jisra_masjid": ["prayed_in", "show_first"],
	"harm_in_the_road": ["count", "done_day", "moved_harm"],
	"ramadan": ["_taken", "_rested"],
	"eid_al_fitr": ["_stood_nights", "_fitr_years", "_eid_days"],
	"eid_al_adha": ["_owns_sheep", "_arafah_day", "_eid_prayer_day", "_sacrifice_day"],
	"zakat": ["_assessments"],
	"pilgrims": ["secret_selected", "umrah_paid", "hajj_paid", "_trips"],
	"qurans_school": [
		"qurans_given", "children_in_school", "secret_selected", "message",
		"_last_public_day", "_public_qurans", "_public_school",
	],
	"names_of_allah": ["learned", "current_name"],
}


static func snapshot(game: Node3D) -> Dictionary:
	var state := {
		"version": VERSION,
		"day": game.day,
		"minute_of_day": game.minute_of_day,
		"market": _capture_fields(game, MARKET_FIELDS),
		"meals_given": game.feeding.meal_counter.total,
		"scene_runner": game.scene_runner.state(),
		"runner_town": game.runner_saved_town(),
	}
	for component: String in COMPONENT_FIELDS:
		state[component] = _capture_fields(game.get(component), COMPONENT_FIELDS[component])
	return state.duplicate(true)


static func save_slot(game: Node3D, path: String) -> Error:
	var directory := ProjectSettings.globalize_path(path).get_base_dir()
	var result := DirAccess.make_dir_recursive_absolute(directory)
	if result != OK:
		return result
	var payload := var_to_bytes(snapshot(game))
	# Keep the previous slot until its replacement has been written and closed.
	var pending := "%s.pending-%d" % [path, OS.get_process_id()]
	var file := FileAccess.open(pending, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var stored := file.store_buffer(_checksum(payload)) and file.store_buffer(payload)
	file.flush()
	result = file.get_error() if stored else ERR_FILE_CANT_WRITE
	file.close()
	if result != OK:
		return result
	return DirAccess.rename_absolute(pending, path)


static func read_slot(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() <= CHECKSUM_BYTES:
		return {}
	var expected := file.get_buffer(CHECKSUM_BYTES)
	var payload := file.get_buffer(file.get_length() - CHECKSUM_BYTES)
	if payload.is_empty() or _checksum(payload) != expected:
		return {}
	# Variant encoding preserves integer prayer/day keys and typed arrays.
	# bytes_to_var cannot instantiate serialized objects.
	var state: Variant = bytes_to_var(payload)
	if not state is Dictionary or state.get("version") != VERSION:
		return {}
	if not state.get("day") is int or not state.get("minute_of_day") is int:
		return {}
	if not state.get("meals_given") is int or not _has_fields(state.get("market"), MARKET_FIELDS):
		return {}
	for component: String in COMPONENT_FIELDS:
		# Earlier slots may predate these components.
		if component in ["partnership", "gate_of_trust", "jisra_masjid"] and not state.has(component):
			continue
		if not _has_fields(state.get(component), COMPONENT_FIELDS[component]):
			return {}
	if not state.get("scene_runner", {}) is Dictionary or not state.get("runner_town", "") is String:
		return {}
	return state


static func restore(game: Node3D, state: Dictionary) -> void:
	var values := state.duplicate(true)
	_restore_fields(game, values.market, MARKET_FIELDS)
	for component: String in COMPONENT_FIELDS:
		if values.has(component):
			_restore_fields(game.get(component), values[component], COMPONENT_FIELDS[component])
		elif component in ["partnership", "gate_of_trust"]:
			game.get(component).reset()
	if not values.has("jisra_masjid"):
		# Earlier slots only identify the location of regular and seasonal prayers.
		game.jisra_masjid.restore_legacy(game.clock.has_prayed_at_masjid()
			or game.ramadan.has_prayed_at_masjid() or game.eid_al_fitr.has_prayed_at_masjid()
			or game.eid_al_adha.has_prayed_at_masjid())
	game.feeding.meal_counter.total = values.meals_given
	game.scene_runner.restore(values.get("scene_runner", {}))
	game.restore_runner_town(values.get("runner_town", ""))
	game.zakat.close_panel()
	game.ui.known_words = game.known_words
	game.ui.idris_met = game.idris_met
	game.player.test_move_axis = Vector2.ZERO
	game.player.update_camera()
	game.world.stop_faris_run()
	game.world.set_inn_people_waiting(not game.open_purse.done)
	if game.progress.gate_open:
		game.world.open_gate(false)
	else:
		game.world.reset_gate()


static func _capture_fields(source: Object, fields: Array) -> Dictionary:
	var values := {}
	for field: String in fields:
		values[field] = source.get(field)
	return values


static func _has_fields(values: Variant, fields: Array) -> bool:
	return values is Dictionary and values.has_all(fields)


static func _restore_fields(target: Object, values: Dictionary, fields: Array) -> void:
	for field: String in fields:
		target.set(field, values[field])


static func _checksum(payload: PackedByteArray) -> PackedByteArray:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(payload)
	return hashing.finish()
