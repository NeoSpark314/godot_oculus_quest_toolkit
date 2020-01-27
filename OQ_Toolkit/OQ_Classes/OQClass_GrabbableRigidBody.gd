# Attach this script to any rigid body you want to be grabbable
# by the Feature_RigidBodyGrab
extends RigidBody

class_name OQClass_GrabbableRigidBody


var target_node = null;
var delta_orientation = Basis();
var delta_position = Vector3();
var is_grabbed := false
var current_grab_type : int

export var is_grabbable := true

var last_reported_collision_pos : Vector3 = Vector3(0,0,0);

var _orig_can_sleep := true;


func grab_init(node, grab_type: int) -> void:
	target_node = node
	current_grab_type = grab_type
	
	is_grabbed = true
	sleeping = false;
	_orig_can_sleep = can_sleep;
	can_sleep = false;


func grab_release(node) -> void:
	# TODO: it would be better to use == Feature_RigidBodyGrab.GrabTypes.KINEMATIC
	# but this leads to an odd cyclic reference error
	# related to this bug: https://github.com/godotengine/godot/issues/21461
	if current_grab_type == 0:
		apply_impulse(target_node, linear_velocity)
		apply_torque_impulse(angular_velocity * 0.001)
	
	is_grabbed = false
	target_node = null
	can_sleep = _orig_can_sleep;


func orientation_follow(state, current_basis : Basis, target_basis : Basis) -> void:
	var delta : Basis = target_basis * current_basis.inverse();
	
	var q = Quat(delta);
	var axis = Vector3(q.x, q.y, q.z);

	if (axis.length_squared() > 0.0001):  # bullet fuzzyzero() is < FLT_EPSILON (1E-5)
		axis = axis.normalized();
		var angle = 2.0 * acos(q.w);
		state.set_angular_velocity(axis * (angle / (state.get_step())));
	else:
		state.set_angular_velocity(Vector3(0,0,0));



func position_follow(state, current_position, target_position) -> void:
	var dir = target_position - current_position;
	state.set_linear_velocity(dir / state.get_step());


func _integrate_forces(state):
	if (!is_grabbed): return
	
	if (!target_node): return
	
	# TODO: it would be better to use == Feature_RigidBodyGrab.GrabTypes.KINEMATIC
	# but this leads to an odd cyclic reference error
	# related to this bug: https://github.com/godotengine/godot/issues/21461
	if current_grab_type == 0:
		return
	
	var target_basis =  target_node.get_global_transform().basis * delta_orientation;
	var target_position = target_node.get_global_transform().origin# + target_basis.xform(delta_position);
	position_follow(state, get_global_transform().origin, target_position);
	orientation_follow(state, get_global_transform().basis, target_basis);
