extends Node2D
#attach to player
@onready var interact_label: Label = $InteractLabel

# list of interactions available in range 
var current_interactions := []
var can_interact := true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			interact_label.hide()
			
			await current_interactions[0].interact.call()
			
			can_interact = true

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)


func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)

func _process(delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		if current_interactions[0].is_interactable :
			interact_label.text = current_interactions[0].interact_name
			interact_label.show()
	else:
		interact_label.hide() 
#returns tru	e or false depending if it should be sorted before or after
func _sort_by_nearest(area1, area2):
	var area1dist = global_position.distance_to(area1.global_position)
	var area2dist = global_position.distance_to(area2.global_position)
	return area1dist < area2dist
