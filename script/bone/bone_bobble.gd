# bone_bobble.gd
extends Bone2D
class_name BobbleBone

# Overshoots and rotates towards a point

@export var ENABLED          : bool      = true
@export var MAXIMUM_DISTANCE : Vector2   = Vector2(8.0, -8.0)

# Starting position
@onready var start_pos : Vector2 = position
# Strength value
var strength           : Vector2 = Vector2.ZERO

func _process(_delta) -> void:
	if ENABLED:
		interpolate_position()

# FUNCTION
#-------------------------------------------------------------------------------

func interpolate_position() -> void:
	# Set strength
	strength = get_input_vector()
	position = lerp(
		position, start_pos + (MAXIMUM_DISTANCE * strength), 0.2
	)

func get_input_vector() -> Vector2:
	return Input.get_vector(
		"move_left",
		"move_right",
		"look_down",
		"look_up"
	)
