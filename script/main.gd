# main.gd
extends Node

# Window nodes
var windows = [
	preload("res://scene/tools.tscn"),
	preload("res://scene/tool_options.tscn")
]

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
		
		# Reposition
		i.position = get_window().position
		match index:
			0:		i.position += TOOL
			1:		i.position += T_OPTIONS
		
		# Add to scene tree
		add_child(i)
		
		# Advance index
		index += 1
