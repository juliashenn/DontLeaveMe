extends Node2D
@export var resource_type: String = "carrot"
@onready var interactable: Area2D = $Interactable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var is_picked := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("default")
	interactable.interact = _on_interact

func _on_interact():
	if not is_picked:
		ResourceManager.add_resource(resource_type, 1)
		queue_free()
