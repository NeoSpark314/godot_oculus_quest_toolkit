extends Spatial

onready var bow = get_parent();

func oq_can_area_object_grab(controller):
	print("BowStringGrab");
	return bow._is_grabbed;

func oq_area_object_grab_started(controller):
	pass;

func oq_area_object_grab_ended(controller):
	pass;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


