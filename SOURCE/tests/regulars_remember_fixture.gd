extends RefCounted
## DOC-TFG-0095: earlier gameplay actions used by the LOCK 28 checks and captures.

const MORNING := 10 * 60


static func apply_event(app: Node3D, key: String) -> bool:
	match key:
		"jars_seen":
			return carry_jars(app, int(app.qasims_jars.data.numbers.seen_from_runs))
		"dice_seen":
			return visit_dice_house(app, int(app.dice_house.data.numbers.seen_from_visits))
		"fountain_named":
			return finish_fountain(app, "named")
		"feeds":
			return feed(app, false)
		"loan_riba", "loan_demand", "loan_forgive", "loan_wait":
			return choose_loan(app, key.trim_prefix("loan_"))
		"school":
			return fund_school(app, "school", false)
		"umrah_jamal", "umrah_jamal_secret", "umrah_musa", "umrah_musa_secret":
			var id := key.trim_prefix("umrah_").trim_suffix("_secret")
			if not send_pilgrim(app, id, key.ends_with("_secret")):
				return false
			app.clock.skip_to(app.day + int(app.pilgrims.data.numbers.umrah_days), MORNING)
			app.update_state()
			return true
		"name_hasib":
			return app.names_of_allah.learn_at("scales", app.idris_met)
	return key.is_empty()


static func carry_jars(app: Node3D, count: int) -> bool:
	var first_night: int = app.day
	for offset in count:
		app.clock.skip_to(first_night + offset, int(app.qasims_jars.data.numbers.open_from))
		if not app.qasims_jars.carry():
			return false
	return true


static func visit_dice_house(app: Node3D, count: int) -> bool:
	var first_night: int = app.day
	for offset in count:
		app.clock.skip_to(first_night + offset, int(app.dice_house.data.numbers.open_from))
		if not app.dice_house.enter():
			return false
	return true


static func finish_fountain(app: Node3D, choice: String) -> bool:
	if not app.dry_fountain.pay(choice):
		return false
	while not app.dry_fountain.is_running():
		if not app.dry_fountain.pay(""):
			return false
	return true


static func feed(app: Node3D, secret: bool) -> bool:
	app.feeding.secret_selected = secret
	return app.feeding.pay(app.feeding.data.options[0].id, true)


static func fund_school(app: Node3D, kind: String, secret: bool) -> bool:
	app.qurans_school.secret_selected = secret
	return app.qurans_school.pay(kind, true)


static func send_pilgrim(app: Node3D, id: String, secret: bool) -> bool:
	app.pilgrims.secret_selected = secret
	return app.pilgrims.send(id, true)


static func choose_loan(app: Node3D, choice: String) -> bool:
	if choice == "riba":
		return app.rashids_loan.answer_ask("lend_more")
	if not app.rashids_loan.answer_ask("lend"):
		return false
	app.clock.skip_to(app.day + int(app.rashids_loan.data.numbers.due_days), MORNING)
	return app.rashids_loan.answer_due(choice)


static func story_lines(node: Node) -> Array[RichTextLabel]:
	var result: Array[RichTextLabel] = []
	if node is Control and not node.is_visible_in_tree():
		return result
	if node is RichTextLabel:
		result.append(node)
	for child in node.get_children():
		result.append_array(story_lines(child))
	return result
