extends SceneTree
## Exercise a new session on the same progress object without loading a scene or data file.

const Progress = preload("res://game/task_progress.gd")

var checks := 0
var failures := 0


func _initialize() -> void:
	_test_restart()
	print("Progress restart checks: %d/%d passed" % [checks - failures, checks])
	quit(0 if failures == 0 else 1)


func _test_restart() -> void:
	var progress = Progress.new()
	progress.setup(_fixture())
	var first: Dictionary = progress.choose_task("parcel", "quick")
	_expect(first.get("trust") == -10, "first session records only trust actually lost")
	_expect(progress.amend_task("parcel"), "first session can make amends")
	_expect(progress.do_daily_job(), "first session can use its daily allowance")
	_expect(not progress.do_daily_job(), "first session exhausts its daily allowance")
	_expect(progress.try_weight(1) and progress.answer_weight(), "first session completes the lesson")
	_expect(progress.ask_gate() == "open", "first session opens the gate")

	var replacement := _fixture()
	replacement.numbers.start_trust = 999
	replacement.numbers.start_coins = 3
	replacement.numbers.trust_max = 60
	replacement.numbers.gate_trust = 60
	replacement.tasks[0].quick.coins = 7
	replacement.daily_job.coins = 11
	progress.setup(replacement)

	_expect(progress.trust == 60 and progress.coins == 3, "restart replaces the wallet and applies the new upper limit")
	_expect(progress.ask_gate() == "needs lesson", "restart closes the gate and clears lesson completion")
	_expect(not progress.answer_weight(), "restart clears the previous weight selection")
	_expect(not progress.amend_task("parcel"), "restart clears the previous task record")
	var replay: Dictionary = progress.choose_task("parcel", "quick")
	_expect(replay.get("coins") == 7 and replay.get("trust") == -40, "restart allows the same task with replacement rewards")
	_expect(progress.coins == 10 and progress.trust == 20, "replayed task uses the replacement wallet")
	_expect(progress.amend_reward("parcel") == 70, "replayed amends use the new session's actual trust loss")
	_expect(progress.amend_task("parcel"), "replayed task allows amends again")
	_expect(progress.coins == 8 and progress.trust == 60, "replayed amends charge once and respect the new limit")
	_expect(not progress.amend_task("parcel"), "replayed amends remain single use")
	_expect(progress.do_daily_job(), "restart restores the daily allowance")
	_expect(progress.coins == 19 and progress.trust == 60, "replayed daily job uses replacement rewards and limits")
	_expect(not progress.do_daily_job(), "replayed daily allowance remains limited")
	_expect(progress.try_weight(1) and progress.answer_weight(), "restart allows the lesson to be completed again")
	_expect(not progress.answer_weight(), "replayed lesson reward remains single use")
	_expect(progress.ask_gate() == "open", "replayed prerequisites reopen the gate")

	replacement.numbers.start_trust = -999
	progress.setup(replacement)
	_expect(progress.trust == 10 and progress.coins == 3, "another restart applies the lower trust limit and starting coins")
	_expect(progress.ask_gate() == "needs trust 10", "another restart closes the previously reopened gate")


func _fixture() -> Dictionary:
	return {
		"numbers": {
			"start_trust": 20, "start_coins": 0, "trust_min": 10, "trust_max": 80,
			"gate_trust": 80, "gate_needs_lesson": true,
		},
		"tasks": [{
			"id": "parcel", "title": "fixture task",
			"honest": {"trust": 30, "coins": 4, "result": "fixture honest result"},
			"quick": {"trust": -40, "coins": 5, "result": "fixture quick result"},
			"amends": {"cost": 2},
		}],
		"daily_job": {"per_day": 1, "trust": 5, "coins": 2},
		"lesson": {"options": ["checked", "light"], "false_weight_index": 1, "trust": 40},
		"gate": {"open": "open", "needs_trust": "needs trust {trust}", "needs_lesson": "needs lesson"},
		"ui": {"result": {"honest_label": "fixture honest", "quick_label": "fixture quick"}},
	}


func _expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + label)
