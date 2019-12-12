# this implementation of step detection is based on the Paper:
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6165345/pdf/sensors-18-02832.pdf
# @article{author = {Lee, Juyoung and Ahn, Sang and Hwang, Jae-In},
#          year = {2018},
#          month = {08},
#          title = {A Walking-in-Place Method for Virtual Reality Using Position and Orientation Tracking},
#          journal = {Sensors}}
#
# See also the python jupyter notebook in the godot_oculus_quest_toolkit repository
# for the data analysis that was used to define the constants below

# TODO: 
#  - some of the constants need more testing as they are all just tuned to me at the moment
#  - walk speed should maybe not be constant but depend on step frequency and other values?


extends Spatial

export var active = true;
export var active_in_desktop = false; # turn this on if you work for example with the VRRecorder feature

const _height_ringbuffer_size = 5; # 5 seems fine in most of the cases so far; but maybe 7 could also work
var _height_ringbuffer_pos = 0;
var _height_ringbuffer = Array()
#const _step_local_detect_threshold = 0.003; # local difference
const _step_height_min_detect_threshold = 0.02; # This might need some tweaking now to avoid missed steps
const _step_height_max_detect_threshold = 0.1; # This might need some tweaking now to avoid missed steps

const _variance_height_detect_threshold = 0.0005;

var _current_height_estimate = 0.0;


func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_StickMovement: parent is not ARVROrigin");
	
	
	_height_ringbuffer.resize(_height_ringbuffer_size);
	_current_height_estimate = vr.get_current_player_height();
	for i in range(0, _height_ringbuffer_size):
		_height_ringbuffer[i] = _current_height_estimate;



func _store_height_in_buffer(y):
	_height_ringbuffer[_height_ringbuffer_pos] = y;
	_height_ringbuffer_pos = (_height_ringbuffer_pos + 1) % _height_ringbuffer_size;
 
func _get_buffered_height(i):
	return _height_ringbuffer[(_height_ringbuffer_pos + i) % _height_ringbuffer_size];


const Cup = -0.06;
const Cdown = -0.177;

# this is required to adjust for the different headset height based on if the user is looking up, down or straight
func _get_viewdir_corrected_height(h, viewdir_y):
	if (viewdir_y >= 0.0):
		return h + Cup * viewdir_y;
	else:
		return h + Cdown * viewdir_y;



func _detect_step():
	var min_value = _get_buffered_height(0);
	var average = min_value;
	var max_diff = 0.0;
		
	var min_val_pos = 0;
	for i in range(1, _height_ringbuffer_size):
		var val = _get_buffered_height(i);
		average += val;
		if (val < min_value):
			min_value = val;
			min_val_pos = i;

	average = average / _height_ringbuffer_size;
	
	var variance = 0.0;
	for i in range(0, _height_ringbuffer_size):
		var val = _get_buffered_height(i);
		variance = variance + abs(average - val);
	variance = variance / _height_ringbuffer_size;
	
	# if there is not much variation in the last _height_ringbuffer_size values we take the average as our current heigh
	# assuming that we are not in a step process then
	if (variance <= _variance_height_detect_threshold):
		_current_height_estimate = average;
	
	# this is now the actual step detection based on that the center value of the ring buffer is the actual minimum (the turning point)
	# and also the defined thresholds to minimize false detections as much as possible
	var dist = _current_height_estimate - min_value;
	if (min_val_pos == _height_ringbuffer_size / 2 
		and dist > _step_height_min_detect_threshold
		and dist < _step_height_max_detect_threshold
		#and (_get_buffered_height(0) - min_value) > _step_local_detect_threshold # this can avoid some local mis predicitons
		): 
		return 1;
	else: 
		return 0;
		

const step_duration = 40.0 / 72.0; # I had ~ 30 frames between steps...
var _step_time = 0.0;
var step_speed = 1.4;


func _move(dt):
	var view_dir = -vr.vrCamera.global_transform.basis.z;
	view_dir.y = 0.0;
	view_dir = view_dir.normalized();
	vr.vrOrigin.translation += view_dir * step_speed* dt;


func _process(dt):
	if (!active): return;
	if (!vr.inVR && !active_in_desktop): return;
	
	var headset_height = vr.get_current_player_height();
	var corrected_height = _get_viewdir_corrected_height(headset_height, -vr.vrCamera.transform.basis.z.y);
	_store_height_in_buffer(corrected_height);
	
	if (_detect_step() == 1):
		_step_time = step_duration;
	else:
		_step_time -= dt;
		
	if (_step_time > 0.0):
		_move(dt);

