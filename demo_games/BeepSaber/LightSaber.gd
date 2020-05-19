extends Area

onready var _mat : ShaderMaterial = $LightSaber_Mesh.mesh.surface_get_material(0);

onready var _anim := $AnimationPlayer;

var type = 0;

func show():
	if (!is_extended()):
		_anim.play("Show");

	
func is_extended():
	return $LightSaber_Mesh.translation.y > 0.1;

func hide():
	# This check makes sure that we are not already in the hidden state
	# (where we translated the light saber to the hilt) to avoid playing it back
	# again from the fully extended light saber position
	if (is_extended()):
		_anim.play("Hide");


func _ready():
	_anim.play("QuickHide");
