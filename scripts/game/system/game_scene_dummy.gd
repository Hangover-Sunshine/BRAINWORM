extends Node2D

func _ready():
	$Camera.zoom = Vector2(0.2, 0.2)
	$ZoomControl.play("zoom_in")
	GlobalSignals.emit_signal("game_status", false)
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

func game_won():
	GlobalSignals.emit_signal("game_status", true)
##

func game_restarting():
	$ZoomControl.play("zoom_out_go")
##
