extends Node2D
class_name CutsceneManager

@export var TimeToStartCutscene:float = 1.5

var _cutscene_start:Timer

func _ready():
	_cutscene_start = Timer.new()
	_cutscene_start.one_shot = true
	_cutscene_start.timeout.connect(_play_cutscene)
	add_child(_cutscene_start)
	_cutscene_start.start(TimeToStartCutscene)
	GlobalSignals.connect("cutscene_interrupted", _on_cutscene_interrupted)
##

## Base implementation for when the cutscene is finished.
func _emit_cutscene_finished():
	GlobalSignals.emit_signal("cutscene_finished")
##

func _play_cutscene():
	pass
##

func _on_cutscene_interrupted():
	pass
##
