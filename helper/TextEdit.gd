extends TextEdit

var output = {};

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_viewport().get_camera_3d().unproject_position($"..".position);
	position.x -= int(size.x * 0.5)

func out(in_key, in_value):
	output[in_key] = in_value
	text = ""
	for item in output:
		text = item + ": " + output[item] + "\n"+text
