# This script extends the Node class in Godot
extends Node

# Preloading the player scene to be instantiated later

# Defining the port and host for the multiplayer server
const PORT = 4343
const HOST = "127.0.0.1"

# Creating a new instance of the ENetMultiplayerPeer class
var peer := ENetMultiplayerPeer.new()

# This function is called when the node enters the scene tree
func _enter_tree():
	# Connecting the signals for when a peer connects or disconnects
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(despawn_player)
	
# This function starts the server
func start_server():
	# Hiding the WorldUI node
	$WorldUI.hide()
	# Setting the window title to "server"
	# Creating a server with the specified port
	peer.create_server(PORT)
	# Setting the multiplayer peer for the current multiplayer API
	multiplayer.multiplayer_peer = peer
	DisplayServer.window_set_title("server - " + str(multiplayer.get_unique_id()))
	#optional: Adding the server as a peer with ID 1
	#spawn_player(1) #you could use the server as a player too by including this line
	
	#some "ai" players not attached to any remote peer which we could easily control with the server
	spawn_player("ai-"+str(randi_range(0,99999)), true)
	spawn_player("ai-"+str(randi_range(0,99999)), true)
	spawn_player("ai-"+str(randi_range(0,99999)), true)

# This function starts the client
func start_client():
	# Hiding the WorldUI node
	$WorldUI.hide()
	# Setting the window title to "client"
	DisplayServer.window_set_title("client")
	# Creating a client that will connect to the specified host and port
	peer.create_client(HOST, PORT)
	# Setting the multiplayer peer for the current multiplayer API
	multiplayer.multiplayer_peer = peer
	
	DisplayServer.window_set_title("client - " + str(multiplayer.get_unique_id()))

# This function spawns a player with a given ID
func spawn_player(id, _is_ai = false):
	if not is_multiplayer_authority():
		return
	# Instantiating a new player scene
	var p = preload("res://player.tscn").instantiate()
	p.position = Vector3(randf_range(-5,5),3,0)
	# Setting the player's name to its ID
	p.name = str(id)
	p.ai = _is_ai
	# Adding the player as a child of the Players node
	%Players.add_child(p, true)
	

# This function despawns a player with a given ID
func despawn_player(id):
	# Looping over all children of the Players node.
	if not is_multiplayer_authority():
		return
	for p in %Players.get_children():
		# Checking if the current child's name matches the ID
		if p.name == str(id):
			# Deleting the player node
			p.queue_free()
			# Exiting the loop as the player has been found and deleted
			break
