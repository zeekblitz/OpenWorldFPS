extends CollisionShape3D

@export var physics_body : Node3D

@export var template_mesh : PlaneMesh
@onready var faces = template_mesh.get_faces()
@onready var snap = Vector3.ONE * template_mesh.size.x/2

var image:Image
var size
var amplitude:float = ProjectSettings.get_setting("shader_globals/amplitude").value

func _ready():
	var terrain = get_parent()
	var texture = terrain.texture
	await texture.changed
	image = texture.get_image()
	size = image.get_width()
	update_shape()

func _physics_process(_delta):
	# if gravity is turned off, then turn off the collision shape
	self.disabled = !physics_body.gravity_enabled
	
	var player_rounded_position = physics_body.global_position.snapped(snap) * Vector3(1,0,1)
	if not global_position == player_rounded_position:
		global_position = player_rounded_position
		update_shape()
	
func update_shape():
	for i in faces.size():
		var global_vert = faces[i] + global_position
		faces[i].y = get_height(global_vert.x,global_vert.z)
	shape.set_faces(faces)

func get_height(x,z):
	return image.get_pixel(fposmod(x,size), fposmod(z,size)).r * amplitude
