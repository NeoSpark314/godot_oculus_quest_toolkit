extends Node

const UI_PIXELS_TO_METER = 1.0 / 1024;

var inVR = false;

# Oculus VR Api Classes
var ovrDisplayRefreshRate = null;
var ovrGuardianSystem =  null;
var ovrInitConfig =  null;
var ovrPerfromance =  null;
var ovrTrackingTransform =  null;

# Global accessors to the tracked vr objects; they will be set by the scripts attached
# to the OQ_ objects
var leftController : ARVRController = null;
var rightController : ARVRController = null;
var vrOrigin : ARVROrigin = null;
var vrCamera : ARVRCamera = null;


enum AXIS {
	None = -1,
	
	LEFT_JOYSTICK_X = 0,
	LEFT_JOYSTICK_Y = 1,
	LEFT_INDEX_TRIGGER = 2,
	LEFT_GRIP_TRIGGER = 3,
	
	RIGHT_JOYSTICK_X = 0 + 16,
	RIGHT_JOYSTICK_Y = 1 + 16,
	RIGHT_INDEX_TRIGGER = 2 + 16,
	RIGHT_GRIP_TRIGGER = 3 + 16,
}

enum CONTROLLER_AXIS {
	None = -1,
	
	JOYSTICK_X = 0,
	JOYSTICK_Y = 1,
	INDEX_TRIGGER = 2,
	GRIP_TRIGGER = 3,
}

# the individual buttons directly identified left or right controller
enum BUTTON {
	None = -1,

	Y = 1,
	LEFT_GRIP_TRIGGER = 2, # grip trigger pressed over threshold
	ENTER = 3, # Menu Button on left controller

	TOUCH_X = 5,
	TOUCH_Y = 6,
	X = 7,

	LEFT_TOUCH_THUMB_UP = 10,
	LEFT_TOUCH_INDEX_TRIGGER = 11,
	LEFT_TOUCH_INDEX_POINTING = 12,

	LEFT_THUMBSTICK = 14, # left/right thumb stick pressed
	LEFT_INDEX_TRIGGER = 15, # index trigger pressed over threshold
	
	B = 1 + 16,
	RIGHT_GRIP_TRIGGER = 2 + 16, # grip trigger pressed over threshold
	TOUCH_A = 5 + 16,
	TOUCH_B = 6 + 16,
	A = 7 + 16,
	
	RIGHT_TOUCH_THUMB_UP = 10 + 16,
	RIGHT_TOUCH_INDEX_TRIGGER = 11 + 16,
	RIGHT_TOUCH_INDEX_POINTING = 12 + 16,

	RIGHT_THUMBSTICK = 14 + 16, # left/right thumb stick pressed
	RIGHT_INDEX_TRIGGER = 15 + 16, # index trigger pressed over threshold
}

# Button list mapping to both controllers (needed for actions assigned to specific controllers instead of global)
enum CONTROLLER_BUTTON {
	None = -1,

	YB = 1,
	GRIP_TRIGGER = 2, # grip trigger pressed over threshold
	ENTER = 3, # Menu Button on left controller

	TOUCH_XA = 5,
	TOUCH_YB = 6,
	XA = 7,

	TOUCH_THUMB_UP = 10,
	TOUCH_INDEX_TRIGGER = 11,
	TOUCH_INDEX_POINTING = 12,

	THUMBSTICK = 14, # left/right thumb stick pressed
	INDEX_TRIGGER = 15, # index trigger pressed over threshold
}


var _log_buffer = [];
var _log_buffer_index = -1;
var _log_buffer_count = 0;


func _init_vr_log():
	for i in range(1024):
		_log_buffer.append([0, "", 0]);
		
func _append_to_log(type, message):
	if _log_buffer_index >= 0 && _log_buffer[_log_buffer_index][1] == message:
		_log_buffer[_log_buffer_index][2] += 1;
	else:
		_log_buffer_index = (_log_buffer_index+1) % _log_buffer.size();
		_log_buffer[_log_buffer_index][0] = type;
		_log_buffer[_log_buffer_index][1] = message;
		_log_buffer[_log_buffer_index][2] = 1;
		_log_buffer_count = min(_log_buffer_count+1, _log_buffer.size());

func log_info(s):
	_append_to_log(0, s);
	print(s);

