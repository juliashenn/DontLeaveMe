extends CanvasLayer

@onready var label = $Panel/DialogueText

var full_text := ""
var current_text := ""
var char_index := 0
var typing_speed := 0.02
var is_typing := false

signal dialogue_finished

func show_dialogue(text: String):
	visible = true
	full_text = text
	current_text = ""
	char_index = 0
	is_typing = true
	set_process(true)

func _process(delta):
	if not is_typing:
		return

	if char_index < full_text.length():
		current_text += full_text[char_index]
		label.text = current_text
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
	else:
		is_typing = false
		
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			advance() # finishes current line instantly
		else:
			DialogueManager._on_line_finished()

func advance():
	if is_typing:
		# Skip typing
		label.text = full_text
		is_typing = false
	else:
		emit_signal("dialogue_finished")

func hide_dialogue():
	visible = false
	label.text = ""
