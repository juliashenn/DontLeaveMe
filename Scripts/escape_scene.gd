extends Node2D
@onready var player: CharacterBody2D = $Terrain/Player
@onready var arrow: Control = $CanvasLayer/Arrow
@onready var camera = get_viewport().get_camera_2d()
@onready var exit: CollisionShape2D = $exit/CollisionShape2D
@onready var bunny: Node2D = $Terrain/Bunny
@onready var music: AudioStreamPlayer2D = $Terrain/Campfire/music
@onready var chasemusic: AudioStreamPlayer2D = $Terrain/Bunny/chasemusic

var dialogue_ended = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arrow.visible = false
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	#DayManager.set_state(DayManager.GameState.EXPLORING)

func _on_dialogue_ended():
	dialogue_ended = true
	if DayManager.current_state == DayManager.GameState.ENDING:
		arrow.visible = true
		return
	DayManager.set_state(DayManager.GameState.EXPLORING)
	arrow.visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dialogue_ended:
		var screen_size = get_viewport().get_visible_rect().size / get_viewport().get_screen_transform().get_scale()
		var screen_center = screen_size / 2
		
		var exit_screen = (exit.global_position - camera.global_position) * camera.zoom + screen_center
		var dir = (exit_screen - screen_center).normalized()
		
		var on_screen = Rect2(Vector2.ZERO, screen_size).has_point(exit_screen)
		arrow.visible = not on_screen
		if not arrow.visible:
			return
			
		var radius = min(screen_center.x, screen_center.y) - 80.0
		var arrow_center = screen_center + dir * radius
		
		arrow.position = arrow_center - arrow.size / 2
		arrow.pivot_offset = arrow.size / 2
		arrow.rotation = atan2(dir.y, dir.x)


func _on_exit_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneManager.change_scene("res://Scenes/bunny_alone.tscn")


func _on_start_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		music.stop()
		bunny.start_chase()
		chasemusic.play()
