extends Node2D
@export var color = "Yellow"
@onready var sprite = $AnimatedSprite2D
@onready var light = $Flame
@onready var interactable: Area2D = $Interactable
@onready var click: AudioStreamPlayer2D = $click

func _ready() -> void:
	interactable.is_interactable = true
	interactable.interact = _on_interact

func _on_interact():
	if interactable.is_interactable:
		get_tree().get_first_node_in_group("player").play_click()
		toggle_light()

func toggle_interactable(can):
	interactable.is_interactable = can
	
var colors = {
	"Pink": Color8(255.0, 164.339, 253.006, 1.0), 
	"Blue": Color8(135.53, 255.0, 254.257, 1.0),
	"Green": Color8(165.439, 255.0, 142.093, 1.0),
	"Yellow": Color8(255, 255, 35),
	"Purple": Color8(162.242, 163.705, 226.737, 1.0)
	}

func _process(delta: float) -> void:
	if sprite.animation != color:
		changeColor(color)

func changeColor(cl) :
	color = cl
	light.set_light_color(colors[cl])
	sprite.play(cl)
	
func toggle_light():
	light.visible = !light.visible

func is_on():
	return light.visible

func set_light(on: bool):
	light.visible = on
