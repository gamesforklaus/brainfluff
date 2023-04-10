# puppet_mode.gd
extends Node2D

# Handles the spawning and tracking
# of a player character

# Reference to tool manager
@onready var tool_manager : Node = get_parent()
# Reference to mouse overlay
@onready var mouse_overlay : Node2D = get_node("mouse_overlay")
# Nodes to instantiate
@onready var puppet = preload("res://scene/entity/player.tscn")
# Reference to current player
var current_puppet : Puppet = null

func _unhandled_input(event) -> void:
	# Handle puppet spawning
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			spawn_puppet()
	# Handle puppet despawning
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_X:
					despawn_puppet()
	
# FUNCTION
#-------------------------------------------------------------------------------

# Handles spawning of puppet
func spawn_puppet() -> void:
	# Create a new puppet instance if one
	# doesnt already exist
	if current_puppet != null:
		return
	
	current_puppet = puppet.instantiate()
	tool_manager.ENTITY_NODE.add_child(current_puppet)
	current_puppet.global_position = get_global_mouse_position()
	
	# Assign puppet camera as default
	current_puppet.PLAYER_CAM.enabled = true
	tool_manager.CAM_NODE.enabled = false
	
	# Play sound
	SoundBus.create_2d_sound(
		SoundBus.PuppetSpawn,
		current_puppet.global_position,
		randf_range(0.9, 1.2)
	)
	
# Handles despawning of puppet
func despawn_puppet() -> void:
	# If a puppet doesnt exist, abort
	if current_puppet == null:
		return
	
	# Re-enable editor cam
	tool_manager.CAM_NODE.position = current_puppet.global_position
	tool_manager.CAM_NODE.enabled = true
	
	# Bye bye, puppet
	current_puppet.queue_free()
	
	# Play sound
	SoundBus.create_global_sound(
		SoundBus.PuppetRemove,
		randf_range(0.9, 1.2)
	)
