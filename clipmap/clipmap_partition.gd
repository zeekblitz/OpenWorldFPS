extends MeshInstance3D

var x = 0
var z = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var texture = NoiseTexture2D.new()
	texture.seamless = true
	var noise = FastNoiseLite.new()
	noise.seed = ProjectSettings.get_setting("shader_globals/seed").value
	texture.noise = noise
	#await texture.changed
	print("part x = %d z = %d" % [x, z])
	var material : ShaderMaterial = self.get_active_material(0)
	material.set_shader_parameter("heightmap", texture)
	
	var length = ProjectSettings.get_setting("shader_globals/clipmap_partition_length").value
	var lod_step = ProjectSettings.get_setting("shader_globals/lod_step").value
	
	mesh = PlaneMesh.new()
	mesh.size = Vector2.ONE * length
	
	position = Vector3(x,0,z) * length
	
	var lod = max(abs(x),abs(z)) * lod_step
	var subdivision_length = pow(2,lod)
	var subdivides = max(length/subdivision_length - 1, 0)
	mesh.subdivide_width = subdivides
	mesh.subdivide_depth = subdivides
	
	
	
