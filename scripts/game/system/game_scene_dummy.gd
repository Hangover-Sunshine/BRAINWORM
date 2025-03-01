extends Node2D

@onready var game_board = $GameControl/Layout_Game
@onready var game_control = $GameControl

func _ready():
	$Camera.zoom = Vector2(0.2, 0.2)
	$ZoomControl.play("zoom_in")
	
	if MusicManager.is_playing("OST", "space_jazz") == false:
		MusicManager.play("OST", "space_jazz")
	##
	
	game_control.initialize_board()
##

func hide_ui():
	game_board.hide_ui()
##

func camera_in_place():
	GlobalSignals.emit_signal("game_status", false)
	game_control.initialize_ui()
##

func game_restarting():
	get_tree().paused = false
	$ZoomControl.play("zoom_out_go")
##

func freeze():
	get_tree().paused = true
##

func countdown():
	game_control.countdown()
##
