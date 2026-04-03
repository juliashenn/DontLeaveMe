extends Node2D
@onready var nest_1: Node2D = $Nest1
@onready var nest_2: Node2D = $Nest2
@onready var nest_3: Node2D = $Nest3
@onready var chicken: Node2D = $Chicken
@onready var chicken_2: Node2D = $Chicken2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#DayManager.set_state(DayManager.GameState.EXPLORING)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if nest_1.has_egg and not chicken.moved:
		chicken.move_to(nest_1.global_position)
	if nest_2.has_egg and not chicken_2.moved:
		chicken_2.move_to(nest_2.global_position)
