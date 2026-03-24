extends Node2D

@onready var anim = $AnimatedSprite2D

const SPEAKER_ID = "bunny"  # must match exactly what you put in DialogueLine.speaker

func _ready():
	DialogueManager.speaker_animation_requested.connect(_on_animation_requested)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_animation_requested(speaker: String, animation: String):
	if speaker == SPEAKER_ID:
		if anim.sprite_frames.has_animation(animation):
			anim.play(animation)

func _on_dialogue_ended():
	anim.play("Sleeping")
