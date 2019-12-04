###
# Feature_VRRecorder
# This is a basic vr interaction recorder that allows to playback vr interactions
# in desktop mode and record interactions on device.
# 
# Note: For Button Preses this requries to disable a Feature_VRSimulator if it is part of the scene
#       because else it will overwrite the button presses on playback
extends Spatial

var _r = null;
var _record_active = false;
var _playback_active = false;
var _playback_position = 0;

func _process(dt):
	if (_record_active): _record();
	if (_playback_active): _play_back();


func start_recording(rec_template = null):
	_record_active = true;
	if (rec_template != null):
		for k in rec_template:
			_r[k] = [];
	else:
		# default recording structure
		_r = {
			"head_position" : [],  # Vec3
			"head_orientation" : [], # Quat
			"head_linear_velocity" : [],
			"head_linear_acceleration" : [],
			"head_angular_velocity" : [],
			"head_angular_acceleration" : [],
			"left_controller_position" : [],
			"left_controller_orientation" : [],
			"left_controller_buttons" : [],
			"left_controller_axis" : [],
			"left_controller_linear_velocity" : [],
			"left_controller_linear_acceleration" : [],
			"left_controller_angular_velocity" : [],
			"left_controller_angular_acceleration" : [],
			"right_controller_position" : [],
			"right_controller_orientation" : [],
			"right_controller_buttons" : [],
			"right_controller_axis" : [],
			"right_controller_linear_velocity" : [],
			"right_controller_linear_acceleration" : [],
			"right_controller_angular_velocity" : [],
			"right_controller_angular_acceleration" : [],
		}


func _rec_vector3(t : Array, v : Vector3):
	t.append(v.x);
	t.append(v.y);
	t.append(v.z);

func _rec_orientation(t : Array, v : Basis):
	var e = v.get_euler();
	t.append(e.x);
	t.append(e.y);
	t.append(e.z);
	
func _rec_axis(t : Array, controller):
	for i in range(0, 4):
		t.append(controller._sim_get_joystick_axis(i))
	
func _rec_buttons(t : Array, controller):
	var b = controller._buttons_pressed;
	var value = 0;
	for i in range(0, 16):
		value += b[i] << i;
	t.append(value);
	

func _record():
	# Head
	if (_r.has("head_position")):
		_rec_vector3(_r.head_position, vr.vrCamera.global_transform.origin);
	if (_r.has("head_orientation")):
		_rec_orientation(_r.head_orientation, vr.vrCamera.global_transform.basis);
	if (_r.has("head_linear_velocity")):
		_rec_vector3(_r.head_linear_velocity, vr.get_head_linear_velocity());
	if (_r.has("head_linear_acceleration")):
		_rec_vector3(_r.head_linear_acceleration, vr.get_head_linear_acceleration());
	if (_r.has("head_angular_velocity")):
		_rec_vector3(_r.head_angular_velocity, vr.get_head_angular_velocity());
	if (_r.has("head_angular_acceleration")):
		_rec_vector3(_r.head_angular_acceleration, vr.get_head_angular_acceleration());
	
	# Left Controller
	if (_r.has("left_controller_position")):
		_rec_vector3(_r.left_controller_position, vr.leftController.global_transform.origin);
	if (_r.has("left_controller_orientation")):
		_rec_orientation(_r.left_controller_orientation, vr.leftController.global_transform.basis);
	if (_r.has("left_controller_buttons")):
		_rec_buttons(_r.left_controller_buttons, vr.leftController);
	if (_r.has("left_controller_axis")):
		_rec_axis(_r.left_controller_axis, vr.leftController);
	if (_r.has("left_controller_linear_velocity")):
		_rec_vector3(_r.left_controller_linear_velocity, vr.get_controller_linear_velocity(vr.leftController.controller_id));
	if (_r.has("left_controller_linear_acceleration")):
		_rec_vector3(_r.left_controller_linear_acceleration, vr.get_controller_linear_acceleration(vr.leftController.controller_id));
	if (_r.has("left_controller_angular_velocity")):
		_rec_vector3(_r.left_controller_angular_velocity, vr.get_controller_angular_velocity(vr.leftController.controller_id));
	if (_r.has("left_controller_angular_acceleration")):
		_rec_vector3(_r.left_controller_angular_acceleration, vr.get_controller_angular_acceleration(vr.leftController.controller_id));
	
	# Right Controller
	if (_r.has("right_controller_position")):
		_rec_vector3(_r.right_controller_position, vr.rightController.global_transform.origin);
	if (_r.has("right_controller_orientation")):
		_rec_orientation(_r.right_controller_orientation, vr.rightController.global_transform.basis);
	if (_r.has("right_controller_buttons")):
		_rec_buttons(_r.right_controller_buttons, vr.rightController);
	if (_r.has("right_controller_axis")):
		_rec_axis(_r.right_controller_axis, vr.rightController);
	if (_r.has("right_controller_linear_velocity")):
		_rec_vector3(_r.right_controller_linear_velocity, vr.get_controller_linear_velocity(vr.rightController.controller_id));
	if (_r.has("right_controller_linear_acceleration")):
		_rec_vector3(_r.right_controller_linear_acceleration, vr.get_controller_linear_acceleration(vr.rightController.controller_id));
	if (_r.has("right_controller_angular_velocity")):
		_rec_vector3(_r.right_controller_angular_velocity, vr.get_controller_angular_velocity(vr.rightController.controller_id));
	if (_r.has("right_controller_angular_acceleration")):
		_rec_vector3(_r.right_controller_angular_acceleration, vr.get_controller_angular_acceleration(vr.rightController.controller_id));


