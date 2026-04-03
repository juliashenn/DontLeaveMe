extends Node2D
@export var resource_type: String = "carrot"
@onready var interactable: Area2D = $Interactable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var click: AudioStreamPlayer2D = $click

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("default")
	interactable.is_interactable = true

	interactable.interact = _on_interact

func _on_interact():
	if interactable.is_interactable:
		get_tree().get_first_node_in_group("player").play_click()
		ResourceManager.add_resource(resource_type, 1)
		queue_free()
		
func toggle_interactable(can):
	interactable.is_interactable = can
