extends CharacterBody2D
# want to make it so that when player enters cave
# its own flame goes out, cave roof disappears 

@export var speed : float = 150
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var dialogue_position : Vector2 = Vector2(158, 435)
@onready var footsteps: AudioStreamPlayer2D = $footsteps
@onready var wind: AudioStreamPlayer2D = $wind
@onready var click: AudioStreamPlayer2D = $click
@onready var water_footsteps = preload("res://Assets/SFX/464610__d001447733__water_footsteps.ogg")
@onready var camera_2d: Camera2D = $Camera2D

@onready var light = $Flame
var on_water := false
var last_direction := "Down"
var light_radius: float = 25.0
var light_speed: float = 5.0  # higher = faster smoothing

var can_move := false
var is_home := true

var step_interval = 105 / speed
var step_timer = 0.0

const SPEAKER_ID := "knight"

func _ready() -> void:
	DayManager.state_changed.connect(_on_state_changed)
	DialogueManager.speaker_animation_requested.connect(_on_animation_requested)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.setup.connect(_setup_dialogue)

func _exit_tree() -> void:
	if DayManager.state_changed.is_connected(_on_state_changed):
		DayManager.state_changed.disconnect(_on_state_changed)
	if DialogueManager.speaker_animation_requested.is_connected(_on_animation_requested):
		DialogueManager.speaker_animation_requested.disconnect(_on_animation_requested)
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	if DialogueManager.setup.is_connected(_setup_dialogue):
		DialogueManager.setup.disconnect(_setup_dialogue)

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
		step_timer = 0.0
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_vector  = Input.get_vector("left", "right", "up", "down")
	velocity = input_vector.normalized() * speed
	move_and_slide()

	update_animation(input_vector)
	
	if velocity.length() > 0 and DayManager.current_state == DayManager.GameState.EXPLORING:
		if on_water:
			if not footsteps.playing:
				footsteps.play()
		else :
			step_timer -= delta
			if step_timer <= 0:
				play_random_sound()
				step_timer = step_interval
	else:
		step_timer = 0.0
		if on_water and footsteps.playing:
			footsteps.stop()

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
	if not is_inside_tree():
		return
	anim.play("WalkDiagUpLeft")
	while global_position.distance_to(target_position) > 0.1:
		if not is_inside_tree() or get_tree() == null:
			return
		global_position = global_position.move_toward(target_position, speed * get_process_delta_time())
		await get_tree().process_frame
		if not is_inside_tree() or get_tree() == null:
			return
	anim.play("IdleDiagUpLeft")
		
func _setup_dialogue():
	move_player_to(Vector2(158, 435))

	# stop movement control here if needed
func set_is_home(isat):
	is_home = isat
	if isat:
		wind.volume_db = -25
		toggle_flame(false)
	else:
		wind.volume_db = -15
		toggle_flame(true)
	
func get_is_home():
	return is_home
	
var last_sound = null

var sounds = [
	preload("res://Assets/Walk/Dirt/DIRT - Walk 1.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk  2.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk Short 1.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk Short 2.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk 3.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk Short 3.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk 4.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk Short 4.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk 5.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk Short 5.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk 6.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk Short 6.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk 7.wav"),
	preload("res://Assets/Walk/Dirt/DIRT - Walk Short 7.wav"),
]

func play_random_sound():
	if sounds.size() == 0:
		return
	var new_sound = sounds.pick_random()
	while new_sound == last_sound and sounds.size() > 1:
		new_sound = sounds.pick_random()
	last_sound = new_sound
	footsteps.stream = new_sound
	footsteps.play()

func play_anim(animation: String):
	anim.play(animation)

func play_click():
	click.play()

func play_water():
	on_water = true
	footsteps.stream = water_footsteps
	if not footsteps.playing:
		footsteps.play()

func leave_water():
	on_water = false
	footsteps.stop()

func zoom_camera(target_zoom: Vector2, duration: float):
	var start_zoom = camera_2d.zoom
	var time_passed = 0.0

	while time_passed < duration:
		await get_tree().process_frame
		time_passed += get_process_delta_time()
		
		var t = clamp(time_passed / duration, 0.0, 1.0)
		camera_2d.zoom = start_zoom.lerp(target_zoom, t)

	camera_2d.zoom = target_zoom
