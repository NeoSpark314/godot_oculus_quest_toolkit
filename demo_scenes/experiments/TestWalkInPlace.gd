extends Spatial

onready var dbginfo = $OQ_ARVROrigin/OQ_LeftController/OQ_UILabel;
onready var wip = $OQ_ARVROrigin/Locomotion_WalkInPlace;

func _ready():
	pass # Replace with function body.
	
	
func _process(dt):
	dbginfo.set_text("Avg. Height = %.3f; speed = %f" % [wip._average_height, wip._move_speed]);

