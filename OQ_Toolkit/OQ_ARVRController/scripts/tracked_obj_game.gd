extends Position3D
#use this one for final game in headset 
#cuts out the functionality to add any templates
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
	IDLE}
var track_button
var user_state=ACTION.IDLE
var controller : ARVRController = null
enum TRACKING{Buttons,Velocity}
var Tracking_type
var ignore_Y_orientation
var action_manager
var point_array=[]
var speed_threshold_start :float  = 1
var speed_threshold_stop :float  = 1

func _ready():
	print("ready")
	controller = get_parent();
	#gets parent as ARVR contoller and sets it to controller needed for button press recong
	# can be modified 
	action_manager = controller.get_parent().get_parent().get_node("action_manager")
	if controller==vr.leftController:
		transform.origin=Vector3(-0.02,-0.045,0.03)
	elif controller==vr.rightController:
		transform.origin=Vector3(0.02,-0.045,0.03)
	p_c = load_p_c_data()
	vr.log_info("loaded templates are "+ str(p_c))
func _physics_process(_delta):
	var click = controller._button_pressed(track_button)
	var release = controller._button_just_released(track_button)
	var controller_vel = controller.get_linear_velocity().length()
	match user_state:
		ACTION.IDLE:
			if(Tracking_type ==TRACKING.Buttons and click) or (Tracking_type ==TRACKING.Velocity and controller_vel>=speed_threshold_start):
				user_state=ACTION.RECOGNIZE
		ACTION.RECOGNIZE:
			point_array.append(make_point(global_transform,controller.controller_id))
			if(Tracking_type ==TRACKING.Buttons and release) or (Tracking_type ==TRACKING.Velocity and controller_vel<speed_threshold_stop):
				var result=recognize(point_array)
				#vr_log_info("result"+str(result[0])+" score "+str(result[1]))
				action_manager.recognise_action(result,controller.controller_id)
				point_array.clear()
				user_state=ACTION.IDLE
				#stop tracking ,recogize pool
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
#load templates 
#############################################################################
var save_p_c_data = "user://p_c_data.dat"
func load_p_c_data():
	var file = File.new()
	var p_c_data = null
	if file.file_exists(save_p_c_data):
		var error = file.open(save_p_c_data, File.READ)
		print(error)
		if error == OK:
			p_c_data = file.get_var()
			file.close()
	return p_c_data

