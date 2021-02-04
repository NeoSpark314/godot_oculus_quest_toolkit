extends "res://OQ_Toolkit/OQ_ARVRController/scripts/Feature_ControllerModel.gd"


func _process(delta):
	update_buttons()
	._process(delta)

# this function handles updating the positions of the buttons on the controller model
#  ideally the digital buttons would be updated on a signal so they wouldn't need to be checked every delta
#  but to avoid modififying existing architecture it is handled by the controller's input array
# 
func update_buttons():
	

