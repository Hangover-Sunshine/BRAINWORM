extends Node2D
class_name CutsceneManager

signal cutscene_started
#signal cutscene_finished

func _ready():
	GlobalSignals.connect("cutscene_interrupted", _on_cutscene_interrupted)
##

## Overload if you want load-in behavior to be customized.
func initialize():
	pass
##

## Base implementation for when the cutscene is finished.
func _emit_cutscene_finished():
	GlobalSignals.emit_signal("cutscene_finished")
##

func _on_cutscene_interrupted():
	pass
##
