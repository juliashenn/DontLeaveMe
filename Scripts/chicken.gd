extends Node2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var speed := 50.0
var moved = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("Idle")

var target_position: Vector2
var moving = false

func move_to(pos: Vector2):
	target_position = pos
	moving = true
	anim.play("Walk")
	moved = true

func _physics_process(delta):
	if not moving:
		return
	anim.flip_h = global_position.x > target_position.x
	if global_position.distance_to(target_position) > 0.1:
		global_position = global_position.move_toward(target_position, speed * delta)
	else:
		moving = false
		anim.play("Idle")
