extends Spatial

enum CollisionType {
	FIXED_GROUND,
	RAYCAST,
	#CAPSULE, # not yet implemented...
}


export var active = true;
export var ground_height := 0.0;
export var gravity := 9.81;
export var epsilon := 0.001;

export var force_move_up : bool = false;
export var move_up_speed : float = 0.0; # 0.0 == instance move up
export var max_raycast_distance : float = 128.0; 
export var ray_collision_mask : int = 2147483647;
export var fall_without_hit : bool = false;

export(CollisionType) var collision_type = CollisionType.FIXED_GROUND;

var move_checker = null;


var on_ground = true;

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_Falling: parent is not ARVROrigin");
		



var fall_speed = 0.0;

func _physics_process(dt):
	if (!active): return;
	
	if (vr.vrOrigin.is_fixed): 
		fall_speed = 0.0; # reset the fall speed when the player is fixed
		return;
	
	on_ground = true;
	
	var head_position = vr.vrCamera.global_transform.origin;
	var player_height = vr.get_current_player_height();
	var foot_height = head_position.y - player_height;
	
	var max_fall_distance = 0.0;

	
	if (collision_type == CollisionType.FIXED_GROUND):
		if (foot_height > ground_height + epsilon):
			on_ground = false;
			#print("head_position: ", head_position);
			#print("foot_height: ", foot_height);
			#print("ground_height: ", ground_height);
			max_fall_distance = foot_height - ground_height;
		else:
			on_ground = true;
			
	elif (collision_type == CollisionType.RAYCAST):
		var space_state = get_world().direct_space_state
		var from = head_position;
		var to = from - Vector3(0.0, max_raycast_distance, 0.0);
		var hit_result = space_state.intersect_ray(from, to, [], ray_collision_mask);
		
		#vr.show_dbg_info("rayCastInfo", "player_height = %f foot_height = %f" % [player_height, foot_height]);
		
		if (fall_without_hit):
			on_ground = false;
			max_fall_distance = max_raycast_distance;
		else:
			on_ground = false;
			max_fall_distance = 0.0;
		
		if (hit_result):
			var hit_point = hit_result.position;
			var hit_dist = head_position.y - hit_point.y;
			if (hit_dist > player_height + epsilon):
				on_ground = false;
				max_fall_distance = hit_dist - player_height;
				#vr.show_dbg_info("dbgFalling", "fallingHit: dist = %f; player_height = %f" % [hit_dist, player_height]);
			else:
				#vr.show_dbg_info("dbgFalling", "onGround: dist = %f; player_height = %f" % [hit_dist, player_height]);
				on_ground = true;
				max_fall_distance = 0.0;
				if (force_move_up && (hit_dist < player_height - epsilon)):
					var move = Vector3(0,0,0);
					if (move_up_speed == 0.0):
						move.y = (player_height - hit_dist);
					else:
						move.y += min(move_up_speed* dt, player_height - hit_dist);
					
					if (move_checker):
						move = move_checker.oq_feature_falling_check_move_up(move);
					
					vr.vrOrigin.translation += move;
					
		else:
			#vr.show_dbg_info("dbgFalling", "fallingNoHit: player_height = %f" % [player_height]);
			pass;

	if (!on_ground):
		fall_speed += gravity * dt;
		vr.vrOrigin.translation.y -= min(max_fall_distance, fall_speed * dt);
	else:
		fall_speed = 0.0;
