tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("vr", "res://addons/OQ_Toolkit/vr_autoload.gd")
	
	add_custom_type("OQ_ARVROrigin", "ARVROrigin", load("res://addons/OQ_Toolkit/OQ_ARVROrigin/scripts/OQ_ARVROrigin.gd"), load("res://addons/OQ_Toolkit/oqt_icon.png"))
	add_custom_type("OQ_ARVRCamera", "ARVRCamera", load("res://addons/OQ_Toolkit/OQ_ARVRCamera/scripts/OQ_ARVRCamera.gd"), load("res://addons/OQ_Toolkit/oqt_icon.png"))
	add_custom_type("OQ_ARVRController", "ARVRController", load("res://addons/OQ_Toolkit/OQ_ARVRController/scripts/OQ_ARVRController.gd"), load("res://addons/OQ_Toolkit/oqt_icon.png"))


func _exit_tree():
	remove_autoload_singleton("vr")
	
	remove_custom_type("OQ_ARVROrigin")
