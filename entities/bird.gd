extends Node3D

var target :Vector3
var speed = 3.0
var timer :float = 0.0

func _ready():
	new_target()
	
func _physics_process(delta): 
	position = lerp(position, target, delta)
	look_at(lerp(rotation, target, delta))
	timer+=delta
	if timer > 2.0:
		timer = 0.0
		new_target()

func new_target():
	randomize()
	target = Vector3(randf_range(-5,5),randf_range(0.5,5),randf_range(-5,5))
