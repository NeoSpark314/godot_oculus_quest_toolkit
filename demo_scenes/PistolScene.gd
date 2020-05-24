extends Spatial

func _ready():
	vr.initialize();
	vr.scene_switch_root = self;
