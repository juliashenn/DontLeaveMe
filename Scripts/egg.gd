extends Node2D
@export var resource_type: String = "egg"
@onready var interactable: Area2D = $Interactable
@onready var click: AudioStreamPlayer2D = $click

func _ready() -> void:
	interactable.is_interactable = true
	interactable.interact = _on_interact

func _on_interact():
	if interactable.is_interactable:
		get_tree().get_first_node_in_group("player").play_click()
		ResourceManager.add_resource(resource_type, 1)
		queue_free()

func toggle_interactable(can):
	interactable.is_interactable = can
