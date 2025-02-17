extends Node2D

func _ready():
	GlobalSignals.emit_signal("game_status", false)
## 

func _input(event):
	# NOTE: Test win
	if event.is_action_pressed("cutscene_skip"):
		GlobalSignals.emit_signal("game_status", true)
	##
	
	# NOTE: Test lose
	if event.is_action_pressed("down"):
		pass
	##
##
