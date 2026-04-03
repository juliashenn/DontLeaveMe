extends CanvasLayer

@onready var label = $Panel/DialogueText
@onready var bunny_portriat = $Panel/Portrait/BunnyPortrait
@onready var speaker_name_label = $Panel/SpeakerName
@onready var knight_portrait = $Panel/Portrait/KnightPortrait
@onready var monster_portrait = $Panel/Portrait/MonsterPortrait
@onready var writing: AudioStreamPlayer2D = $writing

@onready var map: TextureRect = $Control/Map


var full_text := ""
var current_text := ""
var char_index := 0
var typing_speed := 0.02
var is_typing := false
var current_portrait : TextureRect

signal dialogue_finished

func show_dialogue(line: DialogueLine):
	speaker_name_label.text = line.speaker.capitalize()
	# kick off your existing typewriter effect using line.text
	visible = true
	full_text = line.text
	current_text = ""
	char_index = 0
	is_typing = true
	label.text = ""
	set_process(true)
	writing.play()
	
	if line.speaker != null:
		$Panel/Portrait.visible = true
		match line.speaker:
			"bunny":
				current_portrait = bunny_portriat
				knight_portrait.visible = false
				map.visible = false
				monster_portrait.visible = false
			"knight":
				current_portrait = knight_portrait
				bunny_portriat.visible = false
				map.visible = false
				monster_portrait.visible = false
			"map":
				current_portrait = map
				knight_portrait.visible = false
				bunny_portriat.visible = false
				monster_portrait.visible = false
			"Unknown Monster":
				current_portrait = monster_portrait
				knight_portrait.visible = false
				bunny_portriat.visible = false
				map.visible = false
		current_portrait.visible = true
	else:
		$Panel/Portrait.visible = false

func _process(delta):
	if not is_typing:
		return
	if char_index < full_text.length():
		if not writing.playing:
			writing.play()
		current_text += full_text[char_index]
		label.text = current_text
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
	else:
		writing.stop()
		is_typing = false
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		advance()

func advance():
	if is_typing:
		label.text = full_text
		is_typing = false
	else:
		writing.stop()
		emit_signal("dialogue_finished")

func hide_dialogue():
	writing.stop()
	visible = false
	label.text = ""
