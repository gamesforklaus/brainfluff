# tool.gd
extends Node
class_name ToolManager

# Acts as a reference between
# world nodes and tool nodes

@export_category("ToolManager")
@export var WORLD_NODE     : Node2D
@export var GEOMETRY_NODE  : Node
@export var CONNECTOR_NODE : Node
@export var ENTITY_NODE    : Node
@export var UI_NODE        : CanvasLayer
@export var CAM_NODE       : EditorCamera

# Tool, preferences, and accompanying UI set
var toolset = [
	[   # 0 - Vertex Tool
		preload("res://scene/tools/vertex_tool.tscn"),
		preload("res://scene/tools/conf/vertex_mode.tscn"),
		preload("res://scene/tools/ins/vertex_mode_instructions.tscn")
	],
	[   # 1 - Scribble Tool
		preload("res://scene/tools/vertex_tool.tscn"),
		preload("res://scene/tools/conf/vertex_mode.tscn"),
		preload("res://scene/tools/ins/vertex_mode_instructions.tscn")
	],
	[   # 2 - Polygon Tool
		preload("res://scene/tools/vertex_tool.tscn"),
		preload("res://scene/tools/conf/vertex_mode.tscn"),
		preload("res://scene/tools/ins/vertex_mode_instructions.tscn")
	],
	[   # 3 - Remove Tool
		preload("res://scene/tools/vertex_tool.tscn"),
		preload("res://scene/tools/conf/vertex_mode.tscn"),
		preload("res://scene/tools/ins/vertex_mode_instructions.tscn")
	],
	[   # 4 - Stamper Tool
		preload("res://scene/tools/vertex_tool.tscn"),
		preload("res://scene/tools/conf/vertex_mode.tscn"),
		preload("res://scene/tools/ins/vertex_mode_instructions.tscn")
	],
	[   # 5 - Puppet Tool
		preload("res://scene/tools/puppet_tool.tscn"),
		preload("res://scene/tools/conf/puppet_mode.tscn"),
		preload("res://scene/tools/ins/puppet_mode_instructions.tscn")
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
