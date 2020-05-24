# The lightsaber logic is mostly contained in the BeepSaber_Game.gd
# here I only track the extended/sheethed state and provide helper functions to
# trigger the necessary animations
extends Area

# store the saber material in a variable so the main game can set the color on initialize
onready var _mat : ShaderMaterial = $LightSaber_Mesh.mesh.surface_get_material(0);
onready var _anim := $AnimationPlayer;

# the type of note this saber can cut (set in the game main)
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
