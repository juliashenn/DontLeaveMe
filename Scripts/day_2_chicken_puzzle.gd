extends Node2D
@onready var nest_1: Node2D = $Nest #occupied w carrot
@onready var nest_2: Node2D = $Nest2 #empty
@onready var chicken: Node2D = $Chicken


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#DayManager.set_state(DayManager.GameState.EXPLORING)
	#chicken.move_to(nest_1.global_position)


var chicken_sent := false

func _process(delta: float) -> void:
	if nest_2.has_egg and not chicken_sent:
		chicken_sent = true
		chicken.move_to(nest_2.global_position)
	elif not nest_2.has_egg:
		chicken_sent = false
