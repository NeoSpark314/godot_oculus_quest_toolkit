extends Spatial

var controller_velocity = Vector3(0, 0, 0)
var prior_controller_position = Vector3(0, 0, 0)
var prior_controller_velocities = []

var controller : ARVRController = null;

var grab_area : Area = null;
var held_object = null;
var held_object_data = {};

onready var grabbed_object_script = preload("helper_grabbed_RigidBody.gd");


enum {
	GRABTYPE_VELOCITY,
	GRABTYPE_PINJOINT, #!!TODO: not yet working; I first need to figure out how joints work
	
}

var grab_type = GRABTYPE_VELOCITY;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_RigidBodyGrab: parent not ARVRController.");
	grab_area = $GrabArea;


func update_controller_velocity(dt):
	controller_velocity = Vector3(0, 0, 0)
	
	if prior_controller_velocities.size() > 0:
		for vel in prior_controller_velocities:
			controller_velocity += vel

		# Get the average velocity, instead of just adding them together.
		controller_velocity = controller_velocity / prior_controller_velocities.size()

	prior_controller_velocities.append((global_transform.origin - prior_controller_position) / dt)
	
	controller_velocity += (global_transform.origin - prior_controller_position) / dt
	prior_controller_position = global_transform.origin

	if prior_controller_velocities.size() > 30:
		prior_controller_velocities.remove(0)



func start_grab_velocity(rigid_body):
	if (rigid_body.get_script() == grabbed_object_script):
		print("Double grab... not yet supported for velocity grab");
	else:
		held_object = rigid_body;
		held_object_data["script"] = held_object.get_script();
		held_object.set_script(grabbed_object_script);
		held_object.grab_init(self);
		print(grabbed_object_script);
	pass

func release_grab_velocity():
	held_object.grab_release(self);
	held_object.set_script(held_object_data["script"]);
	held_object = null;
	
func start_grab_pinjoint(rigid_body):
	held_object = rigid_body;
	$PinJoint.set_node_a($GrabArea.get_path());
	$PinJoint.set_node_b(held_object.get_path());
	print("Grab PinJoint");
	pass;

func release_grab_pinjoint():
	pass;

func update_grab():
	
	if (held_object == null):
		if (controller._button_just_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)):
			# find the right rigid body to grab
			var rigid_body = null;
			var bodies = grab_area.get_overlapping_bodies();
			if len(bodies) > 0:
				for body in bodies:
					if body is RigidBody:
						rigid_body = body;
			
			if rigid_body:
				if (grab_type == GRABTYPE_VELOCITY): start_grab_velocity(rigid_body);
				elif (grab_type == GRABTYPE_PINJOINT): start_grab_pinjoint(rigid_body);
				
	else:
		if (!controller._button_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)):
			if (grab_type == GRABTYPE_VELOCITY): release_grab_velocity();
			elif (grab_type == GRABTYPE_PINJOINT): release_grab_pinjoint();
			


func do_process(dt):
	if (held_object):
		#held_object.global_transform = global_transform;
		held_object.sleeping = false;
		#held_object.apply_central_impulse(global_transform.origin - held_object.global_transform.origin);
		pass;
	
	update_controller_velocity(dt);
	update_grab()

func _process(dt):
	do_process(dt);
	pass


func _physics_process(dt):
	#do_process(dt);
	pass;
