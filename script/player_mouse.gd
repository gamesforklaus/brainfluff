# player_mouse.gd
extends Marker2D

# Basic script that updates self
# position to the mouse position

func _process(_delta) -> void:
	global_position = get_global_mouse_position()
