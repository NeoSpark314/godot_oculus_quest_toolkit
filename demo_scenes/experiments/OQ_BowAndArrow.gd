extends Spatial


var _is_grabbed := false;

func oq_can_area_object_grab(controller):
	return true;

func oq_area_object_grab_started(controller):
	global_transform = controller.get_grab_transform();
	_is_grabbed = true;

func oq_area_object_grab_ended(controller):
	_is_grabbed = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


