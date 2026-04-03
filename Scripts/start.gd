extends Control

@onready var bunny: Node2D = $Bunny

func _ready() -> void:
	bunny.change_anim("Sleeping")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/forest.tscn")
	DayManager.set_state(DayManager.GameState.DIALOGUE)
	DayManager.start_day()
	


func _on_quit_button_pressed() -> void:
	get_tree().quit()
