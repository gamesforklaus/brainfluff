# prop_button.gd
extends Property
class_name ToggleProperty

# Toggle property, usually associated with
# boolean / binary values

# Initialization
func _ready():
	# Run init function
	initialize()
	
	# Update value to match config
	var val = get_config_value(TARGET)
	if val == null:
		push_warning("Could not obtain config value! - " + str(self))
		return
	VALUE_NODE.button_pressed = val

# Updates global config
func _toggled(button_pressed) -> void:
	pass # Replace with function body.
