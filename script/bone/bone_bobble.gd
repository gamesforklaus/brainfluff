# bone_bobble.gd
extends Bone2D
class_name BobbleBone

# Overshoots and rotates towards a point

@export var ENABLED          : bool      = true
@export var PHYS_BODY        : PhysicsBody2D
@export_category("SpringPhysics")
@export var DAMPENING        : float     = 0.15
@export var TENSION          : float     = 0.2
@export var MAXIMUM_DISTANCE : Vector2   = Vector2(8.0, -8.0)
@export_category("InterpretedPhysics")
@export var PHYSICS_FACTOR   : float     = 2.0
@export var PHYSICS_EXTENTS  : float     = 4.0

# Starting position
@onready var start_pos : Vector2 = position
var target_pos         : Vector2 = Vector2.ZERO
var int_velocity       : Vector2 = Vector2.ZERO
var strength           : Vector2 = Vector2.ZERO
var speed              : Vector2 = Vector2.ZERO

func _process(delta) -> void:
	# Get the strength vector
	strength = get_input_vector()
	
	# Calculate current input strength
	# and consequential displacement
	int_velocity     = lerp(int_velocity, interpret_velocity(delta), 0.2)
	target_pos       = (start_pos + int_velocity + (MAXIMUM_DISTANCE * strength))
	var displacement = (target_pos - position)
	speed += (TENSION * displacement) - (DAMPENING * speed)
	
	# Apply to position if enabled
	if ENABLED:
		position += speed

# FUNCTION
#-------------------------------------------------------------------------------

func interpret_velocity(delta : float) -> Vector2:
	# Get the maximum movement speed and
	# divide into current
	var max_spd = PHYS_BODY.GROUND_SPEED * delta
	var current_spd = PHYS_BODY.linear_velocity
	var interpret = current_spd / max_spd * -PHYSICS_FACTOR
	
	return Vector2(
		clampf(interpret.x, -PHYSICS_EXTENTS, PHYSICS_EXTENTS),
		clampf(interpret.y, -PHYSICS_EXTENTS, PHYSICS_EXTENTS)
	)

func get_input_vector() -> Vector2:
	return Input.get_vector(
		"move_left",
		"move_right",
		"look_down",
		"look_up"
	)
