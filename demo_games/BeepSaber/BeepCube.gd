extends Spatial

var _note;

onready var _anim = $CubeMeshOrientation/CubeMeshAnimation/AnimationPlayer;
onready var _cube_mesh_orientation : Spatial = $CubeMeshOrientation;
onready var _mesh_instance : MeshInstance = $CubeMeshOrientation/CubeMeshAnimation/BeepCube_Mesh;
var _mesh : Mesh = null;
var _mat : SpatialMaterial = null;

func _ready():
	_mesh = _mesh_instance.mesh;
	_mat = _mesh_instance.mesh.surface_get_material(0);
	
	_anim.play("Spawn");

func duplicate_create(color : Color):
	var mi = $CubeMeshOrientation/CubeMeshAnimation/BeepCube_Mesh;
	_mat = mi.mesh.surface_get_material(0).duplicate(true);
	_mat.albedo_color = color;
	mi.mesh = mi.mesh.duplicate();
	mi.mesh.surface_set_material(0, _mat);
	_mesh = mi.mesh;


