extends CharacterBody3D

# Indicates whether the character is controlled by AI.
@export var ai = false
# Holds the position of the character for network synchronization.
@export var _position = Vector3.ZERO
# Base movement speed of the character.
var speed = 3.0
# Defines the initial upward velocity during a jump.
const JUMP_VELOCITY = 20.0
# Defines the strength of gravity applied to the character.
var gravity = -100
# Represents the movement direction vector.
var direction := Vector3(0.0,0.0,0.0)
# Tracks whether the character is currently jumping.
var jumping := false

# The AI's target position to move towards.
var target := Vector3(0.0,0.0,0.0)
# Keeps track of the character's last position.
var last_position := Vector3(0.0,0.0,0.0)
# A timer for managing AI movement and target changes.
var move_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the character's position.
	_position = position
	
	# Adjust AI character speed and mesh if controlled by AI.
	if ai:
		speed *= 0.2
		$MeshInstance3D.mesh = PrismMesh.new()
		move_timer = Time.get_ticks_msec()

# Called every frame with the 'delta' variable being the elapsed time since the previous call.
# This function handles AI logic, player input and multiplayer synchronization.
func _physics_process(delta):
	# Temporary variables for player identification.
	var _name = str(name)
	var _peer_id = str(multiplayer.get_unique_id())
	var is_player = _name == _peer_id
	
	# AI logic: Determines how the AI character moves and when it targets a new position.
	if ai and multiplayer.is_server():
		# Move the AI character towards its target or assign a new target after 5 seconds or if close enough to the current target.
		if target.distance_to(position) < 1 or Time.get_ticks_msec() - move_timer > 5000:
			target = Vector3(randf_range(-5, 5), position.y, randf_range(-5, 5))
			move_timer = Time.get_ticks_msec()
		
		# Set the movement direction towards the target.
		direction = (target - position).normalized()
		# Randomly decide if the AI should jump.
		if is_on_floor() and randi() % 100 == 1:
			velocity.y = JUMP_VELOCITY
		# Apply movement for the AI-controlled character.
		apply_movement(delta, is_player)
		return
	
	# Multiplayer synchronization: Updates the position of non-local characters.
	if not is_player:
		# Set the character's position to the last known position received from network.
		position = _position
		return
	
	# Player input: Handles movement based on user input for the local character.
	if is_player:
		# Process player input for movement and jumping.
		direction.x = Input.get_axis("move_left", "move_right")
		direction.z = Input.get_axis("move_up", "move_down")
		jumping = Input.is_action_just_pressed("ui_accept")
		# Make the character jump if on the floor and the jump action was just pressed.
		if is_on_floor() and jumping:
			velocity.y = JUMP_VELOCITY
		# Apply movement based on player input.
		apply_movement(delta, is_player)
		return

# Applies movement to the character based on calculated velocities and deltas.
func apply_movement(delta, is_player):
	# Compute new velocity based on the current direction and speed.
	var new_velocity = direction * speed
	velocity.x = new_velocity.x
	velocity.z = new_velocity.z
	# Apply gravity when the character is not on the floor.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Move the character with the new velocity.
	move_and_slide()

	# Network synchronization: Send the character's position to other clients if it has changed.
	if last_position != position:
		# If local player, send position to server; otherwise, broadcase to other peers.
		if is_player:
			rpc_send_position.rpc_id(1, position)
		else:
			rpc_send_position(position)

# Remote procedure call to sync the character's position across the network.
@rpc("any_peer", "call_remote")
func rpc_send_position(rpc_position):
	# Update the character's networked position variable.
	_position = rpc_position
