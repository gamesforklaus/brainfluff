# config.gd
extends Node

# Holds all configuration options
# for tools.

var config = {
	"vertex" : {
		"h_origin" : true,
		"mode"     : 0,
		"physics"  : true,
		"color"  : 0x0000ff,
	}
}

# FUNCTION
#-------------------------------------------------------------------------------

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
		if config.has(segment):
			conf_value = config.get(segment)
			continue
		if conf_value.has(segment):
			conf_value = conf_value.get(segment)
			continue
	
	# Return value
	return conf_value
	
func set_config_value(key : String, value) -> void:
	# Split string
	var segments = key.split("/")
	
	# Set value
	# (there has to be a better way to do this T-T)
	match len(segments):
		1: config[segments[0]] = value
		2: config[segments[0]][segments[1]] = value
		_: push_error("Invalid key! - \'" + key + "\'")