func log_warning(s):
	_append_to_log(1, s);
	print("WARNING: ", s);

func log_error(s):
	_append_to_log(2, s);
	print("ERRROR: : ", s);


# returns the current player height based on the difference between
# the height of origin and camera; this assumes that tracking is floor level
func get_current_player_height():
	return vrCamera.translation.y - vrOrigin.translation.y;


func get_controller_axis(axis_id):
	if (axis_id == AXIS.None) : return 0.0;
	if (axis_id < 16):
		if (leftController == null): return false;
		return leftController._sim_get_joystick_axis(axis_id);
	else: 
		if (rightController == null): return false;
		return rightController._sim_get_joystick_axis(axis_id-16);

func button_pressed(button_id):
	if (button_id == BUTTON.None) : return false;
	if (button_id < 16): 
		if (leftController == null): return false;
		return leftController._buttons_pressed[button_id];
	else: 
		if (rightController == null): return false;
		return rightController._buttons_pressed[button_id-16];

func button_just_pressed(button_id):
	if (button_id == BUTTON.None) : return false;
	if (button_id < 16): 
		if (leftController == null): return false;
		return leftController._buttons_just_pressed[button_id];
	else: 
		if (rightController == null): return false;
		return rightController._buttons_just_pressed[button_id-16];

func button_just_released(button_id):
	if (button_id == BUTTON.None) : return false;
	if (button_id < 16): 
		if (leftController == null): return false;
		return leftController._buttons_just_released[button_id];
	else: 
		if (rightController == null): return false;
		return rightController._buttons_just_released[button_id-16];



# wrapper for accessing the VrAPI helper functions that check for availability

func get_supported_display_refresh_rates():
	if (!ovrDisplayRefreshRate):
		log_error("get_supported_display_refresh_rates(): no ovrDisplayRefreshRate object.");
		return [];
	else:
		return ovrDisplayRefreshRate.get_supported_display_refresh_rates();

func set_display_refresh_rate(value):
	if (!ovrDisplayRefreshRate):
		log_error("set_display_refresh_rate(): no ovrDisplayRefreshRate object.");
	else:
		ovrDisplayRefreshRate.set_display_refresh_rate(value);

func get_boundary_oriented_bounding_box():
	if (!ovrGuardianSystem):
		log_error("set_display_refresh_rate(): no ovrDisplayRefreshRate object.");
		return [];
	else:
		return ovrGuardianSystem.get_boundary_oriented_bounding_box();
		

func get_tracking_space():
	if (!ovrTrackingTransform):
		log_error("get_tracking_space(): no ovrTrackingTransform object.");
		return 0;
	else:
		return ovrTrackingTransform.get_tracking_space();

	

func initialize():
	_init_vr_log();
	
	var interface_count = ARVRServer.get_interface_count()
	log_info("Initializing VR:")
	log_info("  Interfaces count: %d" % interface_count)
	var arvr_interface = ARVRServer.find_interface("OVRMobile")
	if arvr_interface and arvr_interface.initialize():
		var OvrDisplayRefreshRate = load("res://addons/godot_ovrmobile/OvrDisplayRefreshRate.gdns");
		var OvrGuardianSystem = load("res://addons/godot_ovrmobile/OvrGuardianSystem.gdns");
		var OvrInitConfig = load("res://addons/godot_ovrmobile/OvrInitconfig.gdns");
		var OvrPerformance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns");
		var OvrTrackingTransform = load("res://addons/godot_ovrmobile/OvrTrackingTransform.gdns");
		
		get_viewport().arvr = true
		log_info("  Loaded OVRMobile Inteface")
		inVR = true;

		ovrDisplayRefreshRate = OvrDisplayRefreshRate.new();
		ovrGuardianSystem = OvrGuardianSystem.new();
		ovrInitConfig = OvrInitConfig.new();
		ovrPerfromance = OvrPerformance.new();
		ovrTrackingTransform = OvrTrackingTransform.new();
		
		log_info(str("    Supported display refresh rates: ", get_supported_display_refresh_rates()));
		
		Engine.target_fps = 72 # TODO: only true for Oculus Quest; query the info here
		# TODO: set physics FPS here too instead of in the project settings
		return true;
	else:
		inVR = false;
		log_error("Failed to enable OVRMobile VR Interface")
		return false;

