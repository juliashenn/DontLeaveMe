# DayManager.gd
extends Node

@onready var blood = preload("res://Scenes/blood.tscn").instantiate()

var current_day := 1
var time_limit := 2000.0
var time_left := 2000.0

signal day_started(day)
signal day_failed(reason)
signal day_completed(day)

signal state_changed(new_state)
signal dialogue_started
signal dialogue_ended

signal time_updated(time)

enum GameState {
	EXPLORING,
	DIALOGUE,
	CUTSCENE,
	PAUSED,
	ENDING
}

var current_state: GameState = GameState.DIALOGUE

var day_scenes = {
	1: "res://Scenes/Day1.tscn",
	2: "res://Scenes/Day2.tscn",
	3: "res://Scenes/Day3.tscn",
	4: "res://Scenes/Day4.tscn",
	5: "res://Scenes/Day5.tscn"
}

var dialogues = {
	1: {
		"start": {
			"good": preload("res://dialogue/day1.tres"),
			"hungry": preload("res://dialogue/day1_hungry.tres"),
		},
		"end": {
			"good": preload("res://dialogue/day1_end_good.tres"),
			"hungry": preload("res://dialogue/day1_end_hungry.tres"),
			"lonely": preload("res://dialogue/day1_end_lonely.tres")
		}
	},
	2: {
		"start": {
			"good": preload("res://dialogue/day2.tres"),
			"hungry": preload("res://dialogue/day2_hungry.tres"),
		},
		"end": {
			"good": preload("res://dialogue/day2_end_good.tres"),
			"hungry": preload("res://dialogue/day2_end_hungry.tres"),
			"lonely": preload("res://dialogue/day2_end_lonely.tres")
		}
	},
	3: {
		"start": {
			"good": preload("res://dialogue/day3.tres"),
			"hungry": preload("res://dialogue/day3_hungry.tres"),
		},
		"end": {
			"good": preload("res://dialogue/day3_end_good.tres"),
			"hungry": preload("res://dialogue/day3_end_hungry.tres"),
			"lonely": preload("res://dialogue/day3_end_lonely.tres")
		}
	},
	4: {
		"start": {
			"good": preload("res://dialogue/day4.tres"),
			"hungry": preload("res://dialogue/day4_hungry.tres"),
		},
		"end": {
			"good": preload("res://dialogue/day4_end_good.tres"),
			"hungry": preload("res://dialogue/day4_end_hungry.tres"),
			"lonely": preload("res://dialogue/day4_end_lonely.tres")
		}
	},
	5: {
		"start": {
			"good": preload("res://dialogue/day5.tres"),
			"hungry": preload("res://dialogue/day5_hungry.tres"),
		},
		"end": {
			"good": preload("res://dialogue/day5_end_good.tres"),
			"hungry": preload("res://dialogue/day5_end_bad.tres"),
			"lonely": preload("res://dialogue/day5_end_bad.tres")
		}
	}
}

var failed_end_dialogue = preload("res://dialogue/day5_end_5fails.tres")

var failed_days = 0

func start_day():
	ResourceManager.reset_day_resources()	
	match current_day:
		1:
			ResourceManager.set_required_food(3)
			time_limit = 60
		2:
			ResourceManager.set_required_food(3)
			time_limit = 120
		3:
			ResourceManager.set_required_food(3)
			time_limit = 120
		4:
			ResourceManager.set_required_food(3)
			time_limit = 120
		5:
			ResourceManager.set_required_food(4)
			time_limit = 180
		# scale as needed
	time_left = time_limit
	set_state(GameState.DIALOGUE)
	emit_signal("day_started", current_day)
	print("start signal emitted")
	print(current_day)
	await get_tree().create_timer(2.5).timeout
	trigger_dialogue("start","good")

func _process(delta):
	if current_state != GameState.EXPLORING:
		return
	time_left -= delta
	emit_signal("time_updated", time_left)
	if time_left <= 0 and failed_days < 5:
		fail_day("time")

func complete_day():
	set_state(GameState.DIALOGUE)
	if ResourceManager.met_food_requirement():
		emit_signal("day_completed", current_day)
		trigger_dialogue("end", "good")
		while current_state != GameState.EXPLORING:
			await state_changed
		if current_day >= day_scenes.size():
			set_state(GameState.ENDING)
			return
		current_day += 1
		start_day()
	else:
		fail_day("food")

func fail_day(reason: String):
	if current_state == GameState.ENDING:
		return
	failed_days += 1
	emit_signal("day_failed", reason)
	emit_signal("day_completed", current_day)
	
	if failed_days == 5:
		set_state(GameState.ENDING)
		SceneManager.teleport_player()
		SceneManager.change_scene("res://Scenes/escape_scene.tscn")
		DialogueManager.start_dialogue(failed_end_dialogue)
		return 
	
	if player_back and not ResourceManager.met_food_requirement():
		SceneManager.teleport_player()
		trigger_dialogue("end", "hungry")
	elif not player_back:
		SceneManager.teleport_player()
		trigger_dialogue("end", "lonely")
		
	while current_state != GameState.EXPLORING:
		await state_changed
	if current_day >= day_scenes.size():
		set_state(GameState.ENDING)
		return
	current_day += 1
	start_day()
	
func set_state(new_state: GameState):
	current_state = new_state
	emit_signal("state_changed", new_state)

func trigger_dialogue(time, type):
	# time = start, end
	# type = good, hungry, lonely
	var dialogue = dialogues[current_day][time][type]
	if dialogue:
		DialogueManager.start_dialogue(dialogue)

func start_dialogue():
	set_state(GameState.DIALOGUE)
	emit_signal("dialogue_started")

func end_dialogue():
	set_state(GameState.EXPLORING)
	emit_signal("dialogue_ended")
	
var prev_state : GameState
func pause_game():
	prev_state = current_state
	set_state(GameState.PAUSED)
	emit_signal("state_changed", GameState.PAUSED)
	get_tree().paused = true
	#emit_signal("game_paused")

func resume_game():
	if prev_state:
		set_state(prev_state)
	else:
		set_state(GameState.EXPLORING)
	get_tree().paused = false
	emit_signal("state_changed", current_state)
	#emit_signal("game_resumed")

var player_back := true

func player_left():
	player_back = false

func player_returned():
	if current_state != GameState.EXPLORING:
		return
	if ResourceManager.met_food_requirement():
		complete_day()
	#elif time_left > 15: #came back but with not enough food
		#trigger_dialogue("start", "hungry")

func end_game():
	DialogueManager.end_dialogue()
	get_tree().change_scene_to_file("res://Scenes/blood.tscn")
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://Scenes/end.tscn")

	
