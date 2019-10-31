extends ARVRCamera


# Sets up everything as it is expected by the helper scripts in the vr singleton
func _enter_tree():
	if (!vr):
		vr.log_error(" in OQ_Camera._enter_tree(): no vr singleton");
		return;
	if (vr.vrCamera):
		vr.log_warning(" in OQ_Camera._enter_tree(): vrCamera already set; overwrting it");
	vr.vrCamera = self;

func _exit_tree():
	if (!vr):
		vr.log_error(" in OQ_Camera._exit_tree(): no vr singleton");
		return;
	if (vr.vrCamera != self):
		vr.log_error(" in OQ_Camera._exit_tree(): different vrCamera");
		return;
	vr.vrCamera = null;


func get_angular_velocity():
	return vr.get_head_angular_velocity();
func get_angular_acceleration():
	return vr.get_head_angular_acceleration();
func get_linear_velocity():
	return vr.get_head_linear_velocity();
func get_linear_acceleration():
	return vr.get_head_linear_acceleration();
