extends Node

@onready var ui = preload("res://Scenes/black.tscn").instantiate()

var day_scenes = {
	1: "res://Scenes/Day1.tscn",
	2: "res://Scenes/Day2.tscn",
	3: "res://Scenes/Day3.tscn"
}

func _ready() -> void:
	get_tree().root.add_child.call_deferred(ui)
	DayManager.day_started.connect(_on_scene_change)
	
func _on_scene_change(current_day):
	if day_scenes.has(current_day):
		var path = day_scenes[current_day]
		ui.fade_to_black()
		get_tree().change_scene_to_file(path)
		ui.fade_from_black()
