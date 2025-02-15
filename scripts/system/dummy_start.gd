extends Control

func _ready():
	Verho.connect("loaded_scene", _loaded_scene)
##

func _loaded_scene(_scene_name):
	queue_free()
##
