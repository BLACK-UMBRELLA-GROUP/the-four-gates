extends RefCounted
## LOCK 32 V1: independent Jisra trust and the one-time toll choice.

const TOLL_CHOICES := ["speak", "pay", "quiet"]

var data: Dictionary
var in_jisra := false
var jisra_trust := 0
var toll_choice := ""
var _progress: RefCounted


func setup(source: Dictionary, progress: RefCounted) -> void:
	data = source
	_progress = progress
	reset()


func reset() -> void:
	in_jisra = false
	jisra_trust = int(data.numbers.jisra_start)
	toll_choice = ""


func can_use_gate() -> bool:
	return (_progress.trust == int(_progress.data.numbers.gate_trust)
		and _progress.lesson_done)


func can_pay_toll() -> bool:
	return _progress.coins >= int(data.numbers.pay_coins)


func choose_toll(choice: String) -> bool:
	if not in_jisra or not toll_choice.is_empty() or choice not in TOLL_CHOICES:
		return false
	match choice:
		"speak":
			jisra_trust += int(data.numbers.speak_trust)
		"pay":
			if not can_pay_toll():
				return false
			_progress.coins -= int(data.numbers.pay_coins)
			jisra_trust += int(data.numbers.pay_trust)
	jisra_trust = mini(jisra_trust, int(_progress.data.numbers.trust_max))
	toll_choice = choice
	return true
