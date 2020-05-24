# BeepCube is the standard cube that will get cut by the sabers
extends Spatial

var _note;

# the animation player contains the span animation that is applied to the CubeMeshAnimation node
onready var _anim = $CubeMeshOrientation/CubeMeshAnimation/AnimationPlayer;
# this is a separate Spatial for the orientation used in the game to display the cut direction
onready var _cube_mesh_orientation : Spatial = $CubeMeshOrientation;
onready var _mesh_instance : MeshInstance = $CubeMeshOrientation/CubeMeshAnimation/BeepCube_Mesh;

# we store the mesh here as part of the BeepCube for easier access because we will
# reuse it when we create the cut cube pieces
var _mesh : Mesh = null;
var _mat : SpatialMaterial = null;

func _ready():
	_mesh = _mesh_instance.mesh;
	_mat = _mesh_instance.mesh.surface_get_material(0);
	# play the spawn animation when this cube enters the scene
	_anim.play("Spawn");

func duplicate_create(color : Color):
	var mi = $CubeMeshOrientation/CubeMeshAnimation/BeepCube_Mesh;
	_mat = mi.mesh.surface_get_material(0).duplicate(true);
	_mat.albedo_color = color;
	mi.mesh = mi.mesh.duplicate();
	mi.mesh.surface_set_material(0, _mat);
	_mesh = mi.mesh;


