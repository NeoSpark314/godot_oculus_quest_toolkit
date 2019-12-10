extends Node

const UI_PIXELS_TO_METER = 1.0 / 1024; # defines the (auto) size of UI elements in 3D

var inVR = false;

###############################################################################
# VR logging systems
###############################################################################

var _log_buffer = [];
var _log_buffer_index = -1;
var _log_buffer_count = 0;

func _init_vr_log():
	for i in range(1024):
		_log_buffer.append([0, "", 0]);
		
func _append_to_log(type, message):
	if (_log_buffer.size() == 0): _init_vr_log();
	
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
	print("ERROR: : ", s);
	
	
var _label_scene = null;
var _dbg_labels = {};


func _reorder_dbg_labels():
	# reorder all available labels
	var offset = 0.0;
	for labels in _dbg_labels.values():
		labels.translation = Vector3(0.1, 0.1 - offset, -0.75);
		offset += 0.08;


# this funciton attaches a UI label to the camera to show debug information
func show_dbg_info(key, value):
	if (!_dbg_labels.has(key)):
		# we could not preload the scene as it depends on the vr. singleton which
		# somehow prevented parsing...
		if (_label_scene == null): _label_scene = load("res://OQ_Toolkit/OQ_UI2D/OQ_UI2DLabel.tscn");
		var l = _label_scene.instance();
		_dbg_labels[key] = l;
		vrCamera.add_child(l);
		_reorder_dbg_labels();
	_dbg_labels[key].set_text(value);
	
func remove_dbg_info(key):
	if (!_dbg_labels.has(key)): return;
	vrCamera.remove_child(_dbg_labels[key]);
	_dbg_labels[key].queue_free();
	_dbg_labels.erase(key);
	_reorder_dbg_labels();


# returns the current player height based on the difference between
# the height of origin and camera; this assumes that tracking is floor level
func get_current_player_height():
	return vrCamera.global_transform.origin.y - vrOrigin.global_transform.origin.y;


###############################################################################
# Controller Handling
###############################################################################

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


###############################################################################
# OVR Settings helpers
###############################################################################

# Oculus VR Api Classes
var ovrDisplayRefreshRate = null;
var ovrGuardianSystem = null;
var ovrInitConfig = null;
var ovrPerfromance = null;
var ovrTrackingTransform = null;
var ovrUtilities = null;
var ovrVrApiProxy = null;
# for the types we need to assume it is always available
var ovrVrApiTypes = load("res://addons/godot_ovrmobile/OvrVrApiTypes.gd").new();

var _need_settings_refresh = false;


func _initialize_OVR_API():
	# load all native interfaces to the vrApi
	var OvrDisplayRefreshRate = load("res://addons/godot_ovrmobile/OvrDisplayRefreshRate.gdns");
	var OvrGuardianSystem = load("res://addons/godot_ovrmobile/OvrGuardianSystem.gdns");
	var OvrInitConfig = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns");
	var OvrPerformance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns");
	var OvrTrackingTransform = load("res://addons/godot_ovrmobile/OvrTrackingTransform.gdns");
	var OvrUtilities = load("res://addons/godot_ovrmobile/OvrUtilities.gdns");
	var OvrVrApiProxy = load("res://addons/godot_ovrmobile/OvrVrApiProxy.gdns");
	
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
	if (OvrUtilities): ovrUtilities = OvrUtilities.new();
	else: log_error("Failed to load OvrUtilities.gdns");
	if (OvrVrApiProxy): ovrVrApiProxy = OvrVrApiProxy.new();
	else: log_error("Failed to load OvrVrApiProxy.gdns");
	
	#log_info(str("    Supported display refresh rates: ", get_supported_display_refresh_rates()));


