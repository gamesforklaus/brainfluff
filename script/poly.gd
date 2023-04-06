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

	# Calculate collision
	collision.polygon = offset_polygon(grab_median())
	
	# If collision triangulation fails, we have a bad polygon
	if Geometry2D.triangulate_polygon(collision.polygon).is_empty():
		physics_body.queue_free()
		return
	
	# If collision decomposition fails, we also have a bad polygon
	if Geometry2D.decompose_polygon_in_convex(collision.polygon).is_empty():
		physics_body.queue_free()
		return
		
	# Add collision to body
	physics_body.add_child(collision)

# Offsets vertices in a polygon by a certain amount
func offset_polygon(center : Vector2) -> PackedVector2Array:
	var new_points = []
	for point in polygon:
		new_points.append(point - center)
	return new_points

# Recenters physic body to the median
# of the polygon
func grab_median() -> Vector2:
	# Prepare for recenter
	var median = polygon.size()
	var pos = Vector2.ZERO
	
	# Recenter
	for point in polygon:
		pos += point / median
	return pos

# Disables temporary polygon
func disable_temporary_polygon() -> void:
	TEMP_POLY.polygon = []
