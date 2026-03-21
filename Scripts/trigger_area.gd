extends Area2D

var front: Node2D
func _ready() -> void:
	front = get_tree().get_first_node_in_group("buildingfront")
	
func set_layer_active(active: bool):
	front.visible = active
	
	for child in front.get_children():
		if child is TileMapLayer:
			child.set_deferred("collision_enabled", active)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.toggle_flame(false)
		#print("removing building front")
		set_layer_active(false)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.toggle_flame(true)
		#print("adding building front")
		set_layer_active(true)
