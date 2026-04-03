extends Control
@onready var map: TextureRect = $Map
var bus_index = AudioServer.get_bus_index("Master")
@onready var h_slider: HSlider = $Panel/VBoxContainer/Volume/HSlider
@onready var credits: Panel = $Credits

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	DayManager.state_changed.connect(_on_state_changed)
	credits.visible = false
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_state_changed(state):
	visible = (state == DayManager.GameState.PAUSED)

func _on_resume_button_pressed() -> void:
	DayManager.resume_game()
	visible = false

func _on_credits_button_pressed() -> void:
	credits.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(h_slider.value))


func _on_texture_button_pressed() -> void:
	map.visible = false


func _on_map_button_pressed() -> void:
	map.visible = true


func _on_credit_close_pressed() -> void:
	credits.visible = false
