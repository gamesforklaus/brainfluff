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

func get_config_value(key : String):
	# Split string
	var segments = key.split("/", false)
	
	# Error catching
	if segments == null:
		push_warning("Could not find config! - " + str(self))
		return
	
	# Get config value
	var conf_value
	for segment in segments:
		print(segment)
		if Config.config.has(segment):
			conf_value = Config.config.get(segment)
			continue
		if conf_value.has(segment):
			conf_value = conf_value.get(segment)
			continue
	
	# Return value
	return conf_value
	
func set_config_value(key : String, value) -> void:
	# Split string
	var segments = key.split("/")
	
	# Set config value
	var conf_value
	for segment in segments:
		if Config.config.has(segment):
			conf_value = Config.config.get(segment)
