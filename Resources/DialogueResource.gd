extends Resource
class_name DialogueResource

@export var lines: Array[DialogueLine] = []  # was Array[String]
@export var auto_advance := false
@export var typing_speed: float = 0.02
@export var camera_focus_target: NodePath
