extends Node

enum State { SAFE, WARNING, DANGER }

var current_state = State.SAFE
var player_velocity := Vector2.ZERO
@export var player: CharacterBody2D
@onready var timer = $Timer
@onready var eyes: Node2D = $eyes
@onready var eyes_2: Node2D = $eyes2
@onready var alert: AudioStreamPlayer2D = $alert
@onready var breathing: AudioStreamPlayer2D = $breathing

var is_active = false
var fail_counts = 0
var has_failed = false

var dialogues =  [preload("res://dialogue/water_monster.tres"),preload("res://dialogue/water_monster2.tres"),preload("res://dialogue/water_monster3.tres")]
var start_dialogue = preload("res://dialogue/waterpuzzleinto.tres")
var no_carrot_dialogue = preload("res://dialogue/water_monster_no_carrot.tres")
func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	#DayManager.set_state(DayManager.GameState.EXPLORING)
	eyes.visible = false
	eyes_2.visible = false

func _on_dialogue_ended():
	if not has_failed and not is_active:
		return
	player.play_water()
	stop_puzzle()
	restart_puzzle()

func start_safe_phase():
	if not is_active:
		return
	started = true
	clear_timer_connections()
	#print("start safe")
	breathing.stop()
	current_state = State.SAFE
	eyes.visible = false
	eyes_2.visible = false
	
	timer.start(randf_range(5.0, 7.0))
	timer.timeout.connect(start_warning_phase, CONNECT_ONE_SHOT)

func start_warning_phase():
	clear_timer_connections()
	#print("warning")
	current_state = State.WARNING
	
	alert.play(2.8)
	
	timer.start(1.2) 
	timer.timeout.connect(start_danger_phase, CONNECT_ONE_SHOT)

func start_danger_phase():
	clear_timer_connections()
	#print("danger")
	current_state = State.DANGER
	
	eyes.global_position = get_random_point_on_radius(player.global_position, 100)
	eyes_2.global_position = eyes.global_position + Vector2(30, 0)
	eyes.visible = true
	eyes_2.visible = true
	if not breathing.playing:
		breathing.play()
	
	timer.start(randf_range(3.0, 4.0)) 
	timer.timeout.connect(start_safe_phase, CONNECT_ONE_SHOT)

func _process(delta):
	check_player_movement()

func check_player_movement():
	if not is_active or has_failed:
		return
	if current_state == State.DANGER:
		if is_player_moving():
			fail_puzzle()

func is_player_moving() -> bool:
	return player.velocity.length() > 0.1

func fail_puzzle():
	if has_failed:
		return    
	has_failed = true
	is_active = false
	player.update_animation(Vector2(0,0))
	if ResourceManager.has_resource("carrot", 1):
		DialogueManager.start_dialogue(dialogues[fail_counts])
		ResourceManager.consume_resource("carrot", 1)
		spawn()
		if fail_counts < 2:
			fail_counts += 1
	else:
		DialogueManager.start_dialogue(no_carrot_dialogue)
	

func restart_puzzle():
	has_failed = false
	is_active = true
	current_state = State.SAFE
	eyes.visible = false
	eyes_2.visible = false
	start_safe_phase()

func stop_puzzle():
	started = false
	is_active = false
	timer.stop()
	eyes.visible = false
	eyes_2.visible = false
	if timer.timeout.is_connected(start_warning_phase):
		timer.timeout.disconnect(start_warning_phase)
	if timer.timeout.is_connected(start_danger_phase):
		timer.timeout.disconnect(start_danger_phase)
	if timer.timeout.is_connected(start_safe_phase):
		timer.timeout.disconnect(start_safe_phase)

func get_random_point_on_radius(center: Vector2, radius: float) -> Vector2:
	var angle: float
	if randf() < 0.5:
		angle = randf_range(PI, 4 * PI / 3)
	else:
		angle = randf_range(5 * PI / 3, TAU)   
	return center + Vector2(cos(angle), sin(angle)) * radius
	
func clear_timer_connections():
	for conn in timer.timeout.get_connections():
		timer.timeout.disconnect(conn.callable)
var started = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if is_active:
			return
		#print("starting dialogue")
		player.update_animation(Vector2(0,0))
		DialogueManager.start_dialogue(start_dialogue)
		player.speed = 40
		is_active = true
	#start_safe_phase()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		stop_puzzle()
		player.leave_water()
		player.speed = 70

func get_random_point_in_area(collision_polygon: CollisionPolygon2D) -> Vector2:
	var poly = collision_polygon.polygon
	var rect = Rect2(poly[0], Vector2.ZERO)
	for p in poly:
		rect = rect.expand(p)
	while true:
		var local_point = Vector2(
			randf_range(rect.position.x, rect.end.x),
			randf_range(rect.position.y, rect.end.y)
		)
		if Geometry2D.is_point_in_polygon(local_point, poly):
			return collision_polygon.to_global(local_point)
	return Vector2(-100, 100)
	
func spawn():
	var pos = get_random_point_in_area($respawnarea/CollisionPolygon2D)
	print(pos)
	var instance = preload("res://Scenes/carrot.tscn").instantiate()
	instance.global_position = pos
	get_tree().current_scene.add_child(instance)
