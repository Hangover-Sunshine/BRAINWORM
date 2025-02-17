extends Node2D

signal unpause

@onready var menu_pause = $MenuPause
@onready var menu_settings = $MenuSettings
@onready var animplayer = $HubPause_AnimPlayer

func _ready():
	animplayer.play("ToPause")
	handle_signals()
##

func handle_signals():
	menu_pause.pause_to_game.connect(to_game)
	menu_pause.pause_to_settings.connect(to_settings)
	menu_settings.settings_to_main.connect(to_pause)
	menu_pause.pause_to_main.connect(to_load)
	Verho.connect("loaded_scene", to_free)

func to_game():
	emit_signal("unpause")
##

func to_pause():
	animplayer.play("ToPause")

func to_settings():
	animplayer.play("ToSettings")

func to_load():
	Verho.change_scene("scenes/menus/hub_menu", "", "BlackFade")

func to_free(_scene_name):
	self.queue_free()
##

