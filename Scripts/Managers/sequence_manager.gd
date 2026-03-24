extends Node

var player: Node2D
var camera: Camera2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	camera = get_tree().get_first_node_in_group("camera")

func start_dialogue():
	move_player_to(Vector2(158.0, 435))

func move_player_to(target_position: Vector2, speed := 100.0):
	DayManager.set_state(DayManager.GameState.CUTSCENE)

	while player.global_position.distance_to(target_position) > 2.0:
		player.global_position = player.global_position.move_toward(
			target_position,
			speed * get_process_delta_time()
		)
		await get_tree().process_frame


func focus_camera_on(target: Node2D, zoom := 1.2, speed := 5.0):
	# Smoothly move camera to target
	while camera.global_position.distance_to(target.global_position) > 2.0:
		camera.global_position = camera.global_position.lerp(
			target.global_position,
			speed * get_process_delta_time()
		)
		await get_tree().process_frame

	# Smooth zoom (smaller = zoom in)
	var target_zoom = Vector2(1.0 / zoom, 1.0 / zoom)

	while camera.zoom.distance_to(target_zoom) > 0.01:
		camera.zoom = camera.zoom.lerp(target_zoom, speed * get_process_delta_time())
		await get_tree().process_frame
		
func play_ending(bunny: Node2D, cave_position: Vector2):
	DayManager.set_state(DayManager.GameState.CUTSCENE)

	# Move player into position
	await move_player_to(cave_position)

	# Focus camera between bunny + player
	var midpoint = (player.global_position + bunny.global_position) / 2.0
	await focus_camera_on_position(midpoint, 1.3)

	# Start dialogue
	var dialogue = preload("res://dialogue/day7_ending.tres")
	DialogueManager.start_dialogue(dialogue)

	await DialogueManager.dialogue_ended

	DayManager.set_state(DayManager.GameState.ENDING)
	
func focus_camera_on_position(pos: Vector2, zoom := 1.2, speed := 5.0):
	while camera.global_position.distance_to(pos) > 2.0:
		camera.global_position = camera.global_position.lerp(
			pos,
			speed * get_process_delta_time()
		)
		await get_tree().process_frame

	var target_zoom = Vector2(1.0 / zoom, 1.0 / zoom)

	while camera.zoom.distance_to(target_zoom) > 0.01:
		camera.zoom = camera.zoom.lerp(target_zoom, speed * get_process_delta_time())
		await get_tree().process_frame
