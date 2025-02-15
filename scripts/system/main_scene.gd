extends Node

@onready var curr_scene = $DummyStart

func _ready():
	MusicManager.loaded.connect(on_music_manager_loaded)
##

func on_music_manager_loaded():
	Verho._curr_scene = curr_scene
	# 					new_scene:String, library:String, transition:String
	Verho.change_scene("scenes/menus/hub_menu", "", "BlackFade")
##