# When the android application gets paused it will destroy the VR context
# this funciton makes sure that we persist the settings we set via vr. to persist
# between pause and resume
func _refresh_settings():
	log_info("_refresh_settings()");
	
	set_display_refresh_rate(oculus_mobile_settings_cache["display_refresh_rate"]);
	request_boundary_visible(oculus_mobile_settings_cache["boundary_visible"]);
	set_tracking_space(oculus_mobile_settings_cache["tracking_space"]);
	set_default_layer_color_scale(oculus_mobile_settings_cache["default_layer_color_scale"]);
	set_extra_latency_mode(oculus_mobile_settings_cache["extra_latency_mode"]);
	set_foveation_level(oculus_mobile_settings_cache["foveation_level"]);
	
	set_swap_interval(oculus_mobile_settings_cache["swap_interval"]);
	set_clock_levels(oculus_mobile_settings_cache["clock_levels_cpu"], oculus_mobile_settings_cache["clock_levels_gpu"]);
	
	_need_settings_refresh = false;


func _notification(what):
	if (what == NOTIFICATION_APP_PAUSED):
		pass;
	if (what == NOTIFICATION_APP_RESUMED):
		_need_settings_refresh = true;
		pass;


# the settings cache used to refresh the settings after an app pause; these are also the default settings
# make sure to update _refresh_settings() and the respective setter wrapper methods when this needs to be changed
var oculus_mobile_settings_cache = {
	"display_refresh_rate" : 72,
	"boundary_visible" : false,
	"tracking_space" : ovrVrApiTypes.OvrTrackingSpace.VRAPI_TRACKING_SPACE_LOCAL_FLOOR,
	"default_layer_color_scale" : Color(1.0, 1.0, 1.0, 1.0),
	"extra_latency_mode" : ovrVrApiTypes.OvrExtraLatencyMode.VRAPI_EXTRA_LATENCY_MODE_ON,
	"foveation_level" : FoveatedRenderingLevel.Off,
	"swap_interval" : 1,
	"clock_levels_cpu" : 2,
	"clock_levels_gpu" : 2,
}

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
		oculus_mobile_settings_cache["display_refresh_rate"] = value;
		ovrDisplayRefreshRate.set_display_refresh_rate(value);

func get_boundary_oriented_bounding_box():
	if (!ovrGuardianSystem):
		log_error("get_boundary_oriented_bounding_box(): no ovrGuardianSystem object.");
		return [Transform(), Vector3(1.93, 2.5, 2.25)]; # return a default value
	else:
		var ret = ovrGuardianSystem.get_boundary_oriented_bounding_box();
		if ((ret == null) || !(ret is Array) || (ret.size() != 2)):
			log_error(str("get_boundary_oriented_bounding_box(): invalid return value: ", ret));
			return [Transform(), Vector3(0, 0, 0)]; # return a default value
		return ret;
		
func request_boundary_visible(val):
	if (!ovrGuardianSystem):
		log_error("request_boundary_visible(): no ovrGuardianSystem object.");
		return false;
	else:
		oculus_mobile_settings_cache["boundary_visible"] = val;
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
		
func set_tracking_space(tracking_space):
	if (!ovrTrackingTransform):
		log_error("set_tracking_space(): no ovrTrackingTransform object.");
		return false;
	else:
		oculus_mobile_settings_cache["tracking_space"] = tracking_space;
		return ovrTrackingTransform.set_tracking_space(tracking_space);


# these variables are currently only used by the recording playback
# order is [head, controller_id 1, controller_id 2]
var _sim_angular_velocity = [Vector3(0,0,0), Vector3(0,0,0), Vector3(0,0,0)];
var _sim_angular_acceleration = [Vector3(0,0,0), Vector3(0,0,0), Vector3(0,0,0)];
var _sim_linear_velocity = [Vector3(0,0,0), Vector3(0,0,0), Vector3(0,0,0)];
var _sim_linear_acceleration = [Vector3(0,0,0), Vector3(0,0,0), Vector3(0,0,0)];

func get_controller_angular_velocity(controller_id):
	if (!ovrUtilities):
		#return Vector3(0,0,0); # we could implement a fallback here
		return _sim_angular_velocity[controller_id];
	else:
		return ovrUtilities.get_controller_angular_velocity(controller_id);

func get_controller_angular_acceleration(controller_id):
	if (!ovrUtilities):
		#return Vector3(0,0,0); # we could implement a fallback here
		return _sim_angular_acceleration[controller_id];
	else:
		return ovrUtilities.get_controller_angular_acceleration(controller_id);
	
