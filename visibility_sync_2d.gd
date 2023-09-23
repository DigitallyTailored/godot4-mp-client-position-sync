extends MultiplayerSynchronizer


func get_id(body) -> int:
	var id = str(body.name)
	return id.to_int() if id.is_valid_int() else 0


func _on_area_2d_body_entered(body):
	if not is_inside_tree() or not multiplayer.has_multiplayer_peer() or not is_multiplayer_authority():
		return
	var id = get_id(body)
	if id == 0 or id == multiplayer.get_unique_id():
		return
	set_visibility_for(id, true)


func _on_area_2d_body_exited(body):
	if not is_inside_tree() or not multiplayer.has_multiplayer_peer() or not is_multiplayer_authority():
		return
	var id = get_id(body)
	if id == 0 or id == multiplayer.get_unique_id():
		return
	set_visibility_for(id, false)
