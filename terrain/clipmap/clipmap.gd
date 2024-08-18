@tool
extends Node3D

var length = ProjectSettings.get_setting("shader_globals/clipmap_partition_length").value
var PARTITION = preload("res://terrain/clipmap/clipmap_partition.tscn")

@export var distance:int = 8
@export var player_character:Node3D
@export var planet_data : Resource:
	set(value): 
		planet_data = value
		on_data_changed()
		if planet_data != null and not planet_data.is_connected("changed", Callable(self, "on_data_changed")):
			planet_data.connect("changed", Callable(self, "on_data_changed"))

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
			
			self.add_child(partition)
	#on_data_changed()

func _physics_process(_delta):
	global_position = player_character.global_position.snapped(Vector3.ONE * length) * Vector3(1,0,1)
	RenderingServer.global_shader_parameter_set("clipmap_position",global_position)
	#pass

func on_data_changed():
	for child in get_children():
		var face := child as clipmap_partition
		face.regenerate_mesh(planet_data)
