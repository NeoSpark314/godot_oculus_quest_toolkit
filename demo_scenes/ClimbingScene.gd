extends Spatial

onready var info_label = $OQ_ARVROrigin/OQ_LeftController/OQ_VisibilityToggle/OQ_UILabel;

func _ready():
	pass # Replace with function body.

func _process(delta):
	info_label.set_text("%.2f %.2f %.2f" % [vr.vrOrigin.translation.x, vr.vrOrigin.translation.y, vr.vrOrigin.translation.z]);
