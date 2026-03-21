extends CharacterBody2D
# want to make it so that when player enters cave
# its own flame goes out, cave roof disappears 

@export var speed : float = 150

@onready var light = $Flame
var last_direction := "Down"
var light_radius: float = 25.0
var target_position: Vector2 = Vector2.ZERO
var light_speed: float = 5.0  # higher = faster smoothing

var can_move := true

func _ready() -> void:
	DayManager.state_changed.connect(_on_state_changed)
	
func _on_state_changed(state):
	can_move = (state == DayManager.GameState.EXPLORING)

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_vector  = Input.get_vector("left", "right", "up", "down")
	velocity = input_vector.normalized() * speed
	move_and_slide()

	update_animation(input_vector)

func toggle_flame(on: bool):
	var flame = $Flame
	flame.visible = on

func update_animation(dir: Vector2):

	var sprite = $AnimatedSprite2D

	if dir.length() > 0:

		var direction_name = get_direction_name(dir.normalized())
		last_direction = direction_name
		sprite.play("Walk" + direction_name)
		light.set_direction(direction_name)
	else:
		sprite.play("Idle" + last_direction)
		


func get_direction_name(dir: Vector2) -> String:
	var angle = dir.angle()
	var sector = int(round(angle / (PI / 4))) % 8
	
	var directions = ["Right", "DiagDownRight",
	 "Down","DiagDownLeft","Left",
	"DiagUpLeft","Up","DiagUpRight"]

	return directions[sector]
	
func move_player_to(target_position: Vector2, move_speed := 2.0):
	DayManager.set_state(DayManager.GameState.CUTSCENE)

	while global_position.distance_to(target_position) > 0.1:
		global_position = global_position.move_toward(target_position, move_speed * get_process_delta_time())
		await get_tree().process_frame

	# stop movement control here if needed
