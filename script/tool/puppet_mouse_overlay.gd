# puppet_mouse.gd
extends Node2D
class_name PuppetToolMouse

# Handles mouse interactions with
# the puppet mode.

func _process(_delta) -> void:
	animate_overlay(_delta)
	global_position = lerp(
		global_position,
		get_global_mouse_position(),
		0.25
	)

# FUNCTION
#-------------------------------------------------------------------------------

# Animates the puppet overlay
func animate_overlay(delta : float) -> void:
	# Declare variables
	var time = Time.get_ticks_msec()

	# Run animation functions
	animate_glow(time)
	animate_scroll(delta)

# Animates the glow effect
func animate_glow(time : float) -> void:
	modulate.a = absf(sin(time / 500) / 2)

# Animates the scrolling effect
func animate_scroll(delta : float) -> void:
	var polygons = get_children()
	for poly in polygons:
		poly.texture_offset += Vector2(10, 5) * delta
