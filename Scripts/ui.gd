extends CanvasLayer
@onready var time_label: Label = $CenterContainer/VBoxContainer/TimeLabel
@onready var egg: HBoxContainer = $VBox/Egg
@onready var torch: HBoxContainer = $VBox/Torch
@onready var day_label: Label = $CenterContainer/VBoxContainer/DayLabel
@onready var map: TextureRect = $Map

var labels = {}
var boxes = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labels = {
		"carrot": $VBox/Carrot/CarrotLabel,
		"torch": $VBox/Torch/TorchLabel,
		"egg": $VBox/Egg/EggLabel,
	}
	boxes = {
		"carrot": $VBox/Carrot,
		"torch": $VBox/Torch,
		"egg": $VBox/Egg,
	}
	map.visible = false
	egg.visible = false
	torch.visible = false
	ResourceManager.resource_changed.connect(_on_resource_changed)
	ResourceManager.food_requirement_changed.connect(_on_food_requirement_changed)
	DayManager.time_updated.connect(_on_time_changed)
	update_all()
	day_label.text = get_parent().name

func _on_time_changed(time):
	var seconds = int(time)
	time_label.text = "%d:%02d" % [seconds / 60, seconds % 60]
	if time <= 10.0:
		time_label.modulate = Color.RED
	else:
		time_label.modulate = Color.WHITE

func _on_resource_changed(type, amount):
	if labels.has(type):
		labels[type].text = _format_text(type, amount)
		if amount != 0 or type == "carrot":
			boxes[type].visible = true
		else:
			boxes[type].visible = false

func _on_food_requirement_changed(required):
	var current_food = ResourceManager.get_resource("carrot")
	if labels.has("carrot"):
		labels["carrot"].text = "Carrots: %d / %d" % [current_food, required]

func update_all():
	for type in labels.keys():
		var label = labels[type]
		var value = ResourceManager.get_resource(type)

		label.text = _format_text(type, value)

func _format_text(type: String, value: int) -> String:
	match type:
		"carrot":
			return "Carrots: %d / %d" % [value, ResourceManager.required_food]
		"matches":
			return "Matches: %d" % value
		"egg":
			return "Eggs: %d" % value
		_:
			return "%s: %d" % [type.capitalize(), value]
			
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		DayManager.pause_game()
	if event.is_action_pressed("map"):
		map.visible = !map.visible


func _on_pause_button_pressed() -> void:
	DayManager.pause_game()


func _on_texture_button_pressed() -> void:
	map.visible = false
