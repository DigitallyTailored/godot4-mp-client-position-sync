extends CharacterBody3D

@export var ai = false
@export var _position = Vector3.ZERO
var speed = 3.0
const JUMP_VELOCITY = 20.0
var gravity = -100
var direction := Vector3(0.0,0.0,0.0)
var jumping := false

# Target for AI movement
var target := Vector3(0.0,0.0,0.0)
var last_position := Vector3(0.0,0.0,0.0)
var move_timer = 0.0

func _ready():
	_position = position
	
	if ai:
		speed *= 0.2
		$MeshInstance3D.mesh = SphereMesh.new()
		move_timer = Time.get_ticks_msec()

func _physics_process(delta):
	var _name = str(name)
	var _peer_id = str(multiplayer.get_unique_id())
	var is_player = _name == _peer_id
	
	$TextEdit.out('name', _name)
	$TextEdit.out('is_player', str(is_player))
	$TextEdit.out('position', str(position))
	$TextEdit.out('_position', str(_position))
	
	if ai and multiplayer.is_server():
		#add logic here to move peer towards target until either within range or 5 seconds has gone by, in which case, change target
		if target.distance_to(position) < 1 or Time.get_ticks_msec() - move_timer > 5000:
			target = Vector3(randf_range(-5, 5), position.y, randf_range(-5, 5))
			move_timer = Time.get_ticks_msec()
			
		direction = (target - position).normalized()
		if is_on_floor() and randi() % 100 == 1:
			velocity.y = JUMP_VELOCITY
		apply_movement(delta, is_player)
		return
	
	#only control player on matching peer
	if not is_player:
		#set position of this external peer to the last received _position
		position = _position
		return
	
	if is_player:
		#to get this far we must be the local player in control of the peer
		#control player on matching peer
		direction.x = Input.get_axis("move_left", "move_right")
		direction.z = Input.get_axis("move_up", "move_down")
		jumping = Input.is_action_just_pressed("ui_accept")
		if is_on_floor() and jumping:
			velocity.y = JUMP_VELOCITY
		apply_movement(delta, is_player)
		return

func apply_movement(delta, is_player):
	var new_velocity = direction * speed
	velocity.x = new_velocity.x
	velocity.z = new_velocity.z
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

	if last_position != position:
		if is_player:
			rpc_send_position.rpc_id(1, position)
		else:
			rpc_send_position(position)

@rpc("any_peer", "call_remote")
func rpc_send_position(rpc_position):
	_position = rpc_position
