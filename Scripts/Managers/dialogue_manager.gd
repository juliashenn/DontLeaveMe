extends Node

@onready var ui = preload("res://Scenes/dialogue_ui.tscn").instantiate()

signal dialogue_started
signal dialogue_ended

var current_dialogue: DialogueResource
var current_line_index := 0

func _ready():
	get_tree().root.add_child.call_deferred(ui)
	ui.visible = false
	ui.dialogue_finished.connect(_on_line_finished)

func start_dialogue(dialogue: DialogueResource):
	current_dialogue = dialogue
	current_line_index = 0

	DayManager.set_state(DayManager.GameState.DIALOGUE)

	_show_current_line()
	emit_signal("dialogue_started")

func _show_current_line():
	if current_dialogue == null:
		return

	if current_line_index < current_dialogue.lines.size():
		var line = current_dialogue.lines[current_line_index]
		ui.show_dialogue(line)
	else:
		end_dialogue()

func _on_line_finished():
	current_line_index += 1
	_show_current_line()

func end_dialogue():
	ui.hide_dialogue()
	DayManager.set_state(DayManager.GameState.EXPLORING)
	emit_signal("dialogue_ended")
