extends Position3D

#############################################################################
#the interface starts here
#############################################################################
# tracked pos should always be a direct child of an ARVR contoller node
# trigger button pressed tarts tracking, release stops tracking 
# when u press trigger your points get stored into an array , 
# sent to recognizer
# ________________________________
# if u press add template
# when u press trigger your points get stored into an array , 
# are made into points
# sent to add template
#_________________________________
# delete template deletes all templates
enum ACTION{
	RECOGNIZE,
	ADD,
	IDLE}
var action=["recognize","add","idle"]
export (vr.CONTROLLER_BUTTON) var track_button : int = vr.CONTROLLER_BUTTON.INDEX_TRIGGER
export var custom_names : bool
export var ignore_Y_orientation : bool = true
export var load_previous_data : bool = false
enum MODES{Developer,Gameplay};export(MODES) var Mode
enum TRACKING{Buttons,Velocity};export (TRACKING) var Tracking_type
# in velocity mode
export var speed_threshold_start :float = 1  #tracking starts when controller velocity exceeds this value
export var speed_threshold_stop :float = 1 #tracking stops when controller velocity receeds this value
var user_state=ACTION.IDLE
var add_name
var controller : ARVRController = null
var keyboard
var type_count : int = 1

var add_mode=false

onready var state_info = $OQ_VisibilityToggle/OQ_UILabel
onready var result_info=$OQ_VisibilityToggle/OQ_UILabel2
onready var ui_canvas = $OQ_VisibilityToggle/OQ_UI2DCanvas

var action_manager
var cancel
var point_array=[]
func result(result):
	result_info.set_label_text("matched with " + str(result[0]) +"\n score " +str(result[1]))

	
func _ready():
	controller = get_parent();
	if Mode == MODES.Gameplay:
		# this is the bad way to do this , the other way is to just swap the script on this node with the tracked_obj_game after removing all children , couldnt make it work 
		vr.log_info("gameplay mode is activated")
		var game_tracker = load("res://OQ_Toolkit/OQ_ARVRController/Q_recog_tracked_obj_game.tscn").instance()
		
		controller.call_deferred("add_child",game_tracker)
		game_tracker.speed_threshold_start = speed_threshold_start
		game_tracker.speed_threshold_stop = speed_threshold_stop
		game_tracker.Tracking_type =  Tracking_type
		game_tracker.track_button = track_button
		game_tracker.ignore_Y_orientation = ignore_Y_orientation
		queue_free()
	#gets parent as ARVR contoller and sets it to controller needed for button press recong
	# can be modified 
	if controller.get_parent().get_parent().has_node("action_manager"):
		action_manager = controller.get_parent().get_parent().get_node("action_manager")
	if controller==vr.leftController:
		rotate_y(deg2rad(45))
		transform.origin=Vector3(-0.02,-0.045,0.03)
	elif controller==vr.rightController:
		rotate_y(deg2rad(-45))
		transform.origin=Vector3(0.02,-0.045,0.03)
	keyboard=controller.get_parent().get_node("OQ_UI2DKeyboard") 
	if keyboard != null:
		keyboard.visible=false
		if !custom_names:
			keyboard.queue_free()
	if  load_previous_data:
		p_c = load_p_c_data()
	
func _physics_process(delta):
	var click = controller._button_pressed(track_button)
	var release = controller._button_just_released(track_button)
	var controller_vel = controller.get_linear_velocity().length()
	state_info.set_label_text("state = "+ action[user_state] + "\n add mode =" + str(add_mode))
	match user_state:
		ACTION.IDLE:
			if(Tracking_type ==TRACKING.Buttons and click) or (Tracking_type ==TRACKING.Velocity and controller_vel>=speed_threshold_start):
				if add_mode:
					user_state=ACTION.ADD
				else:
					user_state=ACTION.RECOGNIZE
		ACTION.RECOGNIZE:
#			vr.log_info("controller velocity for " + str(controller.controller_id) + " is "+ str(controller_vel) )
			point_array.append(make_point(global_transform,controller.controller_id))
			if(Tracking_type ==TRACKING.Buttons and release) or (Tracking_type ==TRACKING.Velocity and controller_vel<speed_threshold_stop):
				var result=recognize(point_array)
				#vr_log_info("result"+str(result[0])+" score "+str(result[1]))
				result(result)
				action_manager.recognise_action(result,controller.controller_id)
				point_array.clear()
				user_state=ACTION.IDLE
				#stop tracking ,recognize pool
		ACTION.ADD:
			point_array.append(make_point(global_transform,controller.controller_id))
			state_info.set_label_text("state =" + "\n add mode =" +  "\n" + str(add_mode)+ action[user_state] )
			if(Tracking_type ==TRACKING.Buttons and release) or (Tracking_type ==TRACKING.Velocity and controller_vel<speed_threshold_stop):
				#vr_log_info(" add_name = "+ add_name)
				result_info.set_label_text("added "+ add_name)
				add_gesture(add_name,point_array)
				type_count+=1
				point_array.clear()
				user_state=ACTION.IDLE
				add_mode=false
				add_name=null
func _on_add_pressed():
	if keyboard==null and !custom_names:
		add_mode=true
		add_name="template_" + str(type_count)
		result_info.set_label_text("make movement")
		
	else:
		set_physics_process(false)
		keyboard._text_edit.grab_focus()
		result_info.set_label_text("add name")
		keyboard.visible=true
func _on_delete_pressed():
#	keyboard._text_edit.grab_focus()
	type_count=1
	result_info.set_label_text("all gestures \n deleted")
	delete_gesture()
func _on_cancel_pressed():
	if add_mode:
		add_mode=false
		result_info.set_label_text("cancelled for \n this hand")
func _on_OQ_UI2DKeyboard_text_input_enter(_string):
	result_info.set_label_text("make movement")
	add_mode=true
	add_name=keyboard._text_edit.text
	keyboard.visible=false
	set_physics_process(true)
func _on_OQ_UI2DKeyboard_text_input_cancel():
	keyboard.visible=false
	set_physics_process(true)
#############################################################################
#the main P recognizer code is here
#############################################################################
const NumPoints = 32
var p_c = [] # stored templates
func make_point(vec,ID):
	var point = []
	point.resize(2)
	if vec is Vector3:
		point[0]=vec
	if vec is Transform:
		if ignore_Y_orientation:
			vec.origin.x=vec.origin.x*cos(vr.vrOrigin.rotation.y)-vec.origin.z*sin(vr.vrOrigin.rotation.y)
			vec.origin.z=vec.origin.z*cos(vr.vrOrigin.rotation.y)+vec.origin.x*sin(vr.vrOrigin.rotation.y)
		point[0]=vec.origin
	point[1]=ID
	return point
func make_cloud(nm,pt):
	var point_cloud=[]
	point_cloud.resize(2)
	point_cloud[0]=nm
	var temp_pts=resample(pt,NumPoints)
	temp_pts=_scale(temp_pts)
	temp_pts=translateto(temp_pts)
	point_cloud[1]=temp_pts
	return point_cloud
func resample(p,n):
	var I = pthl(p)/(n-1)
	var D= 0.0
	var n_p=[]
	n_p.append(p[0])
#	#vr_log_info("unr before " +str(p))
#	#vr_log_info("unr before size " +str(p.size()))
	for i in range(1,p.size()):
		if p[i][1] == p[i-1][1]:
			var d = distance(p[i-1][0],p[i][0])
			if D+d >= I and d!=0:
				var qvec = p[i-1][0] + ((I-D)/d)*(p[i][0]-p[i-1][0])
				var q = make_point(qvec,p[i][1])
				n_p.append(q)
				p.insert(i,q)
				D=0.0
			else:
				D+=d
	if n_p.size()==p.size()-1:
		n_p.append(make_point(p[p.size()-1][0],p[p.size()-1][1]))
#	#vr_log_info("unr after" +str(p))
#	#vr_log_info("unr after size " +str(p.size()))
#	#vr_log_info("res " +str(n_p))
#	#vr_log_info("res size " +str(n_p.size()))
	return n_p
func pthl(p):
	var d=0
	for i in range(1,p.size()):
		if p[i][1] == p[i-1][1]:
			d+=distance(p[i-1][0],p[i][0])
	return d 
func _scale(p):
	var n_p=[]
	var min_vec=Vector3(INF,INF,INF)
	var max_vec=Vector3(-INF,-INF,-INF)
	for i in range(p.size()):
		min_vec.x=min(min_vec.x,p[i][0].x)
		min_vec.y=min(min_vec.y,p[i][0].y)
		min_vec.z=min(min_vec.z,p[i][0].z)
		max_vec.x=max(max_vec.x,p[i][0].x)
		max_vec.y=max(max_vec.y,p[i][0].y)
		max_vec.z=max(max_vec.z,p[i][0].z)
	var size_calc=[max_vec.x-min_vec.x,max_vec.y-min_vec.y,max_vec.z-min_vec.z]
	var size=size_calc.max()
	for i in range(p.size()):
		var qvec
		if !size: # if size==0
			qvec=Vector3(0,0,0) # other wise we get(nan,nan,nan) bcz div by zero
			n_p.append(make_point(qvec,p[i][1]))
		else:
			qvec= (p[i][0] - min_vec)/size
			n_p.append(make_point(qvec,p[i][1]))
	return n_p
func translateto(p):
	var n_p=[]
	var c = centroid(p)
	for i in range(p.size()):
		n_p.append(make_point(p[i][0]+-c[0],p[i][1]))
	return n_p
func centroid(p):
	var vec= Vector3()
	for i in range(p.size()):
		vec+=p[i][0]
	vec/=p.size()
	return make_point(vec,controller.controller_id)
func recognize(points):
	var candidate = make_cloud("",points)
#	display_cloud("candidate", candidate)
	var u = -1
	var b = INF
	for i in range(p_c.size()):
		var d = cldmatch(candidate,p_c[i],b)
		#vr_log_info("score for template "+str(i)+" = "+str(d))
		if d<b:
			b=d
			u=i
	if u == -1:
		return ["no match",0.0]
	else:
		if b>1.0:
			b=1.0/b
		else: 
			b=1.0
		#vr_log_info("made score")
		var n=p_c[u][0]
		return [n,b]
func add_gesture(nme, pts):
	vr.log_info(str(p_c))
	p_c.append(make_cloud(nme,pts))
	save_data(p_c,save_p_c_data)
	var display = load_p_c_data()
	vr.log_info("loaded data is "+ str(display))
	var num=0
	for i in p_c:
		if i[0]==nme:
			num+=1
	return num
func delete_gesture():
	p_c.clear()
	clear_p_c_data()
func cldmatch(candidate, template, minsof):
	var step = floor(pow(candidate.size(),1-.5))
	for i in range(0,candidate.size(),step):
		var m1=cldd(candidate[1],template[1],i)
		var m2=cldd(template[1],candidate[1],i)
#		#vr_log_info("cloud_distance " + str(m1)+ ","+ str(m2))
		minsof=min(m1,m2)
	return minsof
var m=0
func cldd(a,b,start):
	var matched=[]
#	#vr_log_info("size of a= " + str(a.size()) + " b= " + str(b.size()))
	var n = min(a.size(),b.size())
	matched.resize(n)
	for j in range(matched.size()):
		matched[j]=false
	var i=start
	var sum=0
	while true:
		var u=-1;
		var _min=INF
		for j in range(0,matched.size()):
			if matched[j]==false:
				var d = distance(a[i][0],b[j][0])
				if d<_min:
					_min=d
					u=j
		matched[u]=true
		var w= 1-(((i-start+n)%n))/n
		sum += w*_min
		i = (i + 1) % n
		if i==start:
			break
	
#	#vr_log_info("cloud_calculation for m"+str((m%2)+1)+" = "+str(sum))
	m+=1
	return sum
func distance(a,b):
	return (sqrt(pow(b.x-a.x,2)+pow(b.y-a.y,2)+pow(b.z-a.z,2)))
#############################################################################
#savingstuff
#############################################################################
var save_p_c_data = "user://p_c_data.dat"
func save_data(var data = null, var path = null):
	var file = File.new()
	var error = file.open(path, File.WRITE)
	vr.log_info("file is " +str(error))
	if error == OK:
		vr.log_info("saving data " +str(data))
		file.store_var(data)
		file.close()
func load_p_c_data(var path = save_p_c_data):
	var file = File.new()
	var p_c_data = null
	vr.log_info(str(file.file_exists(path)))
	if file.file_exists(path):
		var error = file.open(path, File.READ)
		vr.log_info("file is" +str(error))
		if error == OK:
			p_c_data = file.get_var()
			vr.log_info("loaded data " +str(p_c_data))
			file.close()
	return p_c_data
func clear_p_c_data(var path = save_p_c_data):
	save_data([],path)
	vr.log_info("deleted ,p_c is now "+str(p_c))

