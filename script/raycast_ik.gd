# raycast_ik
extends RayCast2D

# Automatically updates child
# to be positioned at raycast collision point.

@export var HIT_NODE : Marker2D
@onready var ORIGIN = HIT_NODE.global_position

func _process(_delta) -> void:
	if get_collider():
		HIT_NODE.global_position = get_collision_point()
	else:
		HIT_NODE.global_position = ORIGIN
