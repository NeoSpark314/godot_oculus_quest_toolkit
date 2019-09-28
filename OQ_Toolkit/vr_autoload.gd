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
		log_error("get_boundary_oriented_bounding_box(): no ovrGuardianSystem object.");
		return [Transform(), Vector3(1.93, 2.5, 2.25)]; # return a default value
	else:
		var ret = ovrGuardianSystem.get_boundary_oriented_bounding_box();
		if (!ret || !(ret is Array) || ret.size() != 2):
			log_error(str("get_boundary_oriented_bounding_box(): invalid return value: ", ret));
		return ret;
			
		
		
func request_boundary_visible(val):
	if (!ovrGuardianSystem):
		log_error("request_boundary_visible(): no ovrGuardianSystem object.");
		return false;
	else:
		return ovrGuardianSystem.request_boundary_visible(val);
		
func get_boundary_visible():
	if (!ovrGuardianSystem):
		log_error("get_boundary_visible(): no ovrGuardianSystem object.");
		return false;
	else:
		return ovrGuardianSystem.get_boundary_visible();


func get_tracking_space():
	if (!ovrTrackingTransform):
		log_error("get_tracking_space(): no ovrTrackingTransform object.");
		return -1;
	else:
		return ovrTrackingTransform.get_tracking_space();
		
enum TrackingSpace {
	VRAPI_TRACKING_SPACE_LOCAL = 0, # Eye level origin - controlled by system recentering
	VRAPI_TRACKING_SPACE_LOCAL_FLOOR = 1, # Floor level origin - controlled by system recentering
	VRAPI_TRACKING_SPACE_LOCAL_TILTED = 2, # Tilted pose for "bed mode" - controlled by system recentering
	VRAPI_TRACKING_SPACE_STAGE = 3, # Floor level origin - controlled by Guardian setup
	VRAPI_TRACKING_SPACE_LOCAL_FIXED_YAW = 7
}

func set_tracking_space(tracking_space):
	if (!ovrTrackingTransform):
		log_error("set_tracking_space(): no ovrTrackingTransform object.");
		return false;
	else:
		return ovrTrackingTransform.set_tracking_space(tracking_space);


enum ExtraLatencyMode {
	VRAPI_EXTRA_LATENCY_MODE_OFF = 0,
	VRAPI_EXTRA_LATENCY_MODE_ON = 1,
	VRAPI_EXTRA_LATENCY_MODE_DYNAMIC = 2
}

func set_extra_latency_mode(latency_mode):
	if (!ovrPerfromance):
		log_error("set_tracking_space(): no ovrPerfromance object.");
		return false;
	else:
		return ovrPerfromance.set_extra_latency_mode(latency_mode);

var _active_scene_path = null; # this assumes that only a single scene will every be switched
var scene_switch_root = null;

# helper function to switch different scenes; this will be in the
# future extend to allow for some transtioning to happen as well as maybe some shader caching
func switch_scene(scene_path, wait_time = 0.0):
	if (scene_switch_root == null):
		log_error("vr.switch_scene(...) called byt no scene_switch_root configured");
	
	if (_active_scene_path == scene_path): return;
	if (wait_time > 0.0 && _active_scene_path != null):
		yield(get_tree().create_timer(wait_time), "timeout")

	for s in scene_switch_root.get_children():
		if (s.has_method("scene_exit")): s.scene_exit();
		scene_switch_root.remove_child(s);
		s.queue_free();

	var next_scene_resource = load(scene_path);
	if (next_scene_resource):
		_active_scene_path = scene_path;
		var next_scene = next_scene_resource.instance();
		vr.log_info("    switiching to scene '%s'" % scene_path)
		scene_switch_root.add_child(next_scene);
		if (next_scene.has_method("scene_enter")): next_scene.scene_enter();
	else:
		vr.log_error("could not load scene '%s'" % scene_path)


func initialize():
	_init_vr_log();
	
	var interface_count = ARVRServer.get_interface_count()
	log_info("Initializing VR:")
	log_info("  Interfaces count: %d" % interface_count)
	var arvr_interface = ARVRServer.find_interface("OVRMobile")
	if arvr_interface and arvr_interface.initialize():
		get_viewport().arvr = true
		Engine.target_fps = 72 # TODO: only true for Oculus Quest; query the info here
		inVR = true;

		# load all native interfaces to the vrApi
		var OvrDisplayRefreshRate = load("res://addons/godot_ovrmobile/OvrDisplayRefreshRate.gdns");
		var OvrGuardianSystem = load("res://addons/godot_ovrmobile/OvrGuardianSystem.gdns");
		var OvrInitConfig = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns");
		var OvrPerformance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns");
		var OvrTrackingTransform = load("res://addons/godot_ovrmobile/OvrTrackingTransform.gdns");
		
		if (OvrDisplayRefreshRate): ovrDisplayRefreshRate = OvrDisplayRefreshRate.new();
		else: log_error("Failed to load OvrDisplayRefreshRate.gdns");
		if (OvrGuardianSystem): ovrGuardianSystem = OvrGuardianSystem.new();
		else: log_error("Failed to load OvrGuardianSystem.gdns");
		if (OvrInitConfig): ovrInitConfig = OvrInitConfig.new();
		else: log_error("Failed to load OvrInitConfig.gdns");
		if (OvrPerformance): ovrPerfromance = OvrPerformance.new();
		else: log_error("Failed to load OvrPerformance.gdns");
		if (OvrTrackingTransform): ovrTrackingTransform = OvrTrackingTransform.new();
		else: log_error("Failed to load OvrTrackingTransform.gdns");
		
		log_info(str("    Supported display refresh rates: ", get_supported_display_refresh_rates()));

		# We default here to extra latency mode on to have some performace headroom
		set_extra_latency_mode(ExtraLatencyMode.VRAPI_EXTRA_LATENCY_MODE_ON);

		log_info("  Finished loading OVRMobile Interface.")
		
		# TODO: set physics FPS here too instead of in the project settings
		return true;
	else:
		inVR = false;
		log_error("Failed to enable OVRMobile VR Interface")
		return false;

