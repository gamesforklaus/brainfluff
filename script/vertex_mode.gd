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
# Nodes to instantiate
@onready var poly = preload("res://scene/poly.tscn")
@onready var mat = preload("res://scene/phys_material.tres")

func _ready():
	pass

func _process(_delta):
	# Update the polygon building indicator
	if cpolygon_data.size() >= 2:
		update_temp_polygon(cpolygon_data)

func _draw():
	draw_points()

# Handles mouse input
func _unhandled_input(event):
	# If a mouse button is pressed
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			# Add a new point from position
			add_point()
			build_polygon(cpolygon_data)
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
		var mode = Config.get_config_value("vertex/mode")
		
		# Instance and configure polygon
		current_polygon = poly.instantiate()
		match mode:
			0:          # Build
				match type:
					true:
						current_polygon.type = current_polygon.TYPE.PHYSICS
					false:
						current_polygon.type = current_polygon.TYPE.STATIC
			1:          # Cut
				current_polygon.type = current_polygon.TYPE.REMOVE
			2:          # Intersect
				pass
		
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
	

# Updates the polygon building overlay
func update_temp_polygon(points : Array[Vector2]) -> void:
	# Create variables
	var tempPoints : PackedVector2Array = points
	var newPoints  : PackedVector2Array = []
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
	
	# Play delete sound
	SoundBus.create_global_sound(SoundBus.Delete, randf_range(0.8,1.2))
	
	# Redraw
	queue_redraw()

# "Finishes" current polygon
func commit_polygon() -> void:
	# Verify polygon exists
	if current_polygon == null:
		push_warning("Cannot commit polygon - Does not exist.")
		return
		
	# Recenter physics body and polygon
	current_polygon.recenter()
	
	# Spawn commit sound
	SoundBus.create_global_sound(SoundBus.Commit, randf_range(0.8,1.2))
	
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
	
	# Spawn plot sound
	SoundBus.create_global_sound(SoundBus.Plot, randf_range(0.8,1.2))
	queue_redraw()

# Calculates mass based on polygon size
func calculate_mass() -> float:
	return 0.0

'''bug'''
# Supposed to draw points, currently broken
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
