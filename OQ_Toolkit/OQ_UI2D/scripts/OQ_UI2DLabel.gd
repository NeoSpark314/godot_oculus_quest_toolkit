extends Spatial

export var text = "I am a Label\nWith a new line"
export var margin = 16;
export var size_scale = 1.0;



onready var ui_label : Label = $Viewport/CenterContainer/Label
onready var ui_container : CenterContainer = $Viewport/CenterContainer
onready var ui_viewport : Viewport = $Viewport
var ui_mesh : PlaneMesh = null;

func _ready():
	ui_mesh = $MeshInstance.mesh;
	set_text(text);
	


func set_text(t):
	text = t;
	ui_label.set_text(text);
	var size = ui_label.get_minimum_size();
	
	var res = Vector2(size.x + margin * 2, size.y + margin * 2);
	
	ui_container.set_size(res);
	ui_viewport.set_size(res);
	
	var aspect = res.x / res.y;
	
	ui_mesh.size.x = size_scale * res.x * vr.UI_PIXELS_TO_METER;
	ui_mesh.size.y = size_scale * res.y * vr.UI_PIXELS_TO_METER;
	
