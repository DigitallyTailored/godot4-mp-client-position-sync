extends CharacterBody3D

@export var _position :Vector3 = Vector3.ZERO
@export var _rotation :Vector3 = Vector3.ZERO
var is_self = false 

var acceleration = 20.0
const SPEED = 5.0
var is_sprinting = false
const SPRINT_DURATION = 4.0
var sprint_time_left = SPRINT_DURATION
const SPRINT_MULTIPLIER = 1.5
const JUMP_VELOCITY = 5
const MOUSE_SENSITIVITY = 0.25
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2.0
var camera: Camera3D
var yaw = 0.0
var pitch = 0.0
var can_sprint = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera = $Camera3D
	if str(get_parent().name) == str(multiplayer.get_unique_id()):
		is_self = true
	if is_self:
		$MeshInstance3D.visible = false
		#pass
	else:
		camera.queue_free()
		set_process(false)
		

func _physics_process(delta):
	
	if not is_self:
		position = _position
		rotation = _rotation
		return
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("ui_shift") and can_sprint:
		is_sprinting = true
	if is_sprinting:
		sprint_time_left -= delta
		if sprint_time_left < 0:
			sprint_time_left = 0
			is_sprinting = false
			can_sprint = false
	if !is_sprinting and sprint_time_left < SPRINT_DURATION:
		sprint_time_left += delta
	if sprint_time_left > SPRINT_DURATION:
		sprint_time_left = SPRINT_DURATION
		can_sprint = true
		print(can_sprint)

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_dir += Input.get_vector("key_a", "key_d", "key_w", "key_s")
	input_dir = input_dir.normalized()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_velocity = direction * (SPEED * (SPRINT_MULTIPLIER if is_sprinting else 1.0))  # Calculate the target velocity based on input direction
	if direction:
		# Accelerate towards the target speed.
		velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)
	else:
		# Decelerate to a stop.
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
			
		
	move_and_slide()
	rpc_send_position.rpc_id(1, position)
	rpc_send_rotation.rpc_id(1, rotation)
	
	#for col_idx in get_slide_collision_count():
	#	var col := get_slide_collision(col_idx)
	#	if col.get_collider() is RigidBody3D:
	#		var collider = col.get_collider()
	#		#col.get_collider().linear_velocity = -col.get_normal() * 100 * delta
	#		col.get_collider().apply_impulse(-col.get_normal() * 100 * delta, col.get_position() - col.get_collider().global_position)
	#for i in get_slide_collision_count():
	#	var col = get_slide_collision(i)
	#	if col.get_collider() is RigidBody3D:
	#		col.get_collider().apply_force(col.get_normal() * -SPEED * SPRINT_MULTIPLIER)
	

@rpc("any_peer", "call_remote")
func rpc_send_position(rpc_position):
	_position = rpc_position

@rpc("any_peer", "call_remote")
func rpc_send_rotation(rpc_rotation):
	_rotation = rpc_rotation

func _input(event):
	if is_self:
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * MOUSE_SENSITIVITY
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x - event.relative.y * MOUSE_SENSITIVITY, -90, 90)
		if event.is_action_pressed("esc"):
			get_tree().quit()
