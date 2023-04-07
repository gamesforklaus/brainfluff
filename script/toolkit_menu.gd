# toolkit_menu.gd
extends ItemList
class_name Toolkit

# Toolkit menu that spawns
# tool nodes

@onready var _root = get_tree().current_scene
@onready var tool_manager = _root.get_node("tool_manager")

# FUNCTION
#-------------------------------------------------------------------------------

func item_clicked(index):
	# Delete existing tool, then add new tool
	tool_manager.delete_tool()
	tool_manager.spawn_tool(index)
	
