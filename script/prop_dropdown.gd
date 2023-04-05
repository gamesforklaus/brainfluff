# prop_dropdown.gd
extends Property
class_name DropdownProperty

# Dropdown property, usually associated
# with more complex configurations

# Initialization
func _ready():
	# Run init function
	initialize()
	
	# Update value to match config
	var val = get_config_value(TARGET)
	if val == null:
		push_warning("Could not obtain config value! - " + str(self))
		return
	VALUE_NODE.selected = val
