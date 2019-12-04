extends Spatial

###############################################################################
# VR Interaction Recorder
###############################################################################
var _recording = null;
var _record_active = false;
var _playback_active = false;
var _playback_position = 0;

func _process(dt):
	if (_record_active): _record();
	if (_playback_active): _play_back();


func start_recording():
	_record_active = true;
	_recording = {
		"head_position" : [],  # Vec3
		"head_orientation" : [], # Quat
		"left_controller_position" : [],
		"left_controller_orientation" : [],
		"left_controller_buttons" : [],
		"right_controller_position" : [],
		"right_controller_orientation" : [],
		"right_controller_buttons" : [],
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
	
	
func _rec_buttons(t : Array, controller):
	var b = controller._buttons_pressed;
	var value = 0;
	for i in range(0, 16):
		value += b[i] << i;
	t.append(value);
	

func _record():
	# Head
	_rec_vector3(_recording.head_position, vr.vrCamera.global_transform.origin);
	_rec_orientation(_recording.head_orientation, vr.vrCamera.global_transform.basis);
	# Left Controller
	_rec_vector3(_recording.left_controller_position, vr.leftController.global_transform.origin);
	_rec_orientation(_recording.left_controller_orientation, vr.leftController.global_transform.basis);
	_rec_buttons(_recording.left_controller_buttons, vr.leftController);
	# Right Controller
	_rec_vector3(_recording.right_controller_position, vr.rightController.global_transform.origin);
	_rec_orientation(_recording.right_controller_orientation, vr.rightController.global_transform.basis);
	_rec_buttons(_recording.right_controller_buttons, vr.leftController);


func _set_pos_orientation(t : Spatial, p : Array, o : Array):
	var i = _playback_position * 3;
	var pos = Vector3(p[i+0],p[i+1],p[i+2]);
	var orientation = Basis(Vector3(o[i+0],o[i+1],o[i+2]));
	t.global_transform = Transform(orientation, pos);
	
func _set_buttons(controller, buttonArray):
	var value = int(buttonArray[_playback_position]);
	# on playback we set both arrays here
	var b1 = controller._buttons_pressed;
	var b2 = controller._simulation_buttons_pressed;
	for i in range(0, 16):
		var v = (value >> i) & 1;
		b1[i] = v;
		b2[i] = v;

func _play_back():
	_set_pos_orientation(vr.vrCamera, _recording.head_position, _recording.head_orientation);
	_set_pos_orientation(vr.leftController, _recording.left_controller_position, _recording.left_controller_orientation);
	_set_pos_orientation(vr.rightController, _recording.right_controller_position, _recording.right_controller_orientation);
	
	_set_buttons(vr.leftController, _recording.left_controller_buttons);
	_set_buttons(vr.rightController, _recording.right_controller_buttons);
	
	_playback_position = (_playback_position + 1) % (_recording.head_position.size()/3);
	

func stop_and_save_recording(filename = null):
	_record_active = false;
	if (_recording == null):
		vr.log_error("No recording to save.");
		return;
	var d = OS.get_datetime();
	if (filename == null):
		filename = "recording_%d.%02d.%02d_%02d.%02d.%02d.oqrec"  % [d.year, d.month, d.day, d.hour, d.minute, d.second];
	
	var save_rec = File.new()
	save_rec.open("user://" + filename, File.WRITE)
	save_rec.store_line(to_json(_recording))
	save_rec.close()
	vr.log_info("Saved recording to " + OS.get_user_data_dir() + "/" + filename);
	
func load_and_play_recording(recording_file_name):
	var file = File.new();
	var err = file.open(recording_file_name, file.READ);
	if (err == OK):
		_recording = JSON.parse(file.get_as_text()).result;
		_playback_position = 0;
		_playback_active = true;
		var num_frames = _recording.head_position.size() / 3;
			
		vr.log_info("Loaded a recording with " + str(num_frames) + " frames");
		for k in _recording.keys():
			var check_val = _recording[k].size();
			# Do some basic sanity checking of the data here to avoid surprises
			if (check_val != num_frames && check_val != num_frames * 3):
				vr.log_error("Error in recording: %s has wrong number of elements: %d" % [k, _recording[k].size()]);
	else:
		vr.log_error("Failed to load_and_playback_recording " + recording_file_name + ": " + err);
