extends Spatial

var grab_area : Area = null;
var controller : ARVRController = null;

signal oq_area_object_grab_started;
signal oq_area_object_grab_ended;

export var use_parent_of_area := true;

var is_grabbing = false;
var is_just_grabbing = false;
var grabbed_object = null;
var grabbed_object_parent = null;

export(vr.CONTROLLER_BUTTON) var grab_button = vr.CONTROLLER_BUTTON.GRIP_TRIGGER;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_StaticGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	
	
func _process(_dt):
	grab_area.global_transform = controller.get_palm_transform();
	if (controller._button_just_pressed(grab_button)):
		var overlapping_areas = grab_area.get_overlapping_areas();
		for b in overlapping_areas:
			is_grabbing = true;
			is_just_grabbing = true;
			grabbed_object = b;
			var trafo = b.global_transform;
			grabbed_object_parent = b.get_parent();
			grabbed_object_parent.remove_child(b);
			add_child(b);
			b.global_transform = trafo;
			emit_signal("oq_area_object_grab_started", grabbed_object, controller)
			break;
	else:
		is_just_grabbing = false;
	
	if (!controller._button_pressed(grab_button)):
		if (is_grabbing):
			var trafo = grabbed_object.global_transform;
			remove_child(grabbed_object);
			grabbed_object_parent.add_child(grabbed_object);
			grabbed_object.global_transform = trafo;
			grabbed_object = null;
			grabbed_object_parent = null;
			is_grabbing = false;
			emit_signal("oq_area_object_grab_ended", grabbed_object, controller)
