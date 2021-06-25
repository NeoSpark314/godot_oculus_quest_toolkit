# TODO:
# create the hingejoint and kinematic body maybe only when needed
#   and not as part of the scene always
extends Spatial
class_name Feature_RigidBodyGrab

var controller : ARVRController = null;
# the other hand's grab feature
var other_grab_feature : Feature_RigidBodyGrab = null
var grab_area : Area = null;
var held_object = null;
var held_object_data = {};
var grab_mesh : MeshInstance = null;
var held_object_initial_parent : Node
var last_gesture := "";
# A list of grabbable objects
# First object that entered the grab area is at the front. When grab is
# initiated the object at the front of the list will be grabbed.
var grabbable_candidates = []

export(vr.CONTROLLER_BUTTON) var grab_button = vr.CONTROLLER_BUTTON.GRIP_TRIGGER;
export(String) var grab_gesture := "Fist"
export(int, LAYERS_3D_PHYSICS) var grab_layer := 1
export (vr.GrabTypes) var grab_type := vr.GrabTypes.HINGEJOINT;
export var collision_body_active := false;
export(int, LAYERS_3D_PHYSICS) var collision_body_layer := 1
onready var _hinge_joint : HingeJoint = $HingeJoint;
export var reparent_mesh = false;
export var hide_model_on_grab := false;
# set to true to vibrate controller when object is grabbed
export var rumble_on_grab := false;
# control the intesity of vibration when player grabs an object
export(float,0,1,0.01) var rumble_on_grab_intensity = 0.4
# set to true to vibrate controller when object becomes grabbable
export var rumble_on_grabbable := false;
# control the intesity of vibration when an object becomes grabbable
export(float,0,1,0.01) var rumble_on_grabbable_intensity = 0.2


func just_grabbed() -> bool:
	var did_grab: bool
	
	if controller.is_hand:
		var cur_gesture = controller.get_hand_model().detect_simple_gesture()
		did_grab = cur_gesture != last_gesture and cur_gesture == grab_gesture
		last_gesture = cur_gesture
	else:
		did_grab = controller._button_just_pressed(grab_button)
	
	return did_grab


func not_grabbing() -> bool:
	var not_grabbed: bool
	
	if controller.is_hand:
		last_gesture = controller.get_hand_model().detect_simple_gesture()
		not_grabbed = last_gesture != grab_gesture
	else:
		not_grabbed = !controller._button_pressed(grab_button)
	
	return not_grabbed


func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_RigidBodyGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	grab_area.collision_mask = grab_layer;
	
	$CollisionKinematicBody.collision_layer = collision_body_layer;
	$CollisionKinematicBody.collision_mask = collision_body_layer;
	
	if (!collision_body_active):
		$CollisionKinematicBody/CollisionBodyShape.disabled = true;
	
	# find the other Feature_RigidBodyGrab if it exists
	if controller:
		if controller.controller_id == 1:# left
			if vr.rightController:
				for c in vr.rightController.get_children():
					# can't use "is" because of cyclical dependency issue
					if c.get_class() == "Feature_RigidBodyGrab":
						other_grab_feature = c
						break
		else:# right
			if vr.leftController:
				for c in vr.leftController.get_children():
					# can't use "is" because of cyclical dependency issue
					if c.get_class() == "Feature_RigidBodyGrab":
						other_grab_feature = c
						break
						
	# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
	#controller.connect("button_pressed", self, "_on_ARVRController_button_pressed")
	#controller.connect("button_release", self, "_on_ARVRController_button_release")

# Godot's get_class() method only return native class names
# we need this because we can't use "is" to test against a class_name within
# the class itself, Godot complains about a weird cyclical dependency...
func get_class():
	return "Feature_RigidBodyGrab"

func _physics_process(_dt):
	# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
	update_grab()


# TODO: we will re-implement signals later on when we have compatability with the OQ simulator and recorder
func update_grab() -> void:
	if (just_grabbed()):
		grab()
	elif (not_grabbing()):
		release()


func grab() -> void:
	if (held_object):
		return
	
	# get the next grabbable candidate
	var grabbable_rigid_body = null;
	if grabbable_candidates.size() > 0:
		grabbable_rigid_body = grabbable_candidates.front()
	
	if grabbable_rigid_body:
		# rumble controller to acknowledge grab action
		if rumble_on_grab and controller:
			controller.simple_rumble(rumble_on_grab_intensity,0.1)

		match grab_type:
			vr.GrabTypes.KINEMATIC:
				start_grab_kinematic(grabbable_rigid_body);
			vr.GrabTypes.VELOCITY:
				start_grab_velocity(grabbable_rigid_body);
			vr.GrabTypes.HINGEJOINT:
				start_grab_hinge_joint(grabbable_rigid_body);

		# Hiding a hand tracking model disables pose updating,
		# so we can't hide it here or we can't ever change gesture again
		if hide_model_on_grab and not controller.is_hand:
			#make model dissappear
			var model = $"../Feature_ControllerModel_Left"
			if model:
				model.hide()
			else:
				model = $"../Feature_ControllerModel_Right"
				if model:
					model.hide()


