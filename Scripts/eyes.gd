extends Node2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var is_right: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_right:
		anim.flip_h = true
	anim.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
