extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ball_start_position = Vector3();

# Called when the node enters the scene tree for the first time.
func _ready():
	ball_start_position = $Ball.global_transform.origin;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (vr.button_just_pressed(vr.BUTTON.Y)):
		$Ball.global_transform.origin = ball_start_position;
		$Ball.sleeping = true;
	pass
