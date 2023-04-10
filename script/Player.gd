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
@export var GROUND_SPEED  : float     = 17500.0
@export var AIR_SPEED     : float     = 8000.0
@export var JUMP_FORCE    : float     = 2500.0
@export_subgroup("Skeleton")
@export var HEAD_BONE     : Bone2D
@export var JAW_BONE      : Bone2D
@export var FOOT_L        : Marker2D
@export var FOOT_R        : Marker2D
@export var ARM_L         : StretchBone
@export var ARM_R         : StretchBone
@export_subgroup("Timers")
@export var T_BUFFER      : Timer
@export var T_COYOTE      : Timer

# Leg animation variables
const LEG_RADIUS = 19.5
var l_default_pos = [Vector2.ZERO, Vector2.ZERO]

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
	pS.FALL : [pS.IDLE, pS.JUMP]
}

# Current status variables
var floor_normal : Vector2 = Vector2.UP
var p_state      : pS      = pS.IDLE
var velocity     : float   = 0.0
var grabbing     : bool    = false
var jumping      : bool    = false
var buffer       : bool    = false

func _ready() -> void:
	# Get initial positions of feet
	l_default_pos[0] = FOOT_L.position
	l_default_pos[1] = FOOT_R.position

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
			
			# Movement
			velocity = lerp(
				velocity,
				0.0,
				0.1
			)
		pS.MOVE:
			# Transitions
			if !move_direction.x:
				change_state(pS.IDLE)
			elif !on_ground:
				change_state(pS.FALL)
			elif on_ground and Input.is_action_just_pressed("jump"):
				change_state(pS.JUMP)
			
			# Movement
			velocity = lerp(
				velocity,
				move_direction.x * GROUND_SPEED * delta,
				0.1
			)
		pS.JUMP:
			# Transitions
			if state.linear_velocity.y > 0:
				change_state(pS.FALL)
			
			# Movement
			velocity = lerp(
				velocity,
				move_direction.x * AIR_SPEED * delta,
				0.1
			)
		pS.FALL:
			# Transitions
			if Input.is_action_just_pressed("jump"):
				buffer = true
				T_BUFFER.start()
			if on_ground:
				if buffer:
					change_state(pS.JUMP)
				else:
					change_state(pS.IDLE)
			
			# Movement
			velocity = lerp(
				velocity,
				move_direction.x * AIR_SPEED * delta,
				0.1
			)
	
	# Run animation calls
	animate_legs()
	
	# Apply velocity
	state.linear_velocity.x = velocity

# Fired when input buffer times out
func _buffer_timeout():
	buffer = false


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
			jumping = false
			linear_velocity.x = 0
		pS.JUMP:
			jumping = true
			apply_central_impulse(floor_normal * JUMP_FORCE)
		pS.FALL:
			return
		_:
			return

# Animates legs by using sin functions
func animate_legs() -> void:
	# Get movement vector
	var movement_vec = get_movement_vector()
	
	if movement_vec.x:
		# Set leg marker positions
		FOOT_L.position.x = lerp(
			FOOT_L.position.x,
			l_default_pos[0].x + sin(Time.get_ticks_msec() / 80) * LEG_RADIUS,
			0.1
		)
		FOOT_R.position.x = lerp(
			FOOT_R.position.x,
			l_default_pos[1].x + -sin(Time.get_ticks_msec() / 80) * LEG_RADIUS,
			0.1
		)
	else:
		# Set leg marker positions
		FOOT_L.position.x = lerp(
			FOOT_L.position.x,
			l_default_pos[0].x,
			0.2
		)
		FOOT_R.position.x = lerp(
			FOOT_R.position.x,
			l_default_pos[1].x,
			0.2
		)

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
