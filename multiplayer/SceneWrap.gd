extends Node

@export var scene :String = ""
@export var _position :Vector3
@export var _rotation :Vector3
@export var _scale :Vector3 = Vector3(1,1,1)

var target : Node3D
# Called when the node enters the scene tree for the first time.

func _ready():
	target = load(scene).instantiate()
	var multiplayer_synchronizer :MultiplayerSynchronizer= MultiplayerSynchronizer.new()
	target.add_child(multiplayer_synchronizer)
	var config = SceneReplicationConfig.new()
	
	add_child(target)

	#if target has key property starting with underscore, sync that instead - these are used as client overrides or for interpolation
	for property in ['position', 'rotation']:
		if target.get('_'+property) == null:
			config.add_property(str(target.get_path(), ':',property))
		else:
			config.add_property(str(target.get_path(), ':_',property))
	multiplayer_synchronizer.replication_config = config
	
	target.position = _position
	target.rotation = _rotation
	target.scale = _scale
