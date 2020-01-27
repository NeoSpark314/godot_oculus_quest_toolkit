extends Node

		
		
var room_list = [
	"res://demo_scenes/UIDemoScene.tscn",
	"res://demo_scenes/PhysicsScene.tscn",
	"res://demo_scenes/ClimbingScene.tscn",
	"res://demo_scenes/experiments/TableTennis.tscn",
	"res://demo_scenes/experiments/TestRoom.tscn"
	]

var current_room = 0;

func _process(_dt):
	if (vr.button_just_released(vr.BUTTON.ENTER) ||
		(vr.leftController && vr.leftController.is_hand && vr.button_just_released(vr.BUTTON.Y))):
		vr.switch_scene(room_list[0]);
		
func _ready():
	vr.initialize();
	
	vr.scene_switch_root = self;
	
	#vr.switch_scene("res://demo_scenes/experiments/debug/DebugGrab.tscn"); return;
	#vr.switch_scene("res://demo_scenes/experiments/debug/DebugHand.tscn"); return;
	#vr.switch_scene("res://demo_scenes/experiments/debug/DebugFalling.tscn"); return;
	#vr.switch_scene("res://demo_scenes/experiments/debug/DebugWalkInPlace.tscn"); return;
	#vr.switch_scene("res://demo_scenes/experiments/debug/DebugVignette.tscn"); return;
	#vr.switch_scene("res://demo_scenes/experiments/debug/DebugRecording.tscn"); return;
	#vr.switch_scene("res://demo_scenes/WalkInPlaceDemoScene.tscn"); return;
	#vr.switch_scene("res://demo_scenes/PlayerCollisionDemoScene.tscn"); return;
	#vr.switch_scene("res://demo_scenes/HandTrackingDemoScene.tscn"); return;
	#vr.switch_scene("res://demo_scenes/PhysicsScene.tscn"); return;

	# Always advertise Godot a bit in the beggining
	if (vr.inVR): vr.switch_scene("res://demo_scenes/GodotSplash.tscn", 0.0, 0.0);
	vr.switch_scene(room_list[current_room], 0.1, 5.0);

	vr.log_info("  Tracking space is: %d" % vr.get_tracking_space());
	vr.log_info(str("  get_boundary_oriented_bounding_box is: ", vr.get_boundary_oriented_bounding_box()));
	vr.log_info("Engine.target_fps = %d" % Engine.target_fps);

