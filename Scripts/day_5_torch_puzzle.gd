extends Node2D
@onready var torch1: Node2D = $Torch
@onready var torch2: Node2D = $Torch2
@onready var torch4: Node2D = $Torch4
@onready var torch3: Node2D = $Torch3
@onready var carrot: Node2D = $Carrot
@onready var texture_rect: TextureRect = $TextureRect
@onready var flame: PointLight2D = $Flame

var torch1_on := true
var torch2_on := false
var torch3_on := false
var torch4_on := false

var completed := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#DayManager.set_state(DayManager.GameState.EXPLORING)
	torch1.set_light(true)
	torch2.set_light(false)
	torch3.set_light(false)
	torch4.set_light(false)
	carrot.visible = false
	carrot.toggle_interactable(false)
	texture_rect.visible = false
	flame.visible = false

func _process(delta: float) -> void:
	if (torch1_on != torch1.is_on() or torch2_on != torch2.is_on() 
	or torch3_on != torch3.is_on() or torch4_on != torch4.is_on()):
		update_state()
	if not completed:
		if torch1_on and torch2_on and torch3_on and torch4_on:
			if carrot:
				print("got it")
				completed = true
				carrot.toggle_interactable(true)
				carrot.visible = true
				texture_rect.visible = true
				flame.visible = true
func update_state():
	if torch1_on != torch1.is_on():
		torch1_on = torch1.is_on()
		torch2.toggle_light()
		torch2_on = torch2.is_on()
		torch3.toggle_light()
		torch3_on = torch3.is_on()
	elif torch2_on != torch2.is_on():
		torch2_on = torch2.is_on()
		torch4.toggle_light()
		torch4_on = torch4.is_on()
	elif torch3_on != torch3.is_on():
		torch3_on = torch3.is_on()
		torch2.toggle_light()
		torch2_on = torch2.is_on()
		torch1.toggle_light()
		torch1_on = torch1.is_on()
	elif torch4_on != torch4.is_on():
		torch4_on = torch4.is_on()
		torch1.toggle_light()
		torch1_on = torch1.is_on()
