# bone_bobble.gd
extends Bone2D
class_name BobbleBone

# Overshoots and rotates towards a point

@export var ENABLED          : bool      = true
@export var DAMPENING        : float     = 0.2
@export var TENSION          : float     = 0.3
@export var MAXIMUM_DISTANCE : Vector2   = Vector2(8.0, -8.0)

# Starting position
@onready var start_pos : Vector2 = position
var target_pos         : Vector2 = Vector2.ZERO
var strength           : Vector2 = Vector2.ZERO
var speed              : Vector2 = Vector2.ZERO

func _process(delta) -> void:
	# Calculate current input strength
	# and consequential displacement
	strength = get_input_vector()
	var displacement = ((start_pos + (MAXIMUM_DISTANCE * strength) - position)) #* delta
	speed += (TENSION * displacement) - (DAMPENING * speed)
	
	# Apply to position if enabled
	if ENABLED:
		position += speed

# FUNCTION
#-------------------------------------------------------------------------------

func get_input_vector() -> Vector2:
	return Input.get_vector(
		"move_left",
		"move_right",
		"look_down",
		"look_up"
	)
