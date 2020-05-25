extends Spatial

func _ready():
	vr.initialize();
	vr.scene_switch_root = self;

func _physics_process(_dt):
	if (vr.button_just_pressed(vr.BUTTON.ENTER)): # switch back to main menu
		vr.switch_scene("res://demo_scenes/UIDemoScene.tscn");
