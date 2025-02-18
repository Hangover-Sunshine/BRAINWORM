extends Node2D

@onready var game_board = $Layout_Game

var stage:int = 0
var game_data:Dictionary = {}

func _ready():
	$Camera.zoom = Vector2(0.2, 0.2)
	$ZoomControl.play("zoom_in")
	
	game_data["snake"] = []
	game_data["position"] = 0
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
		#$ZoomControl.play("zoom_out")
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
	game_board.initialize(game_data, stage)
##

func game_won():
	GlobalSignals.emit_signal("game_status", true)
##

func game_restarting():
	$ZoomControl.play("zoom_out_go")
##
