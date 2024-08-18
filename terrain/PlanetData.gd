@tool
extends Resource
class_name PlanetData

@export var radius := 1.0 :
	set(value):
		radius = value
		emit_signal("changed")

@export var resolution := 10 :
	set(value):
		resolution = value
		emit_signal("changed")
