extends ARVROrigin


var is_fixed = false;

# Sets up everything as it is expected by the helper scripts in the vr singleton
func _enter_tree():
	if (!vr):
		vr.log_error("in OQ_ARVROrigin._enter_tree(): no vr singleton");
		return;
	if (vr.vrOrigin):
		vr.log_warning("in OQ_ARVROrigin._enter_tree(): origin already set; overwrting it");
	vr.vrOrigin = self;

func _exit_tree():
	if (!vr):
		vr.log_error("in OQ_ARVROrigin._exit_tree(): no vr singleton");
		return;
	if (vr.vrOrigin != self):
		vr.log_error("in OQ_ARVROrigin._exit_tree(): different vrOrigin");
		return;
	vr.vrOrigin = null;
