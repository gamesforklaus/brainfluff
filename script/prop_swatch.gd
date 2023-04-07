# prop_swatch.gd
extends Property
class_name ColorProperty

# Swatch property, associated
# with colors.

# Initialization
func _ready():
	# Run init function
	initialize()
	
	# Update value to match config
	var val = Config.get_config_value(TARGET)
	if val == null:
		push_warning("Could not obtain config value! - " + str(self))
		return
	VALUE_NODE.color = val

func _color_changed(color):
	Config.set_config_value(TARGET, color)
