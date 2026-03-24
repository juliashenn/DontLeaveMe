extends Control

#@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
#@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/forest.tscn")
	DayManager.start_day()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
