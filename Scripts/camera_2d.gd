extends Camera2D

func focus_on(target: Node2D, zoom: float = 1.0):
	var target_pos = target.global_position
	var current_pos = global_position

	# Smoothly interpolate position
	global_position = current_pos.lerp(target_pos, 0.1)

	# Smooth zoom (Camera2D uses Vector2)
	var target_zoom = Vector2(1, 1) / zoom
	zoom = lerp(target, target_zoom, 0.1)
