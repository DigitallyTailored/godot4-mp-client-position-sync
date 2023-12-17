# The script extends from the MultiplayerSynchronizer class
extends MultiplayerSynchronizer

# Function to get the unique ID of a body
# Returns integer representation of body's name if it's a valid integer, otherwise returns 0
func get_id(body) -> int:
	var id = str(body.name)
	return id.to_int() if id.is_valid_int() else 0

# Function triggered when a body enters the 2D area
# If the script is not in the scene tree, or if there's no multiplayer peer, or if the script is not the multiplayer authority, the function returns
# If the ID of the body is 0 or matches the unique ID of the multiplayer, the function returns
# Otherwise, the visibility of the body is set to true
func _on_area_2d_body_entered(body):
	if not is_inside_tree() or not multiplayer.has_multiplayer_peer() or not is_multiplayer_authority():
		return
	var id = get_id(body)
	if id == 0 or id == multiplayer.get_unique_id():
		return
	set_visibility_for(id, true)

# Function triggered when a body exits the 2D area
# If the script is not in the scene tree, or if there's no multiplayer peer, or if the script is not the multiplayer authority, the function returns
# If the ID of the body is 0 or matches the unique ID of the multiplayer, the function returns
# Otherwise, the visibility of the body is set to false
func _on_area_2d_body_exited(body):
	if not is_inside_tree() or not multiplayer.has_multiplayer_peer() or not is_multiplayer_authority():
		return
	var id = get_id(body)
	if id == 0 or id == multiplayer.get_unique_id():
		return
	set_visibility_for(id, false)
