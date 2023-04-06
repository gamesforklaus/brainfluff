# sound_bus.gd
extends Node

# Handles creation and management
# of sound effects

# List of sounds
var sound_effects = [
	preload("res://snd/addtri.wav"),
	preload("res://snd/commit.wav"),
	preload("res://snd/delete.wav"),
	preload("res://snd/joint.wav"),
	preload("res://snd/plot.wav"),
	preload("res://snd/stamp.wav")
]

# ID enum
enum {
	AddTri,
	Commit,
	Delete,
	Joint,
	Plot,
	Stamp
}

# FUNCTION
#-------------------------------------------------------------------------------

# Creates an audio stream based on ID
func create_global_sound(
	id : int,
	pitch : float
):
	# Establish variables
	var sound = AudioStreamPlayer.new()
	var stream = sound_effects[id]
	
	# Configure audio
	sound.stream      = stream
	sound.pitch_scale = pitch
	
	# Add to scene tree
	get_tree().current_scene.add_child(sound)
	sound.play()
	
	# Cleanup
	await sound.finished
	sound.queue_free()

# Creates a positional audio stream based on ID
func create_2d_sound(
	id : int,
	position : Vector2,
	pitch : float
):
	# Establish variables
	var sound = AudioStreamPlayer2D.new()
	var stream = sound_effects[id]
	
	# Configure audio
	sound.stream          = stream
	sound.pitch_scale     = pitch
	sound.global_position = position
	
	# Add to scene tree
	get_tree().current_scene.add_child(sound)
	sound.play()
	
	# Cleanup
	await sound.finished
	sound.queue_free()
