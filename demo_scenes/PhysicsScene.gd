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

func _on_RigidBody_grabbability_changed(body, grabbable, controller):
	if grabbable:
		_set_grabbable_color(body,Color.yellow)
	else:
		_set_grabbable_color(body,Color.white)

func _on_RigidBody_grabbed(body, controller):
	if controller is ARVRController:
		if controller.controller_id == 1:# left
			_set_grabbable_color(body,Color.lightgreen)
		else:# right
			_set_grabbable_color(body,Color.coral)

func _on_RigidBody_released(body, controller):
	_set_grabbable_color(body,Color.white)