func release():
	if !held_object:
		return
	
	match grab_type:
		vr.GrabTypes.KINEMATIC:
			release_grab_kinematic()
		vr.GrabTypes.VELOCITY:
			release_grab_velocity()
		vr.GrabTypes.HINGEJOINT:
			release_grab_hinge_joint()

	# Hiding a hand tracking model disables pose updating,
	# so we can't hide it here or we can't ever change gesture again
	if hide_model_on_grab and not controller.is_hand:
		#make model reappear
		var model = $"../Feature_ControllerModel_Left"
		if model:
			model.show()
		else:
			model = $"../Feature_ControllerModel_Right"
			if model:
				model.show()


func start_grab_kinematic(grabbable_rigid_body):
	if grabbable_rigid_body.is_grabbed:
		if grabbable_rigid_body.is_transferable:
			# release from other hand to we can transfer to this hand
			other_grab_feature.release()
		else:
			# reject grab if object is already held and it's non-transferable
			return
	
	held_object = grabbable_rigid_body
	
	# keep initial transform
	var initial_transform = held_object.get_global_transform()
	
	# reparent
	held_object_initial_parent = held_object.get_parent()
	held_object_initial_parent.remove_child(held_object)
	add_child(held_object)
	
	held_object.global_transform = initial_transform
	held_object.set_mode(RigidBody.MODE_KINEMATIC)
	
	held_object.grab_init(self, grab_type)


func release_grab_kinematic():
	# keep initial transform
	var initial_transform = held_object.get_global_transform()
	
	# reparent
	remove_child(held_object)
	held_object_initial_parent.add_child(held_object)
	
	held_object.global_transform = initial_transform
	held_object.set_mode(RigidBody.MODE_RIGID)
	
	held_object.grab_release()
	
	held_object = null


	
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
		
		if (grab_type == vr.GrabTypes.VELOCITY):
			# now set the mesh transform to be the same as used for the rigid body
			grab_mesh.transform = Transform();
			grab_mesh.transform.basis = held_object.delta_orientation;
		elif (grab_type == vr.GrabTypes.HINGEJOINT):
			grab_mesh.global_transform = mesh_global_trafo;

	
#func start_grab_hinge_joint(grabbable_rigid_body: OQClass_GrabbableRigidBody):
func start_grab_hinge_joint(grabbable_rigid_body):
	if (grabbable_rigid_body == null):
		vr.log_warning("Invalid grabbable_rigid_body in start_grab_hinge_joint()");
		return;
	
	if grabbable_rigid_body.is_grabbed:
		if grabbable_rigid_body.is_transferable:
			# release from other hand to we can transfer to this hand
			other_grab_feature.release()
		else:
			# reject grab if object is already held and it's non-transferable
			return
		
	held_object = grabbable_rigid_body
	held_object.grab_init(self, grab_type)
	
	_hinge_joint.set_node_b(held_object.get_path());
	
	if (reparent_mesh): _reparent_mesh();

func release_grab_hinge_joint():
	_release_reparent_mesh();
	_hinge_joint.set_node_b("");
	held_object.grab_release();
	held_object = null;


#func start_grab_velocity(grabbable_rigid_body: OQClass_GrabbableRigidBody):
func start_grab_velocity(grabbable_rigid_body):
	if (grabbable_rigid_body == null):
		vr.log_warning("Invalid grabbable_rigid_body in start_grab_velocity()");
		return;
	
	if grabbable_rigid_body.is_grabbed:
		if grabbable_rigid_body.is_transferable:
			# release from other hand to we can transfer to this hand
			other_grab_feature.release()
		else:
			# reject grab if object is already held and it's non-transferable
			return
	
	var temp_global_pos = grabbable_rigid_body.global_transform.origin;
	var temp_rotation = grabbable_rigid_body.global_transform.basis;
	
	
	grabbable_rigid_body.global_transform.origin = temp_global_pos;
	grabbable_rigid_body.global_transform.basis = temp_rotation;
	
	held_object = grabbable_rigid_body;
	held_object.grab_init(self, grab_type);

	if (reparent_mesh): _reparent_mesh();


func release_grab_velocity():
	_release_reparent_mesh();
	
	held_object.grab_release()
	held_object = null


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


func _on_GrabArea_body_entered(body):
	if body is OQClass_GrabbableRigidBody:
		if body.is_grabbable:
			grabbable_candidates.push_back(body)
			
			if grabbable_candidates.size() == 1:
				body._notify_became_grabbable(self)
				
				# initiate "grabbable" rumble when first candidate acquired
				if rumble_on_grabbable and controller:
					controller.simple_rumble(rumble_on_grabbable_intensity,0.1)
				

func _on_GrabArea_body_exited(body):
	if body is OQClass_GrabbableRigidBody:
		var prev_candidate = null
		
		# see if body is losing its grab candidacy. if so, notify
		if grabbable_candidates.size() > 0:
			prev_candidate = grabbable_candidates.front()
			if prev_candidate == body:
				prev_candidate._notify_lost_grabbable(self)
		
		grabbable_candidates.erase(body)
		
		# see if a grab candidacy has changed after removal. if so, notify
		if grabbable_candidates.size() > 0:
			var curr_candidate = grabbable_candidates.front()
			if prev_candidate != curr_candidate:
				curr_candidate._notify_became_grabbable(self)
