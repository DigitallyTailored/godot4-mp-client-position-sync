extends Node

# Defines the port and host for the multiplayer server
const PORT = 4343
const HOST = "127.0.0.1"

# Creates a new instance of the ENetMultiplayerPeer class for network communication
var peer := ENetMultiplayerPeer.new()

# Called when the node enters the scene tree, sets up signal connections
func _enter_tree():
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(despawn_player)
	
	#var scenes = get_scenes("res://entities/")
	#print(scenes)
	#for scene in scenes:
	#	%EntitySpawner.add_spawnable_scene(scene)
	
func get_scenes(path):
	var scenes = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				scenes.append_array(get_scenes(path+'/'+file_name))
			else:
				if file_name.ends_with(".tscn"):
					scenes.append(dir.get_current_dir(false)+'/' +file_name)
			file_name = dir.get_next()
	return scenes

# Starts a server, sets up the environment, and spawns AI players
func start_server():
	$WorldUI.hide()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	DisplayServer.window_set_title("server - " + str(multiplayer.get_unique_id()))
	
	spawn_entity("res://entities/tree.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/tree.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/tree.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/rock.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/rock.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/rock.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/rock.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/bird.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/bird.tscn", 'test'+str(randi_range(0,99999)))
	spawn_entity("res://entities/bird.tscn", 'test'+str(randi_range(0,99999)))


# Starts a client, sets up the environment, and connects to the server
func start_client():
	$WorldUI.hide()
	DisplayServer.window_set_title("client")
	peer.create_client(HOST, PORT)
	multiplayer.multiplayer_peer = peer
	DisplayServer.window_set_title("client - " + str(multiplayer.get_unique_id()))

func spawn_player(id):
	spawn_entity("res://entities/character.tscn", id)
	
# Spawns a player with a given ID and optionally marks it as AI
func spawn_entity(scene, id):
	if not is_multiplayer_authority():
		return
	var scene_wrap = load("res://multiplayer/SceneWrap.tscn").instantiate()
	scene_wrap.name = str(id)
	scene_wrap.scene = scene
	scene_wrap._position = Vector3(randf_range(-5,5),0,randf_range(-5,5))
	$Entities.add_child(scene_wrap, true)
	
# Despawns a player with a given ID by removing it from the players node
func despawn_player(id):
	despawn_entity(id)
	
func despawn_entity(id):
	if not is_multiplayer_authority():
		return
	for p in $Entities.get_children():
		if p.name == str(id):
			p.queue_free()
			break
