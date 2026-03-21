extends CanvasLayer

var labels = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labels = {
		"carrot": $Control/CarrotLabel,
		"torch": $Control/TorchLabel,
		"egg": $Control/EggLabel,
	}
	ResourceManager.resource_changed.connect(_on_resource_changed)
	ResourceManager.food_requirement_changed.connect(_on_food_requirement_changed)
	update_all()

func _on_resource_changed(type, amount):
	if labels.has(type):
		labels[type].text = _format_text(type, amount)

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
