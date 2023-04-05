# builder.gd
extends Polygon2D
class_name Builder

# Builds polygons by placing vertices
# where your cursor is at.

# Current array of points
var polyData : PackedVector2Array = []
# Our temp polygon
@onready var tempPoly := $t_p

func _ready():
	pass

func _process(delta):
	# Update the polygon building indicator
	if polyData.size() >= 2:
		update_temp_polygon(polyData)

func _draw():
	draw_points()

# Handles mouse input
func _unhandled_input(event):
	# If a mouse button is pressed
	if event is InputEventMouseButton:
		if event.pressed:
			# Add a new point from position
			add_point()
			build_polygon(polyData)
	# If keyboard button is pressed
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_1:
					reset_polygon()

# FUNCTION
#-------------------------------------------------------------------------------

# Builds a polygon from provided points
func build_polygon(points : Array[Vector2]) -> void:
	# Update current and temp
	set_polygon(points)
	tempPoly.set_polygon(points)

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
	tempPoly.set_polygon(newPoints)

# Grabs mouse position and creates
# point data
func add_point() -> void:
	# Create a position in array
	polyData.append(get_local_mouse_position())

func reset_polygon() -> void:
	# Clear points
	polyData.clear()
	# Reset polygon
	build_polygon(polyData)

func draw_points() -> void:
	var index = 0
	for point in polyData:
		match index:
			0: draw_circle(point, 3, Color.GREEN)
			_: draw_circle(point, 2.5, Color.RED)
		index += 1
