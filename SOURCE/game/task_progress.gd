extends RefCounted
## LOCK 1 task rewards and amends; content and limits come from approved data.

var data: Dictionary = {}
var trust: int = 0
var coins: int = 0
var tasks: Dictionary = {}
var daily_count: int = 0
var lesson_done := false
var tried_weight := -1
var gate_open := false


func setup(source: Dictionary) -> void:
	data = source
	trust = clampi(int(data.numbers.start_trust), int(data.numbers.trust_min), int(data.numbers.trust_max))
	coins = int(data.numbers.start_coins)
	tasks.clear()
	daily_count = 0
	lesson_done = false
	tried_weight = -1
	gate_open = false


func try_weight(index: int) -> bool:
	if lesson_done or index < 0 or index >= data.lesson.options.size():
		return false
	tried_weight = index
	return true


func answer_weight() -> bool:
	if lesson_done or tried_weight != int(data.lesson.false_weight_index):
		return false
	lesson_done = true
	_apply_trust(int(data.lesson.trust))
	return true


func ask_gate() -> String:
	if gate_open:
		return data.gate.open
	if trust < int(data.numbers.gate_trust):
		return str(data.gate.needs_trust).format({"trust": trust})
	if bool(data.numbers.gate_needs_lesson) and not lesson_done:
		return data.gate.needs_lesson
	gate_open = true
	return data.gate.open


func choose_task(id: String, choice: String) -> Dictionary:
	var task := _task(id)
	if task.is_empty() or tasks.has(id) or choice not in ["honest", "quick"]:
		return {}
	var reward: Dictionary = task[choice]
	var change := _apply_trust(int(reward.trust))
	coins += int(reward.coins)
	tasks[id] = {
		"choice": choice,
		"lost_trust": maxi(0, -change),
		"amended": false,
	}
	return {
		"title": task.title,
		"label": data.ui.result.honest_label if choice == "honest" else data.ui.result.quick_label,
		"line": reward.result,
		"coins": int(reward.coins),
		"trust": change,
	}


func amend_reward(id: String) -> int:
	var task := _task(id)
	if task.is_empty() or not tasks.has(id) or tasks[id].choice != "quick":
		return 0
	return int(tasks[id].lost_trust) + int(task.honest.trust)


func amend_task(id: String) -> bool:
	var task := _task(id)
	if task.is_empty() or not tasks.has(id):
		return false
	var state: Dictionary = tasks[id]
	if state.choice != "quick" or state.amended or coins < int(task.amends.cost):
		return false
	coins -= int(task.amends.cost)
	_apply_trust(amend_reward(id))
	state.amended = true
	return true


func do_daily_job() -> bool:
	if daily_count >= int(data.daily_job.per_day):
		return false
	daily_count += 1
	coins += int(data.daily_job.coins)
	_apply_trust(int(data.daily_job.trust))
	return true


func morning() -> void:
	daily_count = 0


func _apply_trust(amount: int) -> int:
	var before := trust
	trust = clampi(trust + amount, int(data.numbers.trust_min), int(data.numbers.trust_max))
	return trust - before


func _task(id: String) -> Dictionary:
	for task: Dictionary in data.tasks:
		if task.id == id:
			return task
	return {}
