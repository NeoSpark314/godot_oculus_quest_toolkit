extends Spatial

export var text = "I am a Label\nWith a new line"
export var margin = 16;
export var size_scale = 1.0;

export var billboard = false;

#export var line_to_parent = false;



onready var ui_label : Label = $Viewport/CenterContainer/Label
onready var ui_container : CenterContainer = $Viewport/CenterContainer
onready var ui_viewport : Viewport = $Viewport
var ui_mesh : PlaneMesh = null;

func _ready():
	ui_mesh = $MeshInstance.mesh;
	set_text(text);
	
	if (billboard):
		$MeshInstance.mesh.surface_get_material(0).set_billboard_mode(SpatialMaterial.BILLBOARD_FIXED_Y);
	
	#if (line_to_parent):
		#var p = get_parent();
		#$LineMesh.visible = true;
		#var center = (global_transform.origin + p.global_transform.origin) * 0.5;
		#$LineMesh.global_transform.origin = center;
		#$LineMesh.look_at_from_position()
		
		
	


func set_text(t):
	text = t;
	ui_label.set_text(text);
	var size = ui_label.get_minimum_size();
	
	var res = Vector2(size.x + margin * 2, size.y + margin * 2);
	
	ui_container.set_size(res);
	ui_viewport.set_size(res);
	
	#var aspect = res.x / res.y;
	
	ui_mesh.size.x = size_scale * res.x * vr.UI_PIXELS_TO_METER;
	ui_mesh.size.y = size_scale * res.y * vr.UI_PIXELS_TO_METER;
	
