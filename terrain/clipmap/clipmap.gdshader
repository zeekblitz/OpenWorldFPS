shader_type spatial;
//render_mode wireframe;

uniform sampler2D heightmap;

global uniform float amplitude;
global uniform vec3 clipmap_position;
global uniform float clipmap_partition_length;
global uniform float lod_step;

varying vec2 normalmap_position;
varying vec3 dev_albedo;

varying vec3 vert;

float true_round(float value){
	return floor(value + 0.5);
}

float get_height(vec3 world_vertex){
	vec2 heightmap_position  = (world_vertex.xz + 0.5)/float(textureSize(heightmap,0).x);
	return texture(heightmap, heightmap_position ).r * amplitude;
}

vec3 get_normal(vec3 vertex, float adjacent_distance){
	vec3 west_vert = vertex + vec3(adjacent_distance, 0, 0);
	west_vert.y = get_height(west_vert);
	vec3 north_vert = vertex + vec3(0, 0, adjacent_distance);
	north_vert.y = get_height(north_vert);
	return normalize(
		cross(
			north_vert - vertex,
			west_vert - vertex
		)
	);
}

vec3 to_normalmap(vec3 n){
	n*=vec3(1.0,1.0,-1.0);
	n = n/2.0+0.5;
	n = vec3(n.x,n.z,n.y);
	return n;
}

void vertex(){
	dev_albedo = vec3(1);
	
	vec3 world_vertex = VERTEX + MODEL_MATRIX[3].xyz;
	normalmap_position = (world_vertex.xz + 0.5) / 
							float(textureSize(heightmap,0).x);
	VERTEX.y = get_height(world_vertex);
	
	vec3 clipmap_vertex = world_vertex - clipmap_position;
	float lod = true_round(max(abs(clipmap_vertex.x), 
				abs(clipmap_vertex.z))/clipmap_partition_length) * lod_step;
	
	float subdivision_length = min(pow(2,lod), clipmap_partition_length);
	
	vec3 fraction = 
		fract((VERTEX + clipmap_partition_length / 2.0) / subdivision_length);
	
	//if (fraction.x == 0.5){
		//dev_albedo = vec3(1,0,0);
		//VERTEX.y = mix(
			//get_height(world_vertex - vec3(fraction.x * subdivision_length, 0, 0)), 
			//get_height(world_vertex + vec3((1.0-fraction.x) * subdivision_length, 0, 0)), 
			//fraction.x
		//);
	//}
	//
	//if (fraction.z == 0.5){
		//dev_albedo = vec3(0,0,1);
		//VERTEX.y = mix(
			//get_height(world_vertex - vec3(0, 0, fraction.z * subdivision_length)), 
			//get_height(world_vertex + vec3(0, 0, (1.0-fraction.z) * subdivision_length)), 
			//fraction.z
		//);
	//}
	
	VERTEX.y = mix(
		mix(
			get_height(world_vertex - vec3(fraction.x * subdivision_length, 0, 0)), 
			get_height(world_vertex + vec3((1.0-fraction.x) * subdivision_length, 0, 0)), 
			fraction.x
		), 
		mix(
			get_height(world_vertex - vec3(0, 0, fraction.z * subdivision_length)), 
			get_height(world_vertex + vec3(0, 0, (1.0-fraction.z) * subdivision_length)), 
			fraction.z
		), 
		ceil(fraction.z)
	);
	
	//normalize(VERTEX);
	
	
	//NORMAL = get_normal(VERTEX, float(subdivision_length));
	vert = world_vertex;
}

void fragment() {
	vec3 interpolated_vert = vert;
	interpolated_vert.y = get_height(vert);
	vec3 normal = get_normal(interpolated_vert, 1.0);
	NORMAL_MAP = to_normalmap(normal);
	//NORMAL_MAP = texture(normalmap,normalmap_position).rgb;
	//ALBEDO = dev_albedo;
}
