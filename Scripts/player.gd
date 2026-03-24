extends CharacterBody2D
# want to make it so that when player enters cave
# its own flame goes out, cave roof disappears 

@export var speed : float = 150
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var dialogue_position : Vector2 = Vector2(158, 435)

@onready var light = $Flame
var last_direction := "Down"
var light_radius: float = 25.0
var light_speed: float = 5.0  # higher = faster smoothing

var can_move := false

var is_home := true

const SPEAKER_ID := "knight"

func _ready() -> void:
	DayManager.state_changed.connect(_on_state_changed)
	DialogueManager.speaker_animation_requested.connect(_on_animation_requested)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.setup.connect(_setup_dialogue)

func _on_animation_requested(speaker: String, animation: String):
	if speaker == SPEAKER_ID:
		if anim.sprite_frames.has_animation(animation):
			anim.play(animation)

func _on_dialogue_ended():
	anim.play("IdleDown")

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
	
func move_player_to(target_position: Vector2):
	if DayManager.current_state == DayManager.GameState.EXPLORING:
		return 
	anim.play("WalkDiagUpLeft")
	while global_position.distance_to(target_position) > 0.1:
		global_position = global_position.move_toward(target_position, speed * get_process_delta_time())
		await get_tree().process_frame
	anim.play("IdleDiagUpLeft")
		
func _setup_dialogue():
	move_player_to(Vector2(158, 435))

	# stop movement control here if needed
func set_is_home(isat):
	is_home = isat
	if isat:
		toggle_flame(false)
	else:
		toggle_flame(true)
	
func get_is_home():
	return is_home
