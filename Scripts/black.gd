extends CanvasLayer
@onready var anim = $AnimationPlayer

func _ready() -> void:
	visible = false

func fade_to_black():
	visible = true
	anim.play("fade_to_black")
	await anim.animation_finished

func fade_from_black():
	anim.play("fade_from_black")
	await anim.animation_finished
	visible = false
