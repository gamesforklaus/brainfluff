# vertex_mode.gd
extends Node2D

# Creates and manages polygons and
# vertex plotting

# Reference to tool manager
@onready var tool_manager : Node = get_parent()
# Current polygon
var current_polygon : Polygon2D = null
# Current polygon body
var current_body = null
# Current array of points
var cpolygon_data : PackedVector2Array = []
# Polygon to instantiate
@onready var poly = preload("res://scene/poly.tscn")
@onready var mat = preload("res://scene/phys_material.tres")

func _ready():
	pass

func _process(delta):
	# Update the polygon building indicator
	if cpolygon_data.size() >= 2:
		update_temp_polygon(cpolygon_data)

func _draw():
	draw_points()

# Handles mouse input
func _unhandled_input(event):
	# If a mouse button is pressed
	if event is InputEventMouseButton:
		if event.pressed:
			# Add a new point from position
			add_point()
			build_polygon(cpolygon_data)
			#recenter()
	# If keyboard button is pressed
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_Z:
					commit_polygon()
				KEY_X:
					clear_polygon()

# FUNCTION
#-------------------------------------------------------------------------------

# Builds a polygon from provided points
func build_polygon(points : Array[Vector2]) -> void:
	# Create polygon if one doesnt exist
	if current_polygon == null:
		# Declare variables
		var type = Config.get_config_value("vertex/physics")
		
		# Instance and configure polygon
		current_polygon = poly.instantiate()
		current_polygon.type = current_polygon.TYPE.PHYSICS if Config.get_config_value(
			"vertex/physics") else current_polygon.TYPE.STATIC
		
		# Add physics type
		if type:
			current_body = RigidBody2D.new()
			current_body.physics_material_override = mat
			current_body.center_of_mass_mode = 1
		else:
			current_body = StaticBody2D.new()
		
		current_body.process_mode = PROCESS_MODE_DISABLED
		tool_manager.GEOMETRY_NODE.add_child(current_body)
		current_body.add_child(current_polygon)
	
	# Update polygons if they exist
	current_polygon.set_polygon(points)
	current_polygon.TEMP_POLY.set_polygon(points)
	
	# Update center of mass
	#if current_body is RigidBody2D:
	#	current_body.center_of_mass = grab_median()

# Updates the polygon building overlay
func update_temp_polygon(points : Array[Vector2]) -> void:
	# Create variables
	var tempPoints : PackedVector2Array = points
	var newPoints  : PackedVector2Array
	var origin = tempPoints[0]
	var mousePos = get_local_mouse_position()
	
	# Create temporary polygon
	newPoints.push_back(origin)
	newPoints.append(tempPoints[tempPoints.size()-1])
	newPoints.append(mousePos)
	current_polygon.TEMP_POLY.set_polygon(newPoints)

# Deletes currently drawn polygon
func clear_polygon() -> void:
	# See if a polygon exists
	if current_polygon == null:
		push_warning("Cannot remove polygon - Does not exist.")
		return
	# Clear points and delete polygon
	cpolygon_data.clear()
	current_body.queue_free()
	# Redraw
	queue_redraw()

# "Finishes" current polygon
func commit_polygon() -> void:
	# Recenter physics body and polygon
	var old_pos = current_polygon.global_position
	var center = current_polygon.grab_median()
	current_body.global_position = center
	current_polygon.position -= center
	
	# Prepare polygon for commit
	current_body.process_mode = Node.PROCESS_MODE_INHERIT
	current_polygon.prepare_commit()
	# Remove polygon from current
	current_polygon = null
	current_body = null
	cpolygon_data = []

# Grabs mouse position and creates
# point data
func add_point() -> void:
	# Create a position in array
	cpolygon_data.append(get_local_mouse_position())
	queue_redraw()

# Calculates mass based on polygon size
func calculate_mass() -> float:
	return 0.0

func draw_points() -> void:
	var polygons = tool_manager.GEOMETRY_NODE.get_children()
	var index = 0
	
	for polygon in polygons:
		# Verify it's a polygon
		if polygon is Polygon:
			# Iterate through vertices
			index = 0
			for point in polygon.polygon:
				match index:
					0: draw_circle(point, 3, Color.GREEN)
					_: draw_circle(point, 2.5, Color.RED)
				index += 1
