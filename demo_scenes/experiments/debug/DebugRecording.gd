extends Spatial


onready var rec = $OQ_ARVROrigin/Feature_VRRecorder;
var output_filename = "test.oqrec";
var record = true; # true => record; false => playback

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST || what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if (record): rec.stop_and_save_recording(output_filename);


# Called when the node enters the scene tree for the first time.
func _ready():
	if (record): rec.start_recording();
	else:
		rec.load_and_play_recording(OS.get_user_data_dir() + "/" + output_filename);


func _process(_dt):
	if (vr.button_just_pressed(vr.BUTTON.A)): print("A");
	if (vr.button_just_pressed(vr.BUTTON.B)): print("B");
	if (vr.button_just_pressed(vr.BUTTON.X)): print("X");
	if (vr.button_just_pressed(vr.BUTTON.Y)): print("Y");
	
