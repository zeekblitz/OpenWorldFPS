extends Node3D

var PARTITION = preload("res://terrain/clipmap/clipmap_partition.tscn")
@export var distance:int = 8

@export var player_character:Node3D

var length = ProjectSettings.get_setting("shader_globals/clipmap_partition_length").value

func _ready():
	var terrain = get_parent()
	var texture = terrain.texture
	await texture.changed
	
	for x in range(-distance, distance+1):
		for z in range(-distance, distance+1):
			var partition = PARTITION.instantiate()
			
			partition.texture = texture
			partition.x = x
			partition.z = z
			
			add_child(partition)
	
func _physics_process(delta):
	global_position = player_character.global_position.snapped(Vector3.ONE * length) * Vector3(1,0,1)
	RenderingServer.global_shader_parameter_set("clipmap_position",global_position)
	pass
