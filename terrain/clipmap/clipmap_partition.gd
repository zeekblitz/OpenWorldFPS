@tool
extends MeshInstance3D
class_name clipmap_partition

var normal : Vector3 = Vector3(0,1,0)

var texture : NoiseTexture2D
var x = 0
var z = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("part x = %d z = %d" % [x, z])
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
	
	

func regenerate_mesh(planet_data : PlanetData):
	# array to hold all of the other arrays
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertex_array := PackedVector3Array()
	var uv_array := PackedVector2Array()
	var normal_array := PackedVector3Array()
	var index_array := PackedInt32Array()
	
	var resolution := planet_data.resolution
	var num_vertices : int = resolution * resolution
	var num_indices : int = (resolution - 1) * (resolution - 1) * 6
	
	normal_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	vertex_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	var tri_index : int = 0
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	for y in range(resolution):
		for c in range(resolution):
			var i : int = c + y * resolution
			var percent := Vector2(c,y) / (resolution - 1)
			var pointOnUnitCube : Vector3 = normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
			var pointOnUnitSphere := pointOnUnitCube.normalized() * planet_data.radius
			vertex_array[i] = pointOnUnitSphere
			if c != resolution-1 and y != resolution-1:
				index_array[tri_index+2] = i
				index_array[tri_index+1] = i + resolution+1
				index_array[tri_index] = i + resolution
				
				index_array[tri_index+5] = i
				index_array[tri_index+4] = i+1
				index_array[tri_index+3] = i + resolution+1
				tri_index += 6
	
	for a in range(0, index_array.size(), 3):
		var b : int = a + 1
		var c : int = a + 2
		
		var ab : Vector3 = vertex_array[index_array[b]] - vertex_array[index_array[a]]
		var bc : Vector3 = vertex_array[index_array[c]] - vertex_array[index_array[b]]
		var ca : Vector3 = vertex_array[index_array[a]] - vertex_array[index_array[c]]
		
		var cross_ab_bc : Vector3 = ab.cross(bc) * -1.0
		var cross_bc_ca : Vector3 = bc.cross(ca) * -1.0
		var cross_ca_ab : Vector3 = ca.cross(ab) * -1.0
		
		normal_array[index_array[a]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[b]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[c]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		
	for i in range(normal_array.size()):
		normal_array[i] = normal_array[i].normalized()
		
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	
	call_deferred("_update_mesh", arrays)

func _update_mesh(arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh
