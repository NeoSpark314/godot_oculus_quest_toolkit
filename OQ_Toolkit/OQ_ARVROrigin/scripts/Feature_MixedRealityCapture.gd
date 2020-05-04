extends Spatial

enum ovrmMediaMrcActivationMode {
  Automatic = 0,
  Disabled = 1,
};

enum ovrmMediaInputVideoBufferType {
  Memory = 0,
  TextureHandle = 1,
};

enum mrcCameraIntrinsics {
	IsValid = 0,					# bool
	LastChangedTimeSeconds,			# real
	FOVPort_UpTan,					# real
	FOVPort_DownTan,				# real
	FOVPort_LeftTan,				# real
	FOVPort_RightTan,				# real
	VirtualNearPlaneDistanceMeters,	# real
	VirtualFarPlaneDistanceMeters,	# real
	ImageSensorPixelResolution_w,	# int
	ImageSensorPixelResolution_h,	# int
};

enum mrcCameraExtrinsics {
	IsValid = 0,			# bool
	LastChangedTimeSeconds, # real
	CameraStatus,			# int
	AttachedToNode,			# int
	RelativePose			# transform
};

var ovr_mrc = null;

onready var _viewport_background = $Background_Viewport;
onready var _camera_background = $Background_Viewport/Background_Camera; # for now only a single camera is supported

onready var _viewport_foreground = $Foreground_Viewport;
onready var _camera_foreground = $Foreground_Viewport/Foreground_Camera; # for now only a single camera is supported

func _mrc_update_capture_camera(mrc_camera_id, cam, vp, is_background):
	var intrinsics = ovr_mrc.get_external_camera_intrinsics(mrc_camera_id);
	var extrinsics = ovr_mrc.get_external_camera_extrinsics(mrc_camera_id);
	
	vp.size = Vector2(intrinsics[mrcCameraIntrinsics.ImageSensorPixelResolution_w], intrinsics[mrcCameraIntrinsics.ImageSensorPixelResolution_h]);
	
	var h_fov = intrinsics[mrcCameraIntrinsics.FOVPort_LeftTan] + intrinsics[mrcCameraIntrinsics.FOVPort_RightTan]
	var v_fov = intrinsics[mrcCameraIntrinsics.FOVPort_UpTan] + intrinsics[mrcCameraIntrinsics.FOVPort_DownTan]
	
	cam.fov = rad2deg(h_fov * 0.5);
	cam.transform = extrinsics[mrcCameraExtrinsics.RelativePose];
	
	var vr_camera_pos = vr.vrCamera.global_transform.origin;
	var distance_to_headset = (cam.global_transform.origin - vr_camera_pos).length()

	if (is_background):
		cam.near = distance_to_headset;
		cam.far = 100.0;  #intrinsics[mrcCameraIntrinsics.VirtualFarPlaneDistanceMeters];
	else:
		cam.near = 0.01; #intrinsics[mrcCameraIntrinsics.VirtualNearPlaneDistanceMeters];
		cam.far = distance_to_headset;

	#print("cam update: fov = %f near = %f far = %f resX = %d resY = %d" % [cam.fov, cam.near, cam.far, vp.size.x, vp.size.y])


var count = 0;

var _last_sync_id = 0;
var _mrc_render_toggle = true;

var initialized_once = false;

# I need to do this here as this can only be called once VR is initialized
func _initialize():
	if (initialized_once): return;
	
	ovr_mrc = load("res://addons/godot_ovrmobile/OvrMRC.gdns");

	if (ovr_mrc.library.get_current_library_path() != ""):
		ovr_mrc = ovr_mrc.new()
		ovr_mrc.initialize();

		ovr_mrc.set_mrc_activation_mode(ovrmMediaMrcActivationMode.Automatic);
		
		vr.log_info("ovr_mrc.get_mrc_activation_mode() = " + str(ovr_mrc.get_mrc_activation_mode()));
		
		ovr_mrc.set_mrc_input_video_buffer_type(ovrmMediaInputVideoBufferType.TextureHandle);
		ovr_mrc.set_mrc_audio_sample_rate(44000);
	else:
		ovr_mrc = null;
		
	initialized_once = true;

func _process(_dt):
	_initialize();
	
	count += 1;
	
	if (ovr_mrc):
		if (!ovr_mrc.update()):
			vr.log_error("ovr_mrc.update() failed")
		if (ovr_mrc.is_mrc_activated()):
			if (ovr_mrc.get_external_camera_count() > 0):
				# render once
				if (_mrc_render_toggle):
					_mrc_update_capture_camera(0, _camera_background, _viewport_background, true);
					_viewport_background.render_target_update_mode = Viewport.UPDATE_ONCE;
				else:
					_mrc_update_capture_camera(0, _camera_foreground, _viewport_foreground, false);
					_viewport_foreground.render_target_update_mode = Viewport.UPDATE_ONCE;
					
				if (_mrc_render_toggle):
					var timestamp = OS.get_ticks_usec();
					#var texture = _viewport_background.get_texture();
					#var texture_id = VisualServer.texture_get_texid(texture.get_rid());
					#print("timestamp = %d; texture_id = %d; _last_sync_id = %d; texture = %s" % [timestamp, texture_id, _last_sync_id, str(texture.get_size())]);
					
					var background_texture_id = VisualServer.viewport_get_color_texture_id(_viewport_background.get_viewport_rid());
					var foreground_texture_id = VisualServer.viewport_get_color_texture_id(_viewport_foreground.get_viewport_rid());
					
					_last_sync_id = ovr_mrc.encode_mrc_frame_with_dual_texture(background_texture_id, foreground_texture_id, timestamp);
					#_last_sync_id = ovr_mrc.encode_mrc_frame_with_dual_texture(texture_id, texture_id, timestamp);
					
					_mrc_render_toggle = false;
				else:
					ovr_mrc.sync_mrc_frame(_last_sync_id);
					_mrc_render_toggle = true;
	
		# Debug Output
		if (count >= 72*5):
			count = 0;
			vr.log_info("ovr_mrc.is_mrc_enabled() = " + str(ovr_mrc.is_mrc_enabled()));
			vr.log_info("ovr_mrc.is_mrc_activated() = " + str(ovr_mrc.is_mrc_activated()));
			
			vr.log_info("ovr_mrc.get_external_camera_count() = " + str(ovr_mrc.get_external_camera_count()));
			for c in range(0, ovr_mrc.get_external_camera_count()):
				vr.log_info(c);
				vr.log_info("ovr_mrc.get_external_camera_intrinsics(...) = " + str(ovr_mrc.get_external_camera_intrinsics(c)));
				vr.log_info("ovr_mrc.get_external_camera_extrinsics(...) = " + str(ovr_mrc.get_external_camera_extrinsics(c)));
				
			vr.log_info("---------");
	

func _ready():
	if (not get_parent() is ARVROrigin):
		vr.log_error("Feature_MixedRealityCapture: parent is not ARVROrigin");


