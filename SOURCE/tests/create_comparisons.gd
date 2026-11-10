extends SceneTree
## Lossless master-left / native-capture-right review evidence.

func _initialize() -> void:
	var folder := "res://../GAME/APPROVED/FOUNDATIONS/"
	var names := ["f01_title", "f02_city_map__gate_closed", "f03_market_map__day_start_quay", "f04_market_map__night", "f05_market_map__at_task_board"]
	if "--tasks" in OS.get_cmdline_user_args():
		names = ["f06_task_board__start", "f07_task__choice", "f08_result__honest", "f09_result__quick", "f10_task_board__amends_and_daily_job", "f11_task_board__daily_job_done"]
	if "--gate" in OS.get_cmdline_user_args():
		names = ["f12_learn__start", "f13_learn__true_weight_level", "f14_learn__false_weight_found", "f15_market_map__gate_needs_lesson", "f16_market_map__gate_needs_trust", "f17_market_map__gate_open", "f18_goal__in_progress", "f19_goal__gate_open", "f20_city_map__gate_open"]
	if "--identity" in OS.get_cmdline_user_args():
		folder = "res://../GAME/APPROVED/IDENTITY/"
		names = ["g01_title__ilmara", "g11_world_map", "g12_city_map", "g13_city_map__district_east", "g14_city_map__gate_of_trust_open", "g15_market_map__day_inn_masjid_clock"]
	for stem: String in names:
		var master := Image.load_from_file(folder + "MASTERS/" + stem + ".png")
		var build := Image.load_from_file(folder + "BUILT/V1/" + stem + "__build.png")
		assert(master.get_size() == Vector2i(1920, 1080) and master.get_size() == build.get_size())
		master.convert(Image.FORMAT_RGBA8)
		build.convert(Image.FORMAT_RGBA8)
		var comparison := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		comparison.blit_rect(master, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		comparison.blit_rect(build, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		assert(comparison.save_png(folder + "BUILT/V1/" + stem + "__master_beside_build.png") == OK)
		print("COMPARE ", stem)
	quit(0)
