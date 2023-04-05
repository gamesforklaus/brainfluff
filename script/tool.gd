# tool.gd
extends Node
class_name ToolManager

# Acts as a reference between
# world nodes and tool nodes

@export_category("ToolManager")
@export var WORLD_NODE : Node2D
@export var GEOMETRY_NODE : Node
@export var CONNECTOR_NODE : Node
