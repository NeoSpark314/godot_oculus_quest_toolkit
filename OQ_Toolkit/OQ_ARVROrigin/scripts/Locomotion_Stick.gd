extends Spatial


export var dead_zone = 0.125;

export var move_speed = 1.0;
export(vr.AXIS) var move_left_right = vr.AXIS.LEFT_JOYSTICK_X;
export(vr.AXIS) var move_forward_back = vr.AXIS.LEFT_JOYSTICK_Y;

enum TurnType {
	CLICK,
	SMOOTH
}

export(TurnType) var turn_type = TurnType.CLICK
export var smooth_turn_speed = 90.0;
export var click_turn_angle = 45.0; 
export(vr.AXIS) var turn_left_right = vr.AXIS.RIGHT_JOYSTICK_X;


func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_StickMovement: parent is not ARVROrigin");



func move(dt):
	var dx = vr.get_controller_axis(move_left_right);
	var dy = vr.get_controller_axis(move_forward_back);
	
	if (dx*dx + dy*dy <= dead_zone*dead_zone):
		return;
		
	var view_dir = -vr.vrCamera.global_transform.basis.z;
	var strafe_dir = vr.vrCamera.global_transform.basis.x;
	
	view_dir.y = 0.0;
	strafe_dir.y = 0.0;
	view_dir = view_dir.normalized();
	strafe_dir = strafe_dir.normalized();

	var move = Vector2(dx, dy).normalized() * move_speed;
	
	vr.vrOrigin.translation += view_dir * move.y * dt;
	vr.vrOrigin.translation += strafe_dir * move.x * dt;

var last_click_rotate = false;

var dead_zone_epsilon = 0.8; # multiplyer to have a smaller reset dead zone in click rotate

func turn(dt):
	
	var dlr = -vr.get_controller_axis(turn_left_right);

	if (last_click_rotate): # reset to false only when stick is moved in deadzone; but with epsilon
		last_click_rotate = (abs(dlr) > dead_zone * dead_zone_epsilon); 

	if (abs(dlr) <= dead_zone): return;

	var origHeadPos = vr.vrCamera.global_transform.origin;
	
	# click turning
	if (turn_type == TurnType.CLICK && !last_click_rotate):
		last_click_rotate = true;
		var dsign = sign(dlr);
		vr.vrOrigin.rotate_y(dsign * deg2rad(click_turn_angle));
			
	# smooth turning
	elif (turn_type == TurnType.SMOOTH):
		vr.vrOrigin.rotate_y(deg2rad(dlr * smooth_turn_speed * dt));

	# reposition vrOrigin for in place rotation
	vr.vrOrigin.global_transform.origin +=  origHeadPos - vr.vrCamera.global_transform.origin;
	vr.vrOrigin.global_transform = vr.vrOrigin.global_transform.orthonormalized();


func _process(dt):
	if (vr.vrOrigin.is_fixed): 
		return;
	
	move(dt);
	turn(dt);

