tool
extends Spatial

var ui_control : Control = null;

onready var viewport = $Viewport;
onready var ui_area = $UIArea;
var ui_collisionshape = null;

var ui_size = Vector2();

func _get_configuration_warning():
	if (ui_control == null): return "Need a Control node as child."
	return '';


func find_child_control():
	ui_control = null;
	for c in get_children():
		if c is Control:
			ui_control = c;
			break;

func update_size():
	ui_size = ui_control.get_size();
	if (ui_area != null):
		ui_area.scale.x = ui_size.x * vr.UI_PIXELS_TO_METER;
		ui_area.scale.y = ui_size.y * vr.UI_PIXELS_TO_METER;
	if (viewport != null):
		viewport.set_size(ui_size);


func _ready():
	if Engine.editor_hint:
		return;

	find_child_control();

	if (!ui_control):
		vr.log_warning("No UI Control element found in OQ_UI2DCanvas: %s" % get_path());
		return;

	update_size();
	
	# reparent at runtime so we render to the viewport
	ui_control.get_parent().remove_child(ui_control);
	viewport.add_child(ui_control);
	
	ui_collisionshape = $UIArea/UICollisionShape


func _process(dt):
	if !Engine.editor_hint: # not in edtior
		# if we are invisible we need to disable the collision shape to avoid interaction with the UIRayCast
		if (!is_visible_in_tree()): 
			ui_collisionshape.disabled = true;
		else:
			ui_collisionshape.disabled = false;
		return;
		


	# Not sure if it is a good idea to do this in the _process but at the moment it seems to 
	# be the easiest to show the actual canvas size inside the editor
	var last = ui_control;
	find_child_control();
	if (ui_control != null):
		if (last != ui_control || ui_size != ui_control.get_size()):
			#print("Editor update size of ", name);
			update_size();



