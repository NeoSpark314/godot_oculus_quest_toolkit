extends Spatial

enum CollisionType {
	FIXED_GROUND,
	RAYCAST,
	#CAPSULE, # not yet implemented...
}

var max_player_height = 3.0; 

export var ground_height := 0.0;

export var gravity := 9.81;

export var epsilon := 0.001;

export var force_up = false;

export(CollisionType) var collision_type = CollisionType.FIXED_GROUND;

var on_ground = true;

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_Falling: parent is not ARVROrigin");
		



var fall_speed = 0.0;

func _physics_process(dt):
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
		var to = from - Vector3(0.0, max_player_height, 0.0);
		var result = space_state.intersect_ray(from, to);
		
		var dist = 0.0;
		
		on_ground = false;
		max_fall_distance = max_player_height;
		
		if (result):
			var hitPoint = result.position;
			dist = head_position.y - hitPoint.y;
			if (dist > player_height):
				on_ground = false;
				max_fall_distance = dist-player_height;
			else:
				on_ground = true;
				max_fall_distance = 0.0;
				if (force_up && (dist < player_height - epsilon)):
					vr.vrOrigin.translation.y += (player_height - dist);

		
		
		#TODO: implement
		#if (result):
		#	print(result);
			
	if (!on_ground):
		fall_speed += gravity * dt;
		vr.vrOrigin.translation.y -= min(max_fall_distance, fall_speed * dt);
		print(vr.vrOrigin.translation.y)
	else:
		fall_speed = 0.0;
