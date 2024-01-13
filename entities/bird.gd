extends CharacterBody3D

var target :Vector3
var speed = 3.0
var timer :float = 0.0

func _ready():
	if not multiplayer.is_server():
		set_process(false)
		return
		
	new_target()
	position.y += 2
	
func _physics_process(delta): 
	velocity = target.normalized()
	move_and_slide()
	timer+=delta
	if timer > 2.0:
		timer = 0.0
		new_target()

func new_target():
	randomize()
	target = Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1))
