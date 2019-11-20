extends Spatial

var controller : ARVRController = null;

export(vr.CONTROLLER_BUTTON) var show_teleport_button = vr.CONTROLLER_BUTTON.TOUCH_INDEX_TRIGGER;
export(vr.CONTROLLER_BUTTON) var execute_teleport_button = vr.CONTROLLER_BUTTON.INDEX_TRIGGER;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_Teleport: parent not ARVRController.");
	
func _process(delta):
	if (controller._button_pressed(show_teleport_button)):
		pass
	
	
	if (controller._button_just_pressed(execute_teleport_button)):
		pass
	
