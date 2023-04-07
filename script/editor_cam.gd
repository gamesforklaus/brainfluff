# editor_cam.gd
extends Camera2D
class_name EditorCamera

# Camera used in the editor.

# Fires when an event with the camera
# has occured (e.g. movement, zoom)
signal camera_event()

# Zoom parameters
const ZOOM_INCREMENT : float = 0.1
const ZOOM_MIN       : float = 0.2
const ZOOM_MAX       : float = 5.0
var current_zoom   : float = 1.0

func _unhandled_input(event) -> void:
	# Camera movement
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			global_position -= event.relative / current_zoom
			camera_event.emit()
	# Camera zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_out()
			update_zoom()
			camera_event.emit()

# FUNCTION
#-------------------------------------------------------------------------------

# Handles zooming in
func zoom_in() -> void:
	if current_zoom < ZOOM_MAX:
		current_zoom = current_zoom + ZOOM_INCREMENT

# Handles zooming out
func zoom_out() -> void:
	if current_zoom > ZOOM_MIN:
		current_zoom = current_zoom - ZOOM_INCREMENT

# Updates the camera's zoom
func update_zoom() -> void:
	# Create a tween
	var tween = create_tween()
	tween.stop()
	
	# Tween current zoom to target
	tween.tween_property(
		self,
		"zoom",
		Vector2(current_zoom, current_zoom),
		0.25
	).set_ease(
		Tween.EASE_OUT
	).set_trans(
		Tween.TRANS_BACK
	)
	tween.play()
