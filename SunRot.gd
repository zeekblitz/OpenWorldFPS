extends DirectionalLight3D

func _process(delta):
	self.rotate_x(0.1 * delta)
