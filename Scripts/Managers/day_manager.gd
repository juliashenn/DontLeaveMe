# DayManager.gd
extends Node

var current_day := 1
var time_limit := 60.0
var time_left := 0.0

signal day_started(day)
signal day_failed(reason)
signal day_completed(day)

signal state_changed(new_state)
signal dialogue_started
signal dialogue_ended

enum GameState {
	EXPLORING,
	DIALOGUE,
	CUTSCENE,
	PAUSED,
	ENDING
}

var current_state: GameState = GameState.EXPLORING

func start_day():
	time_left = time_limit
	ResourceManager.reset_day_resources()

	match current_day:
		1:
			ResourceManager.set_required_food(1)
			time_limit = 60
		2:
			ResourceManager.set_required_food(2)
			time_limit = 55
		3:
			ResourceManager.set_required_food(2)
			time_limit = 50
		# scale as needed

	emit_signal("day_started", current_day)

func _process(delta):
	time_left -= delta
	if time_left <= 0:
		fail_day("time")

func complete_day():
	if ResourceManager.met_food_requirement():
		emit_signal("day_completed", current_day)
		current_day += 1
		start_day()
	else:
		fail_day("food")

func fail_day(reason: String):
	emit_signal("day_failed", reason)
	
func set_state(new_state: GameState):
	current_state = new_state
	emit_signal("state_changed", new_state)

func trigger_end_of_day():
	var dialogue: DialogueResource

	match current_day:
		1:
			dialogue = preload("res://dialogue/day1.tres")
		2:
			dialogue = preload("res://dialogue/day2.tres")
		3:
			dialogue = preload("res://dialogue/day3.tres")

	DialogueManager.start_dialogue(dialogue)

func start_dialogue():
	set_state(GameState.DIALOGUE)
	emit_signal("dialogue_started")

func end_dialogue():
	set_state(GameState.EXPLORING)
	emit_signal("dialogue_ended")
