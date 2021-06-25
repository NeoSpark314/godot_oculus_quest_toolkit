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

func _set_grabbable_color(grab_object, color):
	var mesh_inst = grab_object.get_node("MeshInstance")
	if mesh_inst is MeshInstance:
		var mat : SpatialMaterial = mesh_inst.get_surface_material(0)
		mat.albedo_color = color

func _on_RigidBody_grabbability_changed(body, grabbable):
	if grabbable:
		_set_grabbable_color(body,Color.yellow)
	else:
		_set_grabbable_color(body,Color.white)

func _on_RigidBody_grabbed(body):
	_set_grabbable_color(body,Color.lightgreen)

func _on_RigidBody_released(body):
	_set_grabbable_color(body,Color.white)
