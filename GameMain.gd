# This is the main entry point for the demo scenes of the godot oculus quest toolkit
# Please check https://github.com/NeoSpark314/godot_oculus_quest_toolkit for documentation

extends Node

var room_list = [
	"res://demo_scenes/UIDemoScene.tscn",
	"res://demo_scenes/PhysicsScene.tscn",
	"res://demo_scenes/ClimbingScene.tscn",
	"res://demo_scenes/experiments/TableTennis.tscn",
	"res://demo_scenes/experiments/TestRoom.tscn",
	"res://demo_scenes/WalkInPlaceDemoScene.tscn",
	]

var current_room = 0;

func _process(_dt):
	pass;
		
func _ready():
	vr.initialize();
	vr.scene_switch_root = self;
	
	# This is required for WebXR support to wait until the user pressed the button
	# the buttons itself are created inside the vr.initialize();
	if (vr.arvr_webxr_interface): yield(vr, "signal_webxr_started");
	
	# Always advertise Godot a bit in the beginning
	if (vr.inVR): vr.switch_scene("res://demo_scenes/GodotSplash.tscn", 0.0, 0.0);
	
	vr.switch_scene(room_list[current_room], 0.1, 5.0);

	vr.log_info("  Tracking space is: %d" % vr.get_tracking_space());
	vr.log_info(str("  get_boundary_oriented_bounding_box is: ", vr.get_boundary_oriented_bounding_box()));
	vr.log_info("Engine.target_fps = %d" % Engine.target_fps);

