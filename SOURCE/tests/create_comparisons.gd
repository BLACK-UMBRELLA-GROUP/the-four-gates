extends SceneTree
## Lossless master-left / native-capture-right review evidence.

func _initialize() -> void:
	var folder := "res://../GAME/APPROVED/FOUNDATIONS/"
	var evidence := "BUILT/V1/"
	var names := ["f01_title", "f02_city_map__gate_closed", "f03_market_map__day_start_quay", "f04_market_map__night", "f05_market_map__at_task_board"]
	if "--tasks" in OS.get_cmdline_user_args():
		names = ["f06_task_board__start", "f07_task__choice", "f08_result__honest", "f09_result__quick", "f10_task_board__amends_and_daily_job", "f11_task_board__daily_job_done"]
	if "--gate" in OS.get_cmdline_user_args():
		names = ["f12_learn__start", "f13_learn__true_weight_level", "f14_learn__false_weight_found", "f15_market_map__gate_needs_lesson", "f16_market_map__gate_needs_trust", "f17_market_map__gate_open", "f18_goal__in_progress", "f19_goal__gate_open", "f20_city_map__gate_open"]
	if "--identity" in OS.get_cmdline_user_args():
		folder = "res://../GAME/APPROVED/IDENTITY/"
		names = ["g01_title__ilmara", "g11_world_map", "g12_city_map", "g13_city_map__district_east", "g14_city_map__gate_of_trust_open", "g15_market_map__day_inn_masjid_clock"]
	if "--arrival" in OS.get_cmdline_user_args():
		folder = "res://../GAME/APPROVED/IDENTITY/"
		evidence = "BUILT/V1/ARRIVAL/"
		names = load("res://tests/capture_arrival.gd").MASTER_STEMS.values()
	if "--clock" in OS.get_cmdline_user_args():
		quit(0 if _compare_clock() else 1)
		return
	if "--idris" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_idris.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/IDENTITY/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--open-purse" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_open_purse.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/CHAPTER_1/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--bread-grab" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_bread_grab.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/CHAPTER_1/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--market-stall" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_market_stall.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/MARKET_STALL/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--clothes" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_clothes.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/CLOTHES/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--talking" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_talking.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/TALKING/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--market-day" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_market_day.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/MARKET_DAY/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--prayer-record" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_prayer_record.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/PRAYER_RECORD/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--feeding" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_feeding.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/FEEDING/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--sealed-purse" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_sealed_purse.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/SEALED_PURSE/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--dice-house" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_dice_house.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/DICE_HOUSE/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--qasims-jars" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_qasims_jars.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/QASIMS_JARS/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--jabirs-goats" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_jabirs_goats.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/JABIRS_GOATS/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--idris-recovery" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_idris_recovery.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/IDRIS_HAS_HEARD/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--dry-fountain" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_dry_fountain.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/DRY_FOUNTAIN/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--rashids-loan" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_rashids_loan.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/RASHIDS_LOAN/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--harm-in-the-road" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_harm_in_the_road.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/HARM_IN_THE_ROAD/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--calendar" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_calendar.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/CALENDAR/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--ramadan" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_ramadan.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/RAMADAN/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	if "--iftar-giving" in OS.get_cmdline_user_args():
		var runner := load("res://tests/capture_iftar_giving.gd")
		quit(0 if _compare_master_set("res://../GAME/APPROVED/IFTAR_GIVING/MASTERS/", runner.evidence_folder(), runner.MASTER_STEMS) else 1)
		return
	quit(0 if _compare_master_set(folder + "MASTERS/", folder + evidence, names) else 1)

func _compare_master_set(masters: String, evidence: String, stems: Array) -> bool:
	for stem: String in stems:
		var captured := evidence.path_join(stem)
		if not _compare(masters.path_join(stem + ".png"), captured + "__build.png", captured + "__master_beside_build.png"):
			return false
	return true

func _compare_clock() -> bool:
	var runner := load("res://tests/capture_clock.gd")
	var folder: String = runner.evidence_folder()
	var masters := "res://../GAME/APPROVED/IDENTITY/MASTERS/"
	for stem: String in runner.MASTER_STEMS:
		var master: String = masters + runner.MASTER_STEMS[stem] + ".png"
		if not _compare(master, folder.path_join(stem + "__build.png"), folder.path_join(stem + "__master_beside_build.png")):
			return false
	return _compare(folder.path_join("hud_day__build.png"), folder.path_join("hud_night__build.png"), folder.path_join("hud_day_beside_night.png"))

func _compare(left_path: String, right_path: String, output_path: String) -> bool:
	var left := Image.load_from_file(left_path)
	var right := Image.load_from_file(right_path)
	var frame := Rect2i(0, 0, 1920, 1080)
	if left == null or right == null or left.get_size() != frame.size or right.get_size() != frame.size:
		push_error("Comparison requires two 1920×1080 images for " + output_path)
		return false
	left.convert(Image.FORMAT_RGBA8)
	right.convert(Image.FORMAT_RGBA8)
	var comparison := Image.create(frame.size.x * 2, frame.size.y, false, Image.FORMAT_RGBA8)
	comparison.blit_rect(left, frame, Vector2i.ZERO)
	comparison.blit_rect(right, frame, Vector2i(frame.size.x, 0))
	if comparison.save_png(output_path) != OK:
		push_error("Could not save comparison to " + output_path)
		return false
	print("COMPARE ", output_path.get_file())
	return true
