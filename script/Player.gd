# player.gd
extends RigidBody2D
class_name Puppet

# Handles puppet information.

'''important'''
# For those who this may concern, this is UNFINISHED!
# There are various steps that must be taken before
# this component of Brainfluff can be considered
# feature complete, such as:
#
#   X Movement 
#   * Grabbing
#   * Gyroscope-type player rotation            (seen in Yellowhead footage)
#   * Player-tilt affecting gravitational force (seen in Yellowhead footage)
#	X Godo skeletal rig
#   * Inverse kinematic system                  (seen in Yellowhead footage)
#		X Stretchy arm IK
#		* Legs -> Ground IK

@export_category("Puppet")
@export_subgroup("Attributes")
@export var GROUND_SPEED  : float     = 27500.0
@export var AIR_SPEED     : float     = 8000.0
@export var JUMP_FORCE    : float     = 2500.0
@export_subgroup("Nodes")
@export var HEAD_BONE     : Bone2D
@export var JAW_BONE      : Bone2D
@export var FOOT_L        : RayCast2D
@export var FOOT_R        : RayCast2D
@export var ARM_L         : StretchBone
@export var ARM_R         : StretchBone

# Player states
enum pS {
	IDLE,
	MOVE,
	JUMP,
	FALL
}

# Transition set
var trans = {
	pS.IDLE : [pS.MOVE, pS.JUMP, pS.FALL],
	pS.MOVE : [pS.IDLE, pS.JUMP, pS.FALL],
	pS.JUMP : [pS.FALL],
	pS.FALL : [pS.IDLE]
}

# Current status variables
var floor_normal : Vector2 = Vector2.UP
var p_state      : pS      = pS.IDLE
var velocity     : Vector2 = Vector2.ZERO
var grabbing     : bool    = false

func _integrate_forces(state : PhysicsDirectBodyState2D) -> void:
	# Declare variables
	var on_ground = is_on_ground(state)
	var move_direction = get_movement_vector()
	var delta = state.get_step()
	
	# State machine
	match p_state:
		pS.IDLE:
			# Transitions
			if move_direction.x:
				change_state(pS.MOVE)
			elif on_ground and Input.is_action_just_pressed("jump"):
				change_state(pS.JUMP)
		pS.MOVE:
			# Transitions
			if !move_direction.x:
				change_state(pS.IDLE)
			elif !on_ground:
				change_state(pS.FALL)
			elif on_ground and Input.is_action_just_pressed("jump"):
				change_state(pS.JUMP)
			
			# Movement
			state.linear_velocity.x = lerp(
				state.linear_velocity.x,
				move_direction.x * GROUND_SPEED * delta,
				0.1
			)
# FUNCTION
#-------------------------------------------------------------------------------

# Checks to see if a transition can occur,
# then transitions into state
func change_state(target : pS) -> void:
	if not target in trans[p_state]:
		return
	initialize_state(target)

# Handles initial calls when changing states
func initialize_state(target : pS) -> void:
	p_state = target
	match target:
		pS.IDLE:
			linear_velocity.x = 0
		pS.JUMP:
			apply_central_impulse(floor_normal * JUMP_FORCE)
		pS.FALL:
			return
		_:
			return

# Returns a movement vector
func get_movement_vector() -> Vector2:
	return Input.get_vector(
		"move_left", 
		"move_right", 
		"look_down", 
		"look_up"
	)

# Returns whether or not a player is touching ground
func is_on_ground(state : PhysicsDirectBodyState2D) -> bool:
	return (
		state.get_contact_count() > 0 and
		int(state.get_contact_collider_position(0).y) >= int(global_position.y)
	)
