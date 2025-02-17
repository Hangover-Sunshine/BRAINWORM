extends Node

var curr_scene

func _ready():
	MusicManager.loaded.connect(on_music_manager_loaded)
	curr_scene = get_child(1)
	Verho.default_anim = "BlackFade"
##

func on_music_manager_loaded():
	Verho._curr_scene = curr_scene
	# 					new_scene:String, library:String, transition:String
	#Verho.change_scene("scenes/menus/hub_menu", "", "BlackFade")
##
