extends Node

var actions_list = {"template_1":funcref(self,"action_a"),
					"template_2":funcref(self,"action_b"),
					"template_3":funcref(self,"action_c")}
# this is the actions list , _key_ is the name of the action ,
# which can be set in dev mode , needs to be manually set here later , names must match
# the _value_ is a reference to a function by name ,  
var projectile = []
# preload associated projectiles in projectile list as per function order
var action_stack=[["null",0]]

func recognise_action(result,controller):
	if result[0]!="no match":
		action_stack.push_back([result[0],controller])
#		vr.log_info("stack is "+str(action_stack) +" "+ str(action_stack.size()))
	vr.log_info("recognize action")
	for i in range(1,action_stack.size()):
		if action_stack[i][0] == action_stack[i-1][0] and action_stack[i][1]+action_stack[i-1][1] == 3:
			execute_action(action_stack[i])
#			vr.log_info("combination")
#			vr.log_info("stack is "+str(action_stack))
#			vr.log_info("found same name " + str(action_stack[i][0]) + " with controllers " + str(action_stack[i][1]) +" and "+str(action_stack[i+1][1])) 
#			vr.log_info("popping")
			action_stack.pop_back()
			action_stack.pop_back()
#			vr.log_info("popped")
#			vr.log_info(" left "+str(action_stack))
		else:
			if action_stack[i][1] == vr.leftController.controller_id:
#				vr.log_info("single left")
#				vr.log_info("stack is "+str(action_stack))
				execute_action(action_stack[i])
#				vr.log_info("popping")
				action_stack.pop_back()
#				vr.log_info(" left "+str(action_stack))
#				vr.log_info("popped")
			elif action_stack[i][1] == vr.rightController.controller_id:
#				vr.log_info("single right")
#				vr.log_info("stack is "+str(action_stack))
				execute_action(action_stack[i])
#				vr.log_info("popping")
				action_stack.pop_back()
#				vr.log_info(" left "+str(action_stack))
#				vr.log_info("popped")

func execute_action(action):
	if !actions_list.empty():
		if actions_list.has(str(action[0])):
			actions_list[str(action[0])].call_func(action[1])
			# calls relevant action , by finding name and passes contoller id / ids 
	else:
		vr.log_info("actions list or projectiles is empty")


func action_a(controller):
	vr.log_info("template 1")
	pass
func action_b(controller):
	vr.log_info("template 2")
	pass
func action_c(controller):
	vr.log_info("template 3")
	pass