func _set_pos(t : Spatial, key):
	if (!_r.has(key)): return;
	var p = _r[key];
	var i = _playback_position * 3;
	var pos = Vector3(p[i+0],p[i+1],p[i+2]);
	t.global_transform.origin = pos;

func _set_orientation(t : Spatial, key):
	if (!_r.has(key)): return;
	var o = _r[key];
	var i = _playback_position * 3;
	var orientation = Basis(Vector3(o[i+0],o[i+1],o[i+2]));
	t.global_transform.basis = orientation;
	
func _set_buttons(controller, key):
	if (!_r.has(key)): return;
	var buttonArray = _r[key];
	var value = int(buttonArray[_playback_position]);
	# on playback we set the simulation buttons
	var b2 = controller._simulation_buttons_pressed;
	for i in range(0, 16):
		var v = (value >> i) & 1;
		b2[i] = v;
		
func _set_axis(controller, key):
	if (!_r.has(key)): return;
	var a = _r[key];
	var idx = _playback_position * 4;
	for i in range(0, 4):
		controller._simulation_joystick_axis[i] = a[i + idx];
	
func _get_vec3_or_0(key):
	if (!_r.has(key)): return Vector3(0,0,0);
	var i = _playback_position * 3;
	var p = _r[key];
	return Vector3(p[i+0],p[i+1],p[i+2]);
	

func _play_back():
	_set_pos(vr.vrCamera, "head_position");
	_set_orientation(vr.vrCamera, "head_orientation");
	
	_set_pos(vr.leftController, "left_controller_position");
	_set_orientation(vr.leftController, "left_controller_orientation");
	_set_pos(vr.rightController, "right_controller_position");
	_set_orientation(vr.rightController, "right_controller_orientation");
	
	_set_buttons(vr.leftController, "left_controller_buttons");
	_set_buttons(vr.rightController, "right_controller_buttons");
	
	_set_axis(vr.leftController, "left_controller_axis")
	_set_axis(vr.rightController, "right_controller_axis")
	
	vr._sim_linear_velocity[0] = _get_vec3_or_0("head_linear_velocity");
	vr._sim_linear_velocity[1] = _get_vec3_or_0("left_controller_linear_velocity");
	vr._sim_linear_velocity[2] = _get_vec3_or_0("right_controller_linear_velocity");
	vr._sim_linear_acceleration[0] = _get_vec3_or_0("head_linear_acceleration");
	vr._sim_linear_acceleration[1] = _get_vec3_or_0("left_controller_linear_acceleration");
	vr._sim_linear_acceleration[2] = _get_vec3_or_0("right_controller_linear_acceleration");
	vr._sim_angular_velocity[0] = _get_vec3_or_0("head_angular_velocity");
	vr._sim_angular_velocity[1] = _get_vec3_or_0("left_controller_angular_velocity");
	vr._sim_angular_velocity[2] = _get_vec3_or_0("right_controller_angular_velocity");
	vr._sim_angular_acceleration[0] = _get_vec3_or_0("head_angular_acceleration");
	vr._sim_angular_acceleration[1] = _get_vec3_or_0("left_controller_angular_acceleration");
	vr._sim_angular_acceleration[2] = _get_vec3_or_0("right_controller_angular_acceleration");

	_playback_position = (_playback_position + 1) % (_r.head_position.size()/3);
	

func stop_and_save_recording(filename = null):
	_record_active = false;
	if (_r == null):
		vr.log_error("No recording to save.");
		return;
	var d = OS.get_datetime();
	if (filename == null):
		filename = "recording_%d.%02d.%02d_%02d.%02d.%02d.oqrec"  % [d.year, d.month, d.day, d.hour, d.minute, d.second];
	
	var save_rec = File.new()
	save_rec.open("user://" + filename, File.WRITE)
	save_rec.store_line(to_json(_r))
	save_rec.close()
	vr.log_info("Saved recording to " + OS.get_user_data_dir() + "/" + filename);
	
func load_and_play_recording(recording_file_name):
	var file = File.new();
	var err = file.open(recording_file_name, file.READ);
	if (err == OK):
		_r = JSON.parse(file.get_as_text()).result;
		_playback_position = 0;
		_playback_active = true;
		var num_frames = _r.head_position.size() / 3;
			
		vr.log_info("Loaded a recording with " + str(num_frames) + " frames");
		for k in _r.keys():
			var check_val = _r[k].size();
			# Do some basic sanity checking of the data here to avoid surprises
			if (check_val != num_frames && check_val != num_frames * 3 && check_val != num_frames * 4):
				vr.log_error("Error in recording: %s has wrong number of elements: %d" % [k, _r[k].size()]);
	else:
		vr.log_error("Failed to load_and_playback_r " + recording_file_name + ": " + str(err));
