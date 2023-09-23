extends CharacterBody3D

@export var ai = false
@export var _position = Vector3.ZERO
var speed = 3.0
const JUMP_VELOCITY = 10.0
var gravity = -100
var direction := Vector3(0.0,0.0,0.0)
var jumping := false

# Target for AI movement
var target := Vector3(0.0,0.0,0.0)
var last_position := Vector3(0.0,0.0,0.0)
func _ready():
	_position = position
	
	if ai:
		speed *= 0.1
		$MeshInstance3D.mesh = SphereMesh.new()


func _physics_process(delta):
		
	var _name = str(name)
	var _peer_id = str(multiplayer.get_unique_id())
	var is_player = _name == _peer_id
	
	$TextEdit.out('name', _name)
	$TextEdit.out('is_player', str(is_player))
	$TextEdit.out('position', str(position))
	$TextEdit.out('_position', str(_position))
	
	#if ai and multiplayer.is_server():
	#	we could use this bit to easily set an ai peer position, but I'm leaving that out to keep this simple
	#	return
	
	#only control player on matching peer
	if not is_player:
		#set position of this external peer to the last received _position
		position = _position
		return
	
	#to get this far we must be the local player in control of the peer
	#control player on matching peer
	direction.x = Input.get_axis("move_left", "move_right")
	direction.z = Input.get_axis("move_up", "move_down")
	jumping = Input.is_action_just_pressed("ui_accept")

	if not is_on_floor():
		velocity.y = gravity * delta
	
	if jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if direction:
		var new_velocity= direction * speed
		new_velocity.y = velocity.y
		velocity = new_velocity
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	#TODO: no need to send this each time, should also implement interpolation based on velocity/direction etc
	#send position to server to set and broadcast
	if is_player:
		
		if last_position != position:
			rpc_send_position.rpc_id(1, position)

@rpc("any_peer", "call_remote")
func rpc_send_position(rpc_position):
	_position = rpc_position
