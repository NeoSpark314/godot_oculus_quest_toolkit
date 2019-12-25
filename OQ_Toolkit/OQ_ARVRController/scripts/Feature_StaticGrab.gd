extends Spatial

var grab_area : Area = null;
var controller : ARVRController = null;

# if true the body is checked if it has a method "oq_can_static_grab" and calls it
# to check if it actually can be grabbed. All other objects are ignored
export var check_parent_can_static_grab = false;

var is_grabbing = false;
var is_just_grabbing = false;
var grab_position = Vector3();
var delta_position = Vector3();

export(vr.CONTROLLER_BUTTON) var grab_button = vr.CONTROLLER_BUTTON.GRIP_TRIGGER;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_StaticGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	
	
func _process(_dt):
	if (controller._button_just_pressed(grab_button)):
		for b in grab_area.get_overlapping_bodies():
			
			if (check_parent_can_static_grab):
				var p = b.get_parent();
				if (p && p.has_method("oq_can_static_grab")):
					if (!p.oq_can_static_grab(b, grab_area, controller)): continue;
				else:
					continue;
			
			is_grabbing = true;
			is_just_grabbing = true;
			grab_position = controller.translation; # we need the local translation here as we will move the origin
			break;
	else:
		is_just_grabbing = false;
	
	if (!controller._button_pressed(grab_button)):
		is_grabbing = false;
	elif (is_grabbing):
		delta_position = vr.vrOrigin.global_transform.basis.xform(controller.translation - grab_position);


