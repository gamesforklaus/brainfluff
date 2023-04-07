# tool.gd
extends Node
class_name ToolManager

# Acts as a reference between
# world nodes and tool nodes

@export_category("ToolManager")
@export var WORLD_NODE     : Node2D
@export var GEOMETRY_NODE  : Node
@export var CONNECTOR_NODE : Node
@export var UI_NODE        : CanvasLayer

# Tool, preferences, and accompanying UI set
var toolset = [
	[
		preload("res://scene/tools/vertex_tool.tscn"),
		preload("res://scene/vertex_mode.tscn"),
		preload("res://scene/tools/ins/vertex_mode_instructions.tscn")
	],
]

# Current tool
var current_tool = null
# Current configuration
var current_config = null
# Current UI set
var current_UI_set = null

# FUNCTION
#-------------------------------------------------------------------------------

# Creates a toolset based on ID.
func spawn_tool(id : int) -> void:
	# Instantiate toolset
	var tool = toolset[id][0].instantiate()
	var conf = toolset[id][1].instantiate()
	var hint = toolset[id][2].instantiate()
	
	# Set references
	current_tool = tool
	current_config = conf
	current_UI_set = hint
	
	# Spawn in world
	Main.tool_options_window.add_child(conf)
	add_child(tool)
	UI_NODE.add_child(hint)

func delete_tool() -> void:
	# Delete tools, if null
	if current_tool != null:       current_tool.queue_free()
	if current_config != null:     current_config.queue_free()
	if current_UI_set != null:     current_UI_set.queue_free()
