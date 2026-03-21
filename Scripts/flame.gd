extends PointLight2D

@export var light_radius: float = 25.0
@export var move_speed: float = 6.0

# Flicker settings
@export var flicker_strength: float = 2.5
@export var energy_base: float = 1.2
@export var energy_variation: float = 0.4

# Base color (editable in editor)
@export var base_color: Color = Color(1.0, 0.8, 0.6)

var target_position: Vector2 = Vector2.ZERO

var noise := FastNoiseLite.new()
var noise_time: float = 0.0

func _ready():
	noise.seed = randi()
	noise.frequency = 2.0
	color = base_color

func _process(delta):
	noise_time += delta

	var smooth_pos = position.lerp(target_position, min(move_speed * delta, 1.0))

	var flicker_offset = Vector2(
		noise.get_noise_1d(noise_time),
		noise.get_noise_1d(noise_time + 100)
	) * flicker_strength

	position = smooth_pos + flicker_offset

	var flicker = noise.get_noise_1d(noise_time * 5.0)
	energy = energy_base + flicker * energy_variation

	var color_flicker = noise.get_noise_1d(noise_time * 4.0)
	color = base_color + Color(0.05 * color_flicker, 0.02 * color_flicker, 0)


func set_direction(direction: String):
	var angle_deg: float

	match direction:
		"Right": angle_deg = 0
		"DiagDownRight": angle_deg = 45
		"Down": angle_deg = 90
		"DiagDownLeft": angle_deg = 135
		"Left": angle_deg = 180
		"DiagUpLeft": angle_deg = 225
		"Up": angle_deg = 270
		"DiagUpRight": angle_deg = 315
		_: return

	var angle_rad = deg_to_rad(angle_deg)
	target_position = Vector2(cos(angle_rad), sin(angle_rad)) * light_radius


func set_light_color(new_color: Color):
	base_color = new_color
