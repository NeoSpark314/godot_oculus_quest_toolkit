tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("vr", "res://addons/OQ_Toolkit/vr_autoload.gd")


func _exit_tree():
	remove_autoload_singleton("vr")
