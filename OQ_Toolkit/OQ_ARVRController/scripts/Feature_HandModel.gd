extends Spatial

var hand : ARVRController = null;
var model : Spatial = null;
var skel : Skeleton = null; 

# this array is used to get the orientations from the sdk each frame (an array of Quat)
var _vrapi_bone_orientations = [];

# remap the bone ids from the hand model to the bone orientations we get from the vrapi
const _hand_bone_mappings = [0, 23,  1, 2, 3, 4,  6, 7, 8,  10, 11, 12,  14, 15, 16, 18, 19, 20, 21];


# This is a test pose for the left hand used only on desktop so the hand has a proper position
const test_pose_left_ThumbsUp = [Quat(0, 0, 0, 1), Quat(0, 0, 0, 1), Quat(0.321311, 0.450518, -0.055395, 0.831098),
Quat(0.263483, -0.092072, 0.093766, 0.955671), Quat(-0.082704, -0.076956, -0.083991, 0.990042),
Quat(0.085132, 0.074532, -0.185419, 0.976124), Quat(0.010016, -0.068604, 0.563012, 0.823536),
Quat(-0.019362, 0.016689, 0.8093, 0.586839), Quat(-0.01652, -0.01319, 0.535006, 0.844584),
Quat(-0.072779, -0.078873, 0.665195, 0.738917), Quat(-0.0125, 0.004871, 0.707232, 0.706854),
Quat(-0.092244, 0.02486, 0.57957, 0.809304), Quat(-0.10324, -0.040148, 0.705716, 0.699782),
Quat(-0.041179, 0.022867, 0.741938, 0.668812), Quat(-0.030043, 0.026896, 0.558157, 0.828755),
Quat(-0.207036, -0.140343, 0.018312, 0.968042), Quat(0.054699, -0.041463, 0.706765, 0.704111),
Quat(-0.081241, -0.013242, 0.560496, 0.824056), Quat(0.00276, 0.037404, 0.637818, 0.769273),
]

func _ready():
	hand = get_parent();
	if (not hand is ARVRController):
		vr.log_error(" in Feature_HandModel: parent not ARVRController.");
		
	model = get_child(0);
	if (model == null):
		vr.log_error(" in Feature_HandModel: expected hand model to be child 0");
		
	skel = model.get_child(0).get_child(0); # this is specific to the .gltf file that was exported
	if (skel == null):
		vr.log_error(" in Feature_HandModel: could not get skeleton of hand");
		
	_vrapi_bone_orientations.resize(24);
	_clear_bone_rest(skel);
	
	# apply a start pose
	for i in range(0, _hand_bone_mappings.size()):
		skel.set_bone_pose(_hand_bone_mappings[i], Transform(test_pose_left_ThumbsUp[i]));


func _process(_dt):
	if (vr.inVR):
		_update_hand_model(hand, model, skel);



# the rotations we get from the OVR sdk are absolute and not relative
# to the rest pose we have in the model; so we clear them here to be
# able to use set pose
# This is more like a workaround then a clean solution but allows to use 
# the hand model from the sample without major modifications
func _clear_bone_rest(skel):
	for i in range(0, skel.get_bone_count()):
		var bone_rest = skel.get_bone_rest(i);
		bone_rest.basis = Basis();
		skel.set_bone_rest(i, bone_rest);


func _update_hand_model(hand: ARVRController, model : Spatial, skel: Skeleton):
	# we check to level visibility here for the node to not update
	# when the application (or the OQ_XXXController) set it invisible
	if (vr.ovrHandTracking && visible): # check if the hand tracking API was loaded
		# scale of the hand model as reported by VrApi
		var ls = vr.ovrHandTracking.get_hand_scale(hand.controller_id);
		if (ls > 0.0): model.scale = Vector3(ls, ls, ls);
		
		var confidence = vr.ovrHandTracking.get_hand_pose(hand.controller_id, _vrapi_bone_orientations);
		if (confidence > 0.0):
			model.visible = true;
			for i in range(0, _hand_bone_mappings.size()):
				skel.set_bone_pose(_hand_bone_mappings[i], Transform(_vrapi_bone_orientations[i]));
		else:
			model.visible = false;
		return true;
	else:
		return false;
