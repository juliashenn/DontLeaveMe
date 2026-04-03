extends Node

@onready var ui = preload("res://Scenes/dialogue_ui.tscn").instantiate()
var player: Node2D
var camera: Camera2D

signal dialogue_started
signal dialogue_ended
signal speaker_animation_requested(speaker, anim)
signal setup

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
	if current_dialogue.lines.size() > 0 and current_dialogue.lines[1].speaker == "bunny":
		emit_signal("setup")
	_show_current_line()
	emit_signal("dialogue_started")

func _show_current_line():
	if current_dialogue == null:
		return
	if current_line_index < current_dialogue.lines.size():
		var line = current_dialogue.lines[current_line_index]
		ui.show_dialogue(line)
		if line.animation != "":
			emit_signal("speaker_animation_requested", line.speaker, line.animation)
	else:
		end_dialogue()

var waiting_for_animation = false

func _on_line_finished():
	if waiting_for_animation:
		return  # eat the input until animation is done
	current_line_index += 1
	_show_current_line()

func animation_done():
	waiting_for_animation = false
	current_line_index += 1
	_show_current_line()

func end_dialogue():
	ui.hide_dialogue()
	emit_signal("dialogue_ended")
	if DayManager.current_state != DayManager.GameState.ENDING:
		DayManager.set_state(DayManager.GameState.EXPLORING)
