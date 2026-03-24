extends Node2D
@export var resource_type: String = "egg"
@onready var interactable: Area2D = $Interactable
var is_picked := false

@onready var egg: Sprite2D = $Egg

func _ready() -> void:
	interactable.interact = _on_interact
	egg.visible = false

func _on_interact():
	if not is_picked:
		if ResourceManager.has_resource("egg"):
			ResourceManager.consume_resource(resource_type, 1)
			egg.visible = true
