extends RefCounted
## DOC-TFG-0036: LOCK 9 meals, daily public trust and secret giving.

const TaskProgress = preload("res://game/task_progress.gd")
const PrayerClock = preload("res://game/prayer_clock.gd")

class MealCounter:
	var total := 0
	var goal: int

	func _init(goal_value: int) -> void:
		goal = goal_value


var data: Dictionary
var meal_counter: MealCounter
var meals_given: int:
	get: return meal_counter.total
var _owns_meal_counter := false
var secret_selected := false
var message: String
var _last_public_day := -1
var _progress: TaskProgress
var _clock: PrayerClock


func setup(source: Dictionary, progress: TaskProgress, clock: PrayerClock, shared_counter: MealCounter = null) -> void:
	data = source
	_progress = progress
	_clock = clock
	_owns_meal_counter = shared_counter == null
	meal_counter = MealCounter.new(int(data.numbers.goal_meals)) if _owns_meal_counter else shared_counter
	reset()


func reset() -> void:
	if _owns_meal_counter:
		meal_counter.total = 0
	_last_public_day = -1
	open_panel()


func open_panel() -> void:
	secret_selected = false
	message = data.panel.intro


func can_afford(option: Dictionary) -> bool:
	return _progress.coins >= int(option.cost)


func pay(id: String, knows_sirr: bool) -> bool:
	if secret_selected and not knows_sirr:
		return false
	for option: Dictionary in data.options:
		if option.id != id:
			continue
		if not can_afford(option):
			return false
		_progress.coins -= int(option.cost)
		meal_counter.total += int(option.meals)
		if not secret_selected and _last_public_day != _clock.day:
			_progress.apply_trust(int(data.numbers.trust_per_day))
			_last_public_day = _clock.day
		message = data.panel.done_secret if secret_selected else data.panel.done_public
		return true
	return false


func reputation_line() -> Variant:
	return data.say.feeds if _last_public_day >= 0 else null


func counter() -> String:
	return str(data.panel.counter).format({
		"n": _group_digits(meals_given),
		"m": _group_digits(meal_counter.goal),
	})


func _group_digits(number: int) -> String:
	var value := str(number)
	for index in range(value.length() - 3, 0, -3):
		value = value.insert(index, ",")
	return value
