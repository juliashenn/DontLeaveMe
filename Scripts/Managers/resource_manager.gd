extends Node

signal resource_changed(type, new_amount)
signal food_requirement_changed(required)

var resources = {
	"carrot": 0,
	"torch": 0,
	"egg": 0
}
var required_food := 1

func add_resource(type: String, amount := 1):
	if not resources.has(type):
		resources[type] = 0
	resources[type] += amount
	emit_signal("resource_changed", type, resources[type])
	
func get_resource(type: String):
	if resources.has(type):
		return resources[type]
	return 0

func consume_resource(type: String, amount := 1) -> bool:
	if resources.get(type, 0) >= amount:
		resources[type] -= amount
		emit_signal("resource_changed", type, resources[type])
		return true
	return false

func has_resource(type: String, amount := 1) -> bool:
	return resources.get(type, 0) >= amount

func reset_day_resources():
	resources["carrot"] = 0
	resources["matches"] = 0
	resources["egg"] = 0

func set_required_food(amount):
	required_food = amount
	emit_signal("food_requirement_changed", required_food)

func met_food_requirement() -> bool:
	return resources["carrot"] >= required_food
	
