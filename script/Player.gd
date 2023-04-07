# Player.gd, currently just an example taken off the internet that was slightly edited, 
#but hopefully...
#will evolve into it's own thing.
extends RigidBody2D

var speed = 40
var jump_speed = -10
var gravity = 20

func _physics_process(delta):
	# Input affects x axis only
	linear_velocity.x = Input.get_axis("leftMove", "rightMove") * speed
	
	# Only allow jumping when on the ground
	if Input.is_action_just_pressed("jumpAction"):
		linear_velocity.y = jump_speed
