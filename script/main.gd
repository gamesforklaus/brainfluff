# main.gd
extends Node

# Window nodes
var windows = [
	preload("res://scene/tools.tscn"),
	preload("res://scene/tool_options.tscn")
]

# References
var tool_window          = null
var tool_options_window  = null

# Window offsets
const TOOL      = Vector2i(-262, 0)
const T_OPTIONS = Vector2i(-262, 242)

# Initialization
func _ready() -> void:
	instance_windows()

# FUNCTION
#-------------------------------------------------------------------------------

# Instances various windows
func instance_windows() -> void:
	var index = 0
	for w in windows:
		# Instance
		var i = w.instantiate()
		
		# Reposition and reference
		i.position = get_window().position
		match index:
			0:
				i.position += TOOL
				tool_window = i
			1:
				i.position += T_OPTIONS
				tool_options_window = i
		
		# Add to scene tree
		add_child(i)
		
		# Advance index
		index += 1
