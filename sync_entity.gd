extends CharacterBody3D

# Indicates whether the character is controlled by AI.
@export var ai = false
# Holds the position of the character for network synchronization.
@export var _position = Vector3.ZERO

var direction := Vector3(0.0,0.0,0.0)
# The AI's target position to move towards.
var target := Vector3(0.0,0.0,0.0)
# Keeps track of the character's last position.
var last_position := Vector3(0.0,0.0,0.0)
# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the character's position.
	_position = position

# Called every frame with the 'delta' variable being the elapsed time since the previous call.
# This function handles AI logic, player input and multiplayer synchronization.
func _physics_process(delta):
	# Temporary variables for player identification.
	var _name = str(name)
	var _peer_id = str(multiplayer.get_unique_id())
	var is_player = _name == _peer_id
	
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
		
		# Apply movement based on player input.
		apply_movement(delta, is_player)
		return

# Applies movement to the character based on calculated velocities and deltas.
func apply_movement(delta, is_player):
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
