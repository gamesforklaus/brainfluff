# polygon.gd
extends Polygon2D
class_name Polygon

# Holds references to polygon related
# nodes and some special functions.

enum TYPE {
	STATIC,
	PHYSICS
}

@export_category("Polygon")
@export var TEMP_POLY : Polygon2D

# Reference to collision polygon
var collision = null
# Reference to rigid body
@onready var physics_body = get_parent()
# Type of polygon (physics, static)
var type : TYPE = TYPE.STATIC

func _ready() -> void:
	set_color(Color.ORANGE if type == TYPE.PHYSICS else Color.CORNFLOWER_BLUE)

# FUNCTION
#-------------------------------------------------------------------------------

# Prepares for commit
func prepare_commit() -> void:
	build_collision()			# First, build collision
	disable_temporary_polygon() # Then, disable temporary polygon

# (Re)Builds collision
func build_collision() -> void:
	# Create a new collision node if one doesnt exist
	if collision == null:
		collision = CollisionPolygon2D.new()
	
	# Create a new physics body, if one doesnt exist
#	if physics_body == null && type == TYPE.PHYSICS:
#		physics_body = RigidBody2D.new()
#	else:
#		physics_body = StaticBody2D.new()
	
	# Copy properties over
	collision.polygon = polygon
	physics_body.add_child(collision)
	#add_child(physics_body)
	#collision.reparent(physics_body)

# Disables temporary polygon
func disable_temporary_polygon() -> void:
	TEMP_POLY.polygon = []
