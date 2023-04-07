# ins_cam_details.gd
extends Inspector

# Regurgitates camera information.

func _ready() -> void:
	TARGET.camera_event.connect(update_camera_details.bind())
	
# FUNCTION
#-------------------------------------------------------------------------------

func update_camera_details() -> void:
	# Declare variables
	var details = "[right] "
	
	# Add position string
	details += (
		"\ncamera position ... x" +
		str(int(TARGET.global_position.x)) +
		".y" +
		str(int(TARGET.global_position.y))
	)
	
	# Add zoom string
	details += (
		"\ncamera zoom ... " +
		str(TARGET.current_zoom)
	)
	
	# Set string
	text = details
