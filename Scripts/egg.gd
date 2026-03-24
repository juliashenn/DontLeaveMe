extends Node2D
@export var resource_type: String = "egg"
@onready var interactable: Area2D = $Interactable
var is_picked := false

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	if not is_picked:
		ResourceManager.add_resource(resource_type, 1)
		queue_free()
