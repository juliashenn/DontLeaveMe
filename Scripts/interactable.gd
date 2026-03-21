extends Area2D
# attach to objects

@export var interact_name: String = ""
@export var is_interactable: bool = true

var interact: Callable = func():
	pass
# this is a callable that we can set so that 
# each interactable can customize the interaction result
