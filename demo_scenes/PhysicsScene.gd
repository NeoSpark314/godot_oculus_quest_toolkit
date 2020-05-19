extends Spatial

const info_text = """Physics Demo Room

Right Controller uses GrabType == HingeJoint
Left Controller uses GrabType == Velocity + Reparent Mesh
"""


func _physics_process(_dt):
	if (vr.button_just_pressed(vr.BUTTON.ENTER)): # switch back to main menu
		vr.switch_scene("res://demo_scenes/UIDemoScene.tscn");


func _ready():
	$InfoLabel.set_label_text(info_text);

