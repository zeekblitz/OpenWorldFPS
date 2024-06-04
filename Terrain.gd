extends StaticBody3D

var texture : NoiseTexture2D
var noise : FastNoiseLite

func _init():
	texture = NoiseTexture2D.new()
	texture.seamless = true
	noise = FastNoiseLite.new()
	noise.seed = ProjectSettings.get_setting("shader_globals/seed").value
	texture.noise = noise
