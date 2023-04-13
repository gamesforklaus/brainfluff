# bone_stretch.gd
extends Bone2D
class_name StretchBone

# Stretches towards a point.

@export var ENABLED        : bool      = false
@export var X_STRETCH      : bool      = true
@export var Y_STRETCH      : bool      = false
@export var TARGET         : Node
@export var MAXIMUM_LENGTH : float     = 4.0
@export var MINIMUM_LENGTH : float     = 0.2

func _process(_delta) -> void:
	if ENABLED:
		update_stretch()

# FUNCTION
#-------------------------------------------------------------------------------

func get_distance() -> float:
	# Get literal distance and bone length
	var literal = global_position.distance_to(TARGET.global_position)
	var bone_length = get_length()

	# Divide distance by length of bone
	return literal / bone_length

func update_stretch() -> void:
	# Get distance
	var distance = get_distance()

	# Calculate min and max
	if distance >= MAXIMUM_LENGTH:
		distance = MAXIMUM_LENGTH
	if distance <= MINIMUM_LENGTH:
		distance = MINIMUM_LENGTH

	# Set scale
	if X_STRETCH:     scale.x = lerp(scale.x, distance, 0.5)
	if Y_STRETCH:     scale.y = lerp(scale.y, distance, 0.5)
