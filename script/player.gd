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
#   X Gyroscope-type player rotation            (seen in Yellowhead footage)
#   * Player-tilt affecting gravitational force (seen in Yellowhead footage)
#	X Godo skeletal rig
#   X Inverse kinematic system                  (seen in Yellowhead footage)
#		X Stretchy arm IK
#		X Legs -> Ground IK

@export_category("Puppet")
@export_subgroup("Attributes")
@export var GROUND_SPEED  : float     = 17500.0
@export var AIR_SPEED     : float     = 8000.0
@export var JUMP_FORCE    : float     = 2500.0
@export_subgroup("Cameras")
@export var PLAYER_CAM    : Camera2D
@export_subgroup("Raycasts")
@export var FOOT_RAYCAST_L: RayCast2D
@export var FOOT_RAYCAST_R: RayCast2D
@export var GYROSCOPE     : RayCast2D
@export_subgroup("IK Controllers")
@export var BODY          : Node2D
@export var FOOT_L        : Marker2D
@export var FOOT_R        : Marker2D
@export var HAND_L        : Marker2D
@export var HAND_R        : Marker2D
@export_subgroup("Timers")
@export var T_BUFFER      : Timer
@export var T_COYOTE      : Timer

# Animation variables
const LEG_RADIUS = 8
const HAND_RADIUS = 5
var l_default_pos = [Vector2.ZERO, Vector2.ZERO]
var h_default_pos = [Vector2.ZERO, Vector2.ZERO]
var l_target_pos  = [Vector2.ZERO, Vector2.ZERO]
var h_target_pos  = [Vector2.ZERO, Vector2.ZERO]

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
	# ...then hands
	h_default_pos[0] = HAND_L.position
	h_default_pos[1] = HAND_R.position

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
				
			# Animate
			ani_legs_idle()
			
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
			
			# Animate
			ani_legs_walking()
			
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
			
			# Animate
			ani_legs_air()
			
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
			
			# Animate
			ani_legs_air()
			
			# Movement
			velocity = lerp(
				velocity,
				move_direction.x * AIR_SPEED * delta,
				0.1
			)

	# Run global animation calls
	position_feet()
	calculate_gyro()

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
		int(state.get_contact_collider_position(0).y) >= int(global_position.y - 5)
	)

# Adjusts player rotation according to floor normal
func calculate_gyro() -> void:
	# Declare variables
	var target = PI/25 * get_movement_vector().x
	
	# Slowly return to a target of PI/2 if
	# no collider is found
	if !GYROSCOPE.get_collider():
		BODY.rotation = lerp_angle(
			BODY.rotation,
			target,
			0.05
		)
		return
	
	# Set rotation according to floor normal
	target = PI/2 + GYROSCOPE.get_collision_normal().angle()
	BODY.rotation = lerp_angle(
		BODY.rotation,
		target,
		0.1
	)

# ANIMATION
#-------------------------------------------------------------------------------

# Sets idle position for legs
func ani_legs_idle() -> void:
	# Interpolate to defaults
	l_target_pos[0] = lerp(
			l_target_pos[0],
			l_default_pos[0],
			.1
		)
	l_target_pos[1] = lerp(
		l_target_pos[1],
		l_default_pos[1],
		.1
	)

# Sets walking positions for legs
func ani_legs_walking() -> void:
	# Get movement vector
	var movement_vec = get_movement_vector()
	
	# Set leg marker positions
	l_target_pos[0] = lerp(
		l_target_pos[0],
		calculate_anim_position(l_default_pos[0], LEG_RADIUS),
		.5
	)
	l_target_pos[1] = lerp(
		l_target_pos[1],
		calculate_anim_position(l_default_pos[1], LEG_RADIUS, -100),
		.5
	)

# Sets air-borne positions for legs
func ani_legs_air() -> void:
	# Declare variables
	var air_velocity = linear_velocity.y
	var factor : float
	var y_offset : float
	
	# Calculate factors based on air velocity
	# direction; moving up moves legs inward,
	# moving down moves legs outward
	air_velocity = clamp(air_velocity / 500.0, -1.0, 1.0)
	factor = 4 * absf(air_velocity)
	y_offset = 10 * abs(air_velocity)
	
	# Set leg marker positions
	l_target_pos[0] = lerp(
		l_target_pos[0],
		l_default_pos[0] * factor + Vector2(0, y_offset),
		.25
	)
	l_target_pos[1] = lerp(
		l_target_pos[1],
		l_default_pos[1] * factor + Vector2(0, y_offset),
		.25
	)

# Calculates animation positions
func calculate_anim_position(origin : Vector2, radius : float, offset : float = 0) -> Vector2:
	# Get values
	var time = Time.get_ticks_msec()
	var vec  = get_movement_vector().x
	
	return Vector2(
		(origin.x + sin((time + offset) / 50.0) * vec * radius),
		(-origin.y + cos((time + offset) / 50.0) * vec * radius)
	)

# Handles feet IK points
func position_feet() -> void:
	# Declare variables
	var colliders = [
		FOOT_RAYCAST_L.HIT_NODE.position,
		FOOT_RAYCAST_R.HIT_NODE.position,
	]
	
	# If the colliders have collision point data,
	# set feet IK positions to the highest point
	# between animation position and collision
	# position
	
	FOOT_L.position = l_target_pos[0]
	if FOOT_RAYCAST_L.get_collider():
		if colliders[0].y < FOOT_L.position.y:
			FOOT_L.position.y = colliders[0].y
	
	FOOT_R.position = l_target_pos[1]
	if FOOT_RAYCAST_R.get_collider():
		if colliders[1].y < FOOT_R.position.y:
			FOOT_R.position.y = colliders[1].y
