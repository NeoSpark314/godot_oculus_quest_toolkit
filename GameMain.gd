extends Node

onready var active_scene_root = self; #$activeScene
var active_scene_path = null;

# helper function to switch different scenes
func switchScene(scene_path, wait_time = 0.0):
	if (active_scene_path == scene_path): return;
	if (wait_time > 0.0 && active_scene_path != null):
		yield(get_tree().create_timer(wait_time), "timeout")

	for s in active_scene_root.get_children():
		if (s.has_method("scene_exit")): s.scene_exit();
		active_scene_root.remove_child(s);
		s.queue_free();

	var next_scene_resource = load(scene_path);
	if (next_scene_resource):
		active_scene_path = scene_path;
		var next_scene = next_scene_resource.instance();
		vr.log_info("    switiching to scene '%s'" % scene_path)
		active_scene_root.add_child(next_scene);
		if (active_scene_root.has_method("scene_enter")): active_scene_root.scene_enter();
	else:
		vr.log_error("could not load scene '%s'" % scene_path)
		
		
var room_list = [
	"res://demo_scenes/UIDemoScene.tscn",
	"res://demo_scenes/PhysicsScene.tscn",
	"res://demo_scenes/ClimbingScene.tscn",
	"res://demo_scenes/experiments/TableTennis.tscn",
	"res://demo_scenes/experiments/TestRoom.tscn"
	]

var current_room = 0;

func _process(dt):
	if (vr.button_just_released(vr.BUTTON.ENTER)):
		#current_room = (current_room + 1) % room_list.size();
		#switchScene(room_list[current_room]);
		switchScene(room_list[0]);
		
func _ready():
	vr.initialize();

	# Always advertise Godot a bit in the beggining
	#switchScene("res://demo_scenes/GodotSplash.tscn");
	switchScene(room_list[current_room], 5.0);

	vr.log_info("  Tracking space is: %d" % vr.get_tracking_space());
	vr.log_info(str("  get_boundary_oriented_bounding_box is: ", vr.get_boundary_oriented_bounding_box()));
	vr.log_info("Engine.target_fps = %d" % Engine.target_fps);

