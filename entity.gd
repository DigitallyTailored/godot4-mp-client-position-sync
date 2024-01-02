extends Node3D

@export var ai = false
@export var _position = Vector3.ZERO
	
@rpc("any_peer", "call_remote")
func rpc_send_position(rpc_position):
	_position = rpc_position
