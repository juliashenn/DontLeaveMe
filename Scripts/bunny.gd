extends Node2D
@export var player: CharacterBody2D
@onready var anim = $AnimatedSprite2D
@onready var chomp: AudioStreamPlayer2D = $chomp
@onready var thump: AudioStreamPlayer2D = $thump
@onready var timer: Timer = $Timer
@onready var anim_buff: AnimatedSprite2D = $AnimatedSprite2D2
@onready var chasing: Node2D = $chasing

const SPEAKER_ID = "bunny"  # must match exactly what you put in DialogueLine.speaker

func _ready():
	randomize()
	_set_random_time()
	timer.start()
	anim_buff.visible = false
	
	anim.play("IdleStanding")
	DialogueManager.speaker_animation_requested.connect(_on_animation_requested)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.setup.connect(_on_setup)
	chasing.visible = false

func _on_setup():
	global_position = Vector2(80.0, 410.0)
	anim.flip_h = false
	anim.visible = true
	anim_buff.flip_h = false
	anim_buff.visible = false

func _set_random_time():
	timer.wait_time = randf_range(15.0, 30.0)
	thump.pitch_scale = randf_range(0.9, 1.1)
	thump.volume_db = randf_range(-20, -10)
	
	
func _on_animation_requested(speaker: String, animation: String):
	if speaker == SPEAKER_ID:
		if anim.sprite_frames.has_animation(animation):
			if animation == "Buff" or animation == "BuffEat":
				anim_buff.visible = false
				anim.visible = true
				if animation == "Buff":
					DialogueManager.waiting_for_animation = true
					anim.play("Run")
					move_to(player.global_position - Vector2(30, 0))
					await player.zoom_camera(Vector2(5, 5), 2.0)
					await _wait_until_arrived()
					anim.visible = false
					anim_buff.visible = true
					anim_buff.play("Buff")
					await anim_buff.animation_finished
					DialogueManager.animation_done()
				elif animation == "BuffEat":
					DialogueManager.waiting_for_animation = true
					anim.visible = false
					anim_buff.visible = true
					anim_buff.play("BuffEat")
					await anim_buff.animation_finished
					DialogueManager.animation_done()
			else:
				anim_buff.visible = false
				anim.visible = true
				anim.play(animation)
				
func _wait_until_arrived() -> void:
	while moving:
		await get_tree().process_frame

func _on_dialogue_ended():
	moving = false
	anim_buff.visible = false
	anim.visible = true
	anim.play("Sleeping")
	
func change_anim(animation: String):
	anim.play(animation)

func _on_animated_sprite_2d_frame_changed() -> void:
	if anim_buff.animation == "BuffEat":
		if anim_buff.frame == 7:
			chomp.play()
			if player:
				player.play_anim("Die")
		if anim_buff.frame == 8:
			await get_tree().create_timer(0.3).timeout
			DayManager.end_game()
				
@export var speed = 10.0
var target_position: Vector2
var moving = false

func move_to(pos: Vector2):
	target_position = pos
	moving = true
	anim_buff.flip_h = global_position.x > target_position.x

var caught = false
var is_chasing = false
var chase_speed = 60.0
@export var catch_distance = 20.0
@onready var end_dialogue = preload("res://dialogue/failed_escape.tres")


func start_chase():
	print("starting chase")
	is_chasing = true
	chasing.visible = true
	caught = false

func stop_chase():
	chasing.visible = false
	is_chasing = false

func _physics_process(delta):
	if caught:
		return
	if moving:
		anim_buff.flip_h = global_position.x > target_position.x
		if global_position.distance_to(target_position) > 0.1:
			global_position = global_position.move_toward(target_position, speed * delta)
		else:
			moving = false
		return
	if not is_chasing:  # just add this guard
		return
	if not player:
		return
	var dir = (player.global_position - global_position).normalized()
	anim.flip_h = global_position.x > player.global_position.x
	anim.visible = true
	anim_buff.visible = false
	anim.play("Run")
	global_position += dir * chase_speed * delta
	if is_chasing and global_position.distance_to(player.global_position) < catch_distance:
		stop_chase()
		SceneManager.teleport_player()
		DialogueManager.start_dialogue(end_dialogue)
		


func _on_timer_timeout() -> void:
	thump.play()
	_set_random_time()
	timer.start()
