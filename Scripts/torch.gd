extends Node2D


@export var color = "Yellow"

@onready var sprite = $AnimatedSprite2D
@onready var light = $Flame

var colors = {
	"Pink": Color8(255.0, 164.339, 253.006, 1.0), 
	"Blue": Color8(135.53, 255.0, 254.257, 1.0),
	"Green": Color8(165.439, 255.0, 142.093, 1.0),
	"Yellow": Color8(255, 255, 35),
	"Purple": Color8(162.242, 163.705, 226.737, 1.0)
	}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if sprite.animation != color:
		changeColor(color)

func changeColor(cl) :
	color = cl
	light.set_light_color(colors[cl])
	sprite.play(cl)
