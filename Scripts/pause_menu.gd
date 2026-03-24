extends Control
@onready var map: TextureRect = $Map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	DayManager.state_changed.connect(_on_state_changed)

func _on_state_changed(state):
	visible = (state == DayManager.GameState.PAUSED)

func _on_resume_button_pressed() -> void:
	DayManager.resume_game()
	visible = false

func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	pass # Replace with function body.


func _on_texture_button_pressed() -> void:
	map.visible = false


func _on_map_button_pressed() -> void:
	map.visible = true
