extends Spatial

func set_notificaiton_text(title, text):
	var text_label = $OQ_UI2DCanvas.find_node("NotificationText_Label", true, false);
	var title_label = $OQ_UI2DCanvas.find_node("Title_Label", true, false);
	text_label.set_text(text);
	title_label.set_text(title);
	
func _physics_process(dt):
	if ((vr.button_just_pressed(vr.BUTTON.X) && vr.button_pressed(vr.BUTTON.A))
		|| (vr.button_just_pressed(vr.BUTTON.A) && vr.button_pressed(vr.BUTTON.X))):
		get_parent().remove_child(self);
		queue_free();


