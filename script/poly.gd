# polygon.gd
extends Polygon2D
class_name Polygon

# Holds references to polygon related
# nodes and some special functions.

enum TYPE {
	STATIC,
	PHYSICS,
	REMOVE,
}

var COLOR = [
	Color.CORNFLOWER_BLUE,      # 0 - Static
	Color.ORANGE,               # 1 - Physics
	Color.INDIAN_RED,           # 2 - Remove
]

@export_category("Polygon")
@export var TEMP_POLY : Polygon2D
@export var POLY_LINE : Line2D

# Reference to rigid body
@onready var physics_body = get_parent()
# Reference to collision polygon
var collision                    = null
# Type of polygon (physics, static)
var type                  : TYPE = TYPE.STATIC
# The current mode of the polygon
var is_editing            : bool = true

func _ready() -> void:
	# Prepare polygon color
	var custom_color = Config.get_config_value("vertex/visual/use_color")
	if custom_color:
		# Set custom color
		set_color(Config.get_config_value("vertex/visual/color"))
	else:
		# Set color
		set_color(COLOR[type])

	# Prepare outline color
	var outline_color = Config.get_config_value("vertex/outline/use_color")
	if outline_color:
		POLY_LINE.default_color = Config.get_config_value("vertex/outline/color")
	else:
		POLY_LINE.default_color = color

	# Prepare outline texture
	var outline_type = Config.get_config_value("vertex/outline/line_tex")
	match outline_type:
		0:     POLY_LINE.visible = false
		1:     POLY_LINE.texture = load("res://gfx/line/default.svg")
		2:     POLY_LINE.texture = load("res://gfx/line/smooth.svg")
		3:     POLY_LINE.texture = load("res://gfx/line/rugged.svg")
		4:     POLY_LINE.texture = load("res://gfx/line/fuzzy.svg")
		5:     POLY_LINE.texture = load("res://gfx/line/puffy.svg")

func _process(_delta : float) -> void:
	if is_editing:
		animate_hatch(_delta, Time.get_ticks_msec())

# FUNCTION
#-------------------------------------------------------------------------------

# Prepares for commit
func prepare_commit() -> void:
	build_collision()			# First, build collision
	disable_temporary_polygon() # Then, disable temporary polygon
	disable_hatch()             # Finally, clear texture
	is_editing = false          # Mark editing as complete

# (Re)Builds collision
func build_collision() -> void:
	# Create a new collision node if one doesnt exist
	if collision == null:
		collision = CollisionPolygon2D.new()

	# Calculate collision
	collision.polygon = offset_polygon(grab_median())

	# If collision triangulation fails, we have a bad polygon
	if Geometry2D.triangulate_polygon(collision.polygon).is_empty():
		push_warning("Bad triangulation! - " + str(self))
		physics_body.queue_free()
		return

	# If collision decomposition fails, we also have a bad polygon
	if Geometry2D.decompose_polygon_in_convex(collision.polygon).is_empty():
		push_warning("Bad decompisition! - " + str(self))
		physics_body.queue_free()
		return

	# Perform CSG operation if needed
	if type != TYPE.PHYSICS:
		csg_operation()

	# Add collision to body
	physics_body.add_child(collision)

	# Generate outline
	generate_outline()

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
		_:
			push_warning("Polygon cannot have internal opening!")
			return new_poly[0]

func add_polygon(
	targetA : PackedVector2Array,
	targetB : PackedVector2Array) -> PackedVector2Array:
	# Calculate new polygon data
	var new_poly = Geometry2D.merge_polygons(targetB, targetA)

	match new_poly.size():
		0:
			push_warning("No polygon to add to.")
			return []
		1:
			return new_poly[0]
		_:
			push_warning("Polygon cannot have internal opening!")
			return new_poly[0]

# Creates an area body based on existing collision
func create_area() -> Area2D:
	# Create a new area body
	var area = Area2D.new()
	var area_col = collision.duplicate()

	# Add to scene
	area.add_child(area_col)
	physics_body.add_child(area)
	return area

# Gets overlapping polygons.
func get_overlapping_polygons(area : Area2D) -> Array[Polygon]:
	# Get overlapping polygons
	var polys : Array[Polygon] = []
	for bodies in area.get_overlapping_bodies():
		# Check for self
		if bodies == physics_body:
			break

		# Check for rigid body
		if bodies is RigidBody2D:
			print("phys")
			break

		var node_children = bodies.get_children()
		for poly in node_children:
			if poly is Polygon:
				polys.append(poly)

	return polys

# Goes through a list of polygons and performs
# a csg operation.
func csg_operation() -> void:
	# Create new area
	var area = create_area()
	'''refactor'''
	# The area node needs two physics frames
	# in order to update it's overlapping bodies.
	# This is a godot limitation, but there has
	# to be a cleaner work-around.
	await get_tree().physics_frame
	await get_tree().physics_frame
	# Get a list of overlapping polygons.
	var poly_list = get_overlapping_polygons(area)

	# Error catching
	if poly_list.size() == 0:
		# Depending on type, either
		# a) delete polygon
		# b) create a new polygon
		match type:
			TYPE.STATIC:
				area.queue_free()
				return
			_:
				physics_body.queue_free()

	# Iterate through polygons
	var index : int = 1
	var new_poly : PackedVector2Array = []

	for poly in poly_list:
		# Remove existing collision
		poly.collision.queue_free()
		poly.collision = null

		# Perform operation
		match type:
			TYPE.REMOVE:
				# Cut into existing polygon
				poly.polygon = cut_polygon(poly.polygon)
			TYPE.STATIC:
				# Create a new polygon, remove other overlapping ones
				new_poly = add_polygon(polygon, poly.polygon)
				polygon = new_poly

				# Add polygon data to last polygon,
				# otherwise remove polygon
				if index == poly_list.size():
					poly.set_polygon(polygon)
				else:
					poly.physics_body.queue_free()

		# Recenter polygon
		poly.recenter()
		poly.call_deferred("prepare_commit")

		# Increment
		index += 1

	# Perform cleanup operation
	physics_body.queue_free()

func recenter() -> void:
	var center = grab_median()
	physics_body.global_position = center
	offset = -center

# Disables temporary polygon
func disable_temporary_polygon() -> void:
	TEMP_POLY.polygon = []

# Animates hatch texture
func animate_hatch(delta : float, time : float) -> void:
	# Modulate visibility
	self_modulate.a = absf(sin(time / 500) / 2)
	# Scroll tex
	texture_offset += Vector2(10, 5) * delta

# Disables the hatch texture on the polygon
func disable_hatch() -> void:
	texture = null
	self_modulate.a = 1.0

# Enables the hatch texture on the polygon
func enable_hatch() -> void:
	texture = load("res://gfx/ui/hatch.png")

# Generates outline
func generate_outline() -> void:
	# Clear existing outline
	POLY_LINE.clear_points()

	# Add points based on polygon
	for point in polygon:
		POLY_LINE.add_point(point + offset)

	# Cap off
	POLY_LINE.add_point(POLY_LINE.points[0])
