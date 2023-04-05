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
# Type of polygon (physics, static)
var type : TYPE = TYPE.STATIC

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
	
	# Copy properties over
	collision.polygon = polygon
	add_child(collision)

# Disables temporary polygon
func disable_temporary_polygon() -> void:
	TEMP_POLY.polygon = []
