extends Node2D
@onready var interactable: Area2D = $Interactable
@onready var egg: Sprite2D = $Egg
@onready var area_2d: Area2D = $Area2D

var carrot: Node2D 


@export var has_chicken: bool
@export var has_egg: bool
var has_carrot: bool

func _ready() -> void:
	carrot = find_child("Carrot")
	has_carrot = carrot != null
	toggle_egg(has_egg)
	interactable.interact = _on_interact
	await get_tree().physics_frame
	area_2d.monitoring = false
	await get_tree().physics_frame
	area_2d.monitoring = true

func _process(delta: float) -> void:
	if has_carrot and (carrot == null or not is_instance_valid(carrot)):
		#print("carrot taken")
		carrot = null
		has_carrot = false
		update_state()

func _on_interact():
	if interactable.is_interactable:
		get_tree().get_first_node_in_group("player").play_click()
		if not has_egg:
			#print("placing egg")
			if ResourceManager.has_resource("egg"):
				ResourceManager.consume_resource("egg", 1)
				toggle_egg(true)
		else:
			#print("taking egg")
			ResourceManager.add_resource("egg", 1)
			toggle_egg(false)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("chicken"):
		#print("chicken here")
		has_chicken = true
		update_state()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("chicken"):
		#print("chicken left")
		has_chicken = false
		update_state()

func toggle_egg(on: bool):
	egg.visible = on
	has_egg = on
	update_state()

func update_state():
	if has_chicken:
		interactable.is_interactable = false
		if carrot != null and is_instance_valid(carrot):
			carrot.toggle_interactable(false)
		return

	# Carrot present (and no egg) — only carrot is interactable
	if has_carrot and not has_egg:
		if carrot != null and is_instance_valid(carrot):
			carrot.toggle_interactable(true)
		interactable.is_interactable = false
		return

	# Default — nest is interactable (place/take egg), carrot locked if somehow both exist
	if carrot != null and is_instance_valid(carrot):
		carrot.toggle_interactable(false)
	interactable.is_interactable = true
