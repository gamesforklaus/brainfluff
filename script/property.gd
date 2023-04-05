# property.gd
extends Control
class_name Property

# Stores a name and description
# for a property.

@export_category("Property")
@export_subgroup("Nodes")
@export var NAME_NODE  : Control
@export var VALUE_NODE : Control
@export_subgroup("Information")
@export var NAME       : String = "Property Name"
@export var TARGET     : String = "property"
@export_multiline var DESCRIPTION : String = "This is a description."

func initialize() -> void:
	# Set name
	NAME_NODE.set_text(NAME)
	
	# Initialize tooltip texts in self and children
	tooltip_text = DESCRIPTION
	NAME_NODE.tooltip_text = DESCRIPTION
	VALUE_NODE.tooltip_text = DESCRIPTION
