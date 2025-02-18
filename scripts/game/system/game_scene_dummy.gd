extends Node2D

@onready var game_board = $GameControl/Layout_Game
@onready var game_control = $GameControl

var stage:int = 0
var game_data:Dictionary = {}

func _ready():
	$Camera.zoom = Vector2(0.2, 0.2)
	$ZoomControl.play("zoom_in")
	
	game_data["snake"] = []
	game_data["dir"] = Vector2i(1, 0)
	game_data["flesh"] = 0
	game_data["macs"] = 0
	game_data["tissue"] = 0
##

func _input(event):
	# NOTE: Test win
	if event.is_action_pressed("cutscene_skip"):
		$ZoomControl.play("zoom_out")
	##
	
	# NOTE: Test lose
	if event.is_action_pressed("down"):
		GlobalSignals.emit_signal("player_died")
	##
##

func _save():
	pass
##

func _load():
	pass
##

func camera_in_place():
	GlobalSignals.emit_signal("game_status", false)
	game_control.initialize_board(game_data, stage)
##

func game_won():
	GlobalSignals.emit_signal("game_status", true)
##

func game_restarting():
	$ZoomControl.play("zoom_out_go")
##
