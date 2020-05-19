extends Spatial

onready var info_label = $OQ_ARVROrigin/OQ_LeftController/OQ_VisibilityToggle/OQ_UILabel;

func _ready():
	pass;


func _physics_process(_dt):
	if (vr.button_just_pressed(vr.BUTTON.ENTER)): # switch back to main menu
		vr.switch_scene("res://demo_scenes/UIDemoScene.tscn");


func _process(_dt):
	info_label.set_label_text("%.2f %.2f %.2f" % [vr.vrOrigin.translation.x, vr.vrOrigin.translation.y, vr.vrOrigin.translation.z]);
	
	
