extends Spatial

var _average_height_arr = [];
var _average_height_idx = 0;
var _average_height = 0.0;

var _move_speed = 0.0;

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_StickMovement: parent is not ARVROrigin");
	
	_average_height = vr.vrCamera.translation.y;
	for i in range(0, 32):
		_average_height_arr.append(_average_height);


func _update_average_height():
	_average_height_arr[_average_height_idx] = vr.vrCamera.translation.y;
	_average_height = _average_height_arr[0];
	for i in range(1, 32):
		_average_height += _average_height_arr[i];
	_average_height = _average_height / _average_height_arr.size();
	_average_height_idx = (_average_height_idx+1) % _average_height_arr.size();
	
	
func _move(dt):
	var view_dir = -vr.vrCamera.global_transform.basis.z;
	view_dir.y = 0.0;
	view_dir = view_dir.normalized();
	vr.vrOrigin.translation += view_dir * _move_speed * dt;

var frame_number = 0;

var headpos_log = {"frame" : [], "y" : [], "A" : []};

func _log_headpos():
	
	headpos_log["frame"].append(frame_number);
	headpos_log["y"].append(vr.vrCamera.translation.y);
	headpos_log["A"].append(vr.button_pressed(vr.BUTTON.A));
	
	frame_number += 1;
	
	
	

		
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST || what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		print("exit");
		var file = File.new();
		var err = file.open("user://head_log.json", File.WRITE);
		print( "User dir: " + OS.get_user_data_dir());
		print( "fp_user error code: " + str(err) )
		
		if (file != null):
			file.store_line(JSON.print(headpos_log));
			file.close();


func _process(dt):
	_log_headpos();
	
	_update_average_height();
	
	_move_speed = 0.0;
	
	#var diff = abs(vr.vrCamera.translation.y - _average_height);
#	if (diff > 0.01):
#		_move_speed += diff*32.0;
#	else:
#		_move_speed -= 0.01;
#
#
#	if _move_speed < 0.0: _move_speed = 0.0;
#	if _move_speed > 2.0: _move_speed = 2.0;
#
#	_move(dt);
	
	pass;