func get_controller_linear_velocity(controller_id):
	if (!ovrUtilities):
		#return Vector3(0,0,0); # we could implement a fallback here
		return _sim_linear_velocity[controller_id];
	else:
		return ovrUtilities.get_controller_linear_velocity(controller_id);


func get_controller_linear_acceleration(controller_id):
	if (!ovrUtilities):
		#return Vector3(0,0,0); # we could implement a fallback here
		return _sim_linear_acceleration[controller_id];
	else:
		return ovrUtilities.get_controller_linear_acceleration(controller_id);


func get_head_angular_velocity():
	if (!ovrUtilities):
		#return Vector3(0,0,0); # we could implement a fallback here
		return _sim_angular_velocity[0];
	else:
		return ovrUtilities.get_head_angular_velocity();

func get_head_angular_acceleration():
	if (!ovrUtilities):
		#return Vector3(0,0,0); # we could implement a fallback here
		return _sim_angular_acceleration[0];
	else:
		return ovrUtilities.get_head_angular_acceleration();
	
func get_head_linear_velocity():
	if (!ovrUtilities):
		#return Vector3(0,0,0); # we could implement a fallback here
		return _sim_linear_velocity[0];
	else:
		return ovrUtilities.get_head_linear_velocity();


func get_head_linear_acceleration():
	if (!ovrUtilities):
		#return Vector3(0,0,0); # we could implement a fallback here
		return _sim_linear_acceleration[0];
	else:
		return ovrUtilities.get_head_linear_acceleration();


func get_ipd():
	if (!ovrUtilities):
		log_error("get_ipd(): no ovrUtilities object.");
		return 0.065;
	else:
		return ovrUtilities.get_ipd();


func set_default_layer_color_scale(color : Color):
	if (!ovrUtilities):
		#log_error("get_ipd(): no ovrUtilities object."); # no error message here as it is commonly called in process
		return false;
	else:
		oculus_mobile_settings_cache["default_layer_color_scale"] = color;
		return ovrUtilities.set_default_layer_color_scale(color);


func set_extra_latency_mode(latency_mode):
	if (!ovrPerfromance):
		log_error("set_tracking_space(): no ovrPerfromance object.");
		return false;
	else:
		oculus_mobile_settings_cache["extra_latency_mode"] = latency_mode;
		return ovrPerfromance.set_extra_latency_mode(latency_mode);


enum FoveatedRenderingLevel {
	Off = 0,
	Low = 1,
	Medium = 2,
	High = 3,
	HighTop = 4  # Quest Only
}

func set_foveation_level(ffr_level):
	if (!ovrPerfromance):
		log_error("set_foveation_level(): no ovrPerfromance object.");
		return false;
	else:
		oculus_mobile_settings_cache["foveation_level"] = ffr_level;
		return ovrPerfromance.set_foveation_level(ffr_level);

func set_swap_interval(interval):
	if (!ovrPerfromance):
		log_error("set_swap_interval(): no ovrPerfromance object.");
		return false;
	else:
		oculus_mobile_settings_cache["swap_interval"] = interval;
		return ovrPerfromance.set_swap_interval(interval);
	
func set_clock_levels(cpu_level, gpu_level):
	if (!ovrPerfromance):
		log_error("set_clock_levels(): no ovrPerfromance object.");
		return false;
	else:
		oculus_mobile_settings_cache["clock_levels_cpu"] = cpu_level;
		oculus_mobile_settings_cache["clock_levels_gpu"] = gpu_level;
		return ovrPerfromance.set_clock_levels(cpu_level, gpu_level);


###############################################################################
# Scene Switching Helper Logic
###############################################################################

var _active_scene_path = null; # this assumes that only a single scene will every be switched
var scene_switch_root = null;

