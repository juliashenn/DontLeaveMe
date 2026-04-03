extends Node

@onready var ui = preload("res://Scenes/black.tscn").instantiate()

var day_scenes = {
	1: "res://Scenes/Day1.tscn",
	2: "res://Scenes/Day2.tscn",
	3: "res://Scenes/Day3.tscn",
	4: "res://Scenes/Day4.tscn",
	5: "res://Scenes/Day5.tscn"
}
var player
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	get_tree().root.add_child.call_deferred(ui)
	DayManager.day_started.connect(_on_scene_change)
	
func _on_scene_change(current_day):
	if day_scenes.has(current_day):
		var path = day_scenes[current_day]
		DialogueManager.end_dialogue()
		ui.fade_to_black()
		get_tree().change_scene_to_file(path)
		ui.fade_from_black()

func teleport_player():
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not player:
		return 
	ui.fade_to_black()
	player.global_position = Vector2(174, 444)
	ui.fade_from_black()

func change_scene(path):
	ui.fade_to_black()
	get_tree().change_scene_to_file(path)
	ui.fade_from_black()
