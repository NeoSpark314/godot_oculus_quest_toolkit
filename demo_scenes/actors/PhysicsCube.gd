extends OQClass_GrabbableRigidBody

onready var mesh_inst := $MeshInstance

var currently_grabbable = false

func _ready():
	mesh_inst.set_surface_material(0, SpatialMaterial.new())

func _set_color(color):
	var mat : SpatialMaterial = mesh_inst.get_surface_material(0)
	mat.albedo_color = color
	
func _set_grabbable_color():
	if currently_grabbable:
		_set_color(Color.yellow)
	else:
		_set_color(Color.white)

func _on_PhysicsCube_grabbability_changed(body, grabbable, controller):
	currently_grabbable = grabbable
	if not is_grabbed:
		_set_grabbable_color()

func _on_PhysicsCube_grabbed(body, controller):
	if controller is ARVRController:
		if controller.controller_id == 1:# left
			_set_color(Color.lightgreen)
		else:# right
			_set_color(Color.coral)

func _on_PhysicsCube_released(body, controller):
	_set_grabbable_color()
