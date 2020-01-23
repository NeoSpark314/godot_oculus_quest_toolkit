extends Spatial

var controller : ARVRController = null;
var grab_area : Area = null;
var held_object = null;
var held_object_data = {};
var grab_mesh : MeshInstance = null;


export var collision_body_active := false;

enum GrabType {
	VELOCITY,
	HINGEJOINT,
	#GRABTYPE_PINJOINT, #!!TODO: not yet working; I first need to figure out how joints work
}

export(GrabType) var grab_type = GrabType.VELOCITY;

onready var _hinge_joint : HingeJoint = $HingeJoint;


export var reparent_mesh = false;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_RigidBodyGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	
	
	if (!collision_body_active):
		$CollisionKinematicBody/CollisionBodyShape.disabled = true;
	
	
	# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
	#controller.connect("button_pressed", self, "_on_ARVRController_button_pressed")
	#controller.connect("button_release", self, "_on_ARVRController_button_release")


func _process(_dt):
	# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
	update_grab()


# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
func update_grab():
	if (controller._button_just_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)):
		grab()
	elif (!controller._button_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)):
		release()


func grab():
	if (held_object):
		return

	# find the right rigid body to grab
	var grabbable_rigid_body = null;
	var bodies = grab_area.get_overlapping_bodies();
	if len(bodies) > 0:
		for body in bodies:
			if body is OQClass_GrabbableRigidBody:
				if body.is_grabbable:
					grabbable_rigid_body = body

	if grabbable_rigid_body:
		if (grab_type == GrabType.VELOCITY): start_grab_velocity(grabbable_rigid_body)
		elif (grab_type == GrabType.HINGEJOINT): start_grab_hinge_joint(grabbable_rigid_body)
		#elif (grab_type == GRABTYPE_PINJOINT): start_grab_pinjoint(rigid_body);


func release():
	if !held_object:
		return
	
	if (grab_type == GrabType.VELOCITY): release_grab_velocity();
	elif (grab_type == GrabType.HINGEJOINT): release_grab_hinge_joint();
	#elif (grab_type == GRABTYPE_PINJOINT): release_grab_pinjoint();
	
func _release_reparent_mesh():
	if (grab_mesh):
		remove_child(grab_mesh);
		held_object.add_child(grab_mesh);
		grab_mesh.transform = Transform();
		grab_mesh = null;


func _reparent_mesh():
	for c in held_object.get_children():
		if (c is MeshInstance):
			grab_mesh = c;
			break;
	if (grab_mesh):
		vr.log_info("Feature_RigidBodyGrab: reparentin mesh " + grab_mesh.name);
		var mesh_global_trafo = grab_mesh.global_transform;
		held_object.remove_child(grab_mesh);
		add_child(grab_mesh);
		
		if (grab_type == GrabType.VELOCITY):
			# now set the mesh transform to be the same as used for the rigid body
			grab_mesh.transform = Transform();
			grab_mesh.transform.basis = held_object.delta_orientation;
		elif (grab_type == GrabType.HINGEJOINT):
			grab_mesh.global_transform = mesh_global_trafo;

	
func start_grab_hinge_joint(grabbable_rigid_body: OQClass_GrabbableRigidBody):
	if (grabbable_rigid_body == null):
		vr.log_warning("Invalid grabbable_rigid_body in start_grab_hinge_joint()");
		return;
		
	if grabbable_rigid_body.is_grabbed:
		return;
		
	held_object = grabbable_rigid_body
	held_object.grab_init(self, GrabType.HINGEJOINT)
	
	_hinge_joint.set_node_b(held_object.get_path());
	
	if (reparent_mesh): _reparent_mesh();





func release_grab_hinge_joint():
	_release_reparent_mesh();
	_hinge_joint.set_node_b("");
	held_object.grab_release(self);
	held_object = null;

func start_grab_velocity(grabbable_rigid_body: OQClass_GrabbableRigidBody):
	if (grabbable_rigid_body == null):
		vr.log_warning("Invalid grabbable_rigid_body in start_grab_velocity()");
		return;
	
	if grabbable_rigid_body.is_grabbed:
		return;
	
	var temp_global_pos = grabbable_rigid_body.global_transform.origin
	var temp_rotation = grabbable_rigid_body.global_transform.basis
	
	
	grabbable_rigid_body.global_transform.origin = temp_global_pos
	grabbable_rigid_body.global_transform.basis = temp_rotation
	
	held_object = grabbable_rigid_body
	held_object.grab_init(self, GrabType.VELOCITY)
	
	if (reparent_mesh): _reparent_mesh();



func release_grab_velocity():
	_release_reparent_mesh();
	
	held_object.grab_release(self)
	held_object = null


func start_grab_pinjoint(rigid_body):
	held_object = rigid_body;
	$PinJoint.set_node_a($GrabArea.get_path());
	$PinJoint.set_node_b(held_object.get_path());
	print("Grab PinJoint");
	pass;

func release_grab_pinjoint():
	pass;


# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
#func _on_ARVRController_button_pressed(button_number):
#	if button_number != vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
#		return
#
#	# if grab button, grab
#	grab()
#
#func _on_ARVRController_button_release(button_number):
#	if button_number != vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
#		return
#
#	# if grab button, grab
#	release()
