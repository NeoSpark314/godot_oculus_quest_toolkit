# This script contains the button logic for the controller

# TODOs:
#   - the $ui_raycast_hit should maybe be auto-created? or at least optimized
#   - 
extends ARVRController

# used for the vr simulation
var _simulation_buttons_pressed       = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

var _buttons_pressed       = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
var _buttons_just_pressed  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
var _buttons_just_released = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

var _simulation_joystick_axis = [0.0, 0.0, 0.0, 0.0];


# Sets up everything as it is expected by the helper scripts in the vr singleton
func _enter_tree():
	if (!vr):
		vr.log_error(" in OQ_ARVRController._enter_tree(): no vr singleton");
		return;
	if (controller_id == 1):
		if (vr.leftController != null):
			vr.log_warning(" in OQ_ARVRController._enter_tree(): left controller already set; overwriting it");
		vr.leftController = self;
	elif (controller_id == 2):
		if (vr.rightController != null):
			vr.log_warning(" in OQ_ARVRController._enter_tree(): right controller already set; overwriting it");
		vr.rightController = self;
	else:
		vr.log_error(" in OQ_ARVRController._enter_tree(): unexpected controller id %d" % controller_id);

# Reset when we exit the tree
func _exit_tree():
	if (!vr):
		vr.log_error(" in OQ_ARVRController._exit_tree(): no vr singleton");
		return;
	if (controller_id == 1):
		if (vr.leftController != self):
			vr.log_warning(" in OQ_ARVRController._exit_tree(): left controller different");
			return;
		vr.leftController = null;
	elif (controller_id == 2):
		if (vr.rightController != self):
			vr.log_warning(" in OQ_ARVRController._exit_tree(): right controller different");
			return;
		vr.rightController = null;
	else:
		vr.log_error(" in OQ_ARVRController._exit_tree(): unexpected controller id %d" % controller_id);

	vr.vrOrigin = null;



func _ready():
	pass 

func _button_pressed(button_id):
	return _buttons_pressed[button_id];

func _button_just_pressed(button_id):
	return _buttons_just_pressed[button_id];

func _button_just_released(button_id):
	return _buttons_just_released[button_id];

func _sim_is_button_pressed(i):
	if (vr.inVR): return is_button_pressed(i); # is the button pressed
	else: return _simulation_buttons_pressed[i];
	
func _sim_get_joystick_axis(i):
	if (vr.inVR): return get_joystick_axis(i);
	else: return _simulation_joystick_axis[i];

func _update_buttons_and_sticks():
	for i in range(0, 16):
		var b = _sim_is_button_pressed(i);
		
		if (b != _buttons_pressed[i]): # the state of the button did change
			_buttons_pressed[i] = b;   # update the main state of our button
			if (b == 1):              # and check if it was just pressed or released
				_buttons_just_pressed[i] = 1;
			else:
				_buttons_just_released[i] = 1;
		else:                         # reset just pressed/released
			_buttons_just_pressed[i] = 0;
			_buttons_just_released[i] = 0;
			
			

var first_time = true;

func _process(dt):
	if (get_is_active() || !vr.inVR): # wait for active controller; or update if we are in simulation mode
		_update_buttons_and_sticks();
		
		# this avoid getting just_pressed events when a key is pressed and the controller becomes 
		# active (like it happens on vr.scene_change!)
		if (first_time): 
			_update_buttons_and_sticks();
			first_time = false;