# helper function to switch different scenes; this will be in the
# future extend to allow for some transtioning to happen as well as maybe some shader caching
func _perform_switch_scene(scene_path):
	for s in scene_switch_root.get_children():
		if (s.has_method("scene_exit")): s.scene_exit();
		scene_switch_root.remove_child(s);
		s.queue_free();

	var next_scene_resource = load(scene_path);
	if (next_scene_resource):
		_active_scene_path = scene_path;
		var next_scene = next_scene_resource.instance();
		log_info("    switiching to scene '%s'" % scene_path)
		scene_switch_root.add_child(next_scene);
		if (next_scene.has_method("scene_enter")): next_scene.scene_enter();
	else:
		log_error("could not load scene '%s'" % scene_path)


var _target_scene_path = null;
var _scene_switch_fade_out_duration = 0.0;
var _scene_switch_fade_out_time = 0.0;
var _scene_switch_fade_in_duration = 0.0;
var _scene_switch_fade_in_time = 0.0;
var _switch_performed = false;

func switch_scene(scene_path, fade_time = 0.1, wait_time = 0.0):
	if (wait_time > 0.0 && _active_scene_path != null):
		yield(get_tree().create_timer(wait_time), "timeout")

	if (scene_switch_root == null):
		log_error("vr.switch_scene(...) called but no scene_switch_root configured");
	if (_active_scene_path == scene_path): return;
	if (fade_time <= 0.0):
		_perform_switch_scene(scene_path);
		return;
	_target_scene_path = scene_path;
	
	_scene_switch_fade_out_duration = fade_time;
	_scene_switch_fade_in_duration = fade_time;
	_scene_switch_fade_out_time = 0.0;
	_scene_switch_fade_in_time = 0.0;
	_switch_performed = false;

func _check_for_scene_switch_and_fade(dt):
	# first fade out before switch
	if (_target_scene_path != null && !_switch_performed):
		if (_scene_switch_fade_out_time < _scene_switch_fade_out_duration):
			var c = 1.0 - _scene_switch_fade_out_time / _scene_switch_fade_out_duration;
			set_default_layer_color_scale(Color(c, c, c, c));
			_scene_switch_fade_out_time += dt;
		else: # then swith scene when everything is black
			set_default_layer_color_scale(Color(0, 0, 0, 0));
			_perform_switch_scene(_target_scene_path);
			_switch_performed = true;
	elif (_target_scene_path != null && _switch_performed):
		if (_scene_switch_fade_in_time < _scene_switch_fade_in_duration):
			var c = _scene_switch_fade_in_time / _scene_switch_fade_in_duration;
			set_default_layer_color_scale(Color(c, c, c, c));
			_scene_switch_fade_in_time += dt;
		else: # then swith scene when everything is black
			set_default_layer_color_scale(Color(1, 1, 1, 1));
			_target_scene_path = null;


###############################################################################
# Main Funcitonality for initialize and process
###############################################################################

func _ready():
	pass;
	
func _process(dt):
	if (_need_settings_refresh):
		_refresh_settings();
		
	_check_for_scene_switch_and_fade(dt);


func initialize():
	_init_vr_log();
	
	var interface_count = ARVRServer.get_interface_count()
	log_info("Initializing VR:")
	log_info("  Interfaces count: %d" % interface_count)
	
	var arvr_ovr_mobile_interface = ARVRServer.find_interface("OVRMobile")
	var arvr_open_vr_interface = ARVRServer.find_interface("OpenVR")
	
	if arvr_ovr_mobile_interface and arvr_ovr_mobile_interface.initialize():
		get_viewport().arvr = true
		Engine.target_fps = 72 # TODO: only true for Oculus Quest; query the info here
		inVR = true;
		_initialize_OVR_API();
		# this will initialize the default
		_refresh_settings();
		log_info("  Loaded OVRMobile Interface.")
		# TODO: set physics FPS here too instead of in the project settings
		return true;
	elif arvr_open_vr_interface and arvr_open_vr_interface.initialize():
		get_viewport().arvr = true
		Engine.target_fps = 90 # TODO: this is headset dependent => figure out how to get this info at runtime
		OS.vsync_enabled = false
		inVR = true;
		log_info("  Loaded OpenVR Interface.")
	else:
		inVR = false;
		log_error("Failed to enable OVRMobile VR Interface")
		return false;

