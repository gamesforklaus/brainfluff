# polygon.gd
extends Polygon2D
class_name Polygon

# Holds references to polygon related
# nodes and some special functions.

enum TYPE {
	STATIC,
	PHYSICS,
	REMOVE,
	ADD
}

var COLOR = [
	Color.CORNFLOWER_BLUE,      # 0 - Static
	Color.ORANGE,               # 1 - Physics
	Color.INDIAN_RED,           # 2 - Remove
	Color.LIME_GREEN            # 3 - Add
]

@export_category("Polygon")
@export var TEMP_POLY : Polygon2D

# Reference to collision polygon
var collision = null
# Reference to rigid body
@onready var physics_body = get_parent()
# Type of polygon (physics, static)
var type : TYPE = TYPE.STATIC

func _ready() -> void:
	# Set color
	set_color(COLOR[type])

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
	
	# Cut depending on mode
	if type == TYPE.REMOVE:
		cut_polygons()
		
	# Add depending on mode
	if type == TYPE.ADD:
		add_polygons()

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

# Cuts into other existing polygons
func cut_polygon(target : PackedVector2Array) -> PackedVector2Array:
	# Calculate new polygon data
	var new_poly = Geometry2D.clip_polygons(target, polygon)
	
	match new_poly.size():
		0:
			push_warning("No polygon to cut.")
			return []
		1:
			return new_poly[0]
		2:
			push_warning("Polygon cannot have internal opening!")
			return new_poly[0]
		_:
			print(new_poly.size())
			print(new_poly)
			push_warning("Something wrong happened.")
			return []

func add_polygon(target : PackedVector2Array) -> PackedVector2Array:
	# Calculate new polygon data
	var new_poly = Geometry2D.merge_polygons(target, polygon)
	
	match new_poly.size():
		0:
			push_warning("No polygon to add to.")
			return []
		1:
			return new_poly[0]
		2:
			push_warning("Polygon cannot have internal opening!")
			return new_poly[0]
		_:
			print(new_poly.size())
			print(new_poly)
			push_warning("Something wrong happened.")
			return []

# Gets overlapping polygons.
func get_overlapping_polygons() -> Array[Polygon]:
	# Create a new area body
	var area = Area2D.new()
	var area_col = collision.duplicate(DUPLICATE_USE_INSTANTIATION)
	
	# Add to scene
	area.add_child(area_col)
	physics_body.add_child(area)
	
	# We need to wait a physics frame in order
	# for the area node to update. Shitty.
	await area.body_entered
	
	# Get overlapping polygons
	var polys : Array[Polygon] = []
	var nodes = area.get_overlapping_bodies()
	for node in nodes:
		if node == physics_body:
			continue
		var node_children = node.get_children()
		for poly in node_children:
			if poly is Polygon:
				polys.append(poly)
	
	print(area.get_overlapping_bodies())
	
	return polys

# Goes through a list of polygons and
# cuts each
func cut_polygons() -> void:
	# Get overlapping polys
	var poly_list = await get_overlapping_polygons()
	
	# Error catching
	if poly_list.size() == 0:
		physics_body.queue_free()
		return
	
	# Iterate through polygons
	for poly in poly_list:
		# Remove existing collision
		poly.collision.queue_free()
		poly.collision = null
		
		# Cut into polygon
		poly.polygon = cut_polygon(poly.polygon)
		
		# Recenter polygon
		poly.recenter()
		poly.call_deferred("prepare_commit")
	
	# Delete self
	await get_tree().physics_frame
	physics_body.queue_free()

func recenter() -> void:
	var center = grab_median()
	physics_body.global_position = center
	offset = -center

# Disables temporary polygon
func disable_temporary_polygon() -> void:
	TEMP_POLY.polygon = []

func add_polygons() -> void:
	# Get overlapping polys
	var poly_list = await get_overlapping_polygons()
	
	# Error catching
	if poly_list.size() == 0:
		physics_body.queue_free()
		return
	
	# Iterate through polygons
	for poly in poly_list:
		# Remove existing collision
		poly.collision.queue_free()
		poly.collision = null
		
		# Add polygon
		poly.polygon = add_polygon(poly.polygon)
		
		# Recenter polygon
		poly.recenter()
		poly.call_deferred("prepare_commit")
	
	# Delete self
	await get_tree().physics_frame
	physics_body.queue_free()
