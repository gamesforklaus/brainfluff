# bone_bobble.gd
extends Line2D
class_name StretchLine2D

# Stretches self between two points

@export var ENABLED          : bool      = true
@export var TARGET_1         : Node2D
@export var TARGET_2         : Node2D
@export var OFFSET_1         : Vector2   = Vector2.ZERO
@export var OFFSET_2         : Vector2   = Vector2.ZERO

func _process(_delta) -> void:
	set_point_position(0, TARGET_1.position + OFFSET_1)
	set_point_position(1, TARGET_2.position + OFFSET_2)

# FUNCTION
#-------------------------------------------------------------------------------
