extends Node2D


@onready var dialogue = preload("res://dialogue/escaped.tres")

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	await get_tree().create_timer(2).timeout
	DialogueManager.start_dialogue(dialogue)

func _on_dialogue_ended():
	SceneManager.change_scene("res://Scenes/end.tscn")
