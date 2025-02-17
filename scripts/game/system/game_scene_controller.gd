extends Node2D

@export var Cutscenes:Array[PackedScene]
@export var GameScene:PackedScene

@onready var internal_fade_controller = $InternalFadeController
@onready var main_camera = $MainCamera

var _game_scene

var _curr_level:int = 0

var _curr_cutscene:CutsceneManager
var _in_cutscene:bool = false
var _can_pause:bool = false

func _ready():
	GlobalSignals.connect("cutscene_finished", _on_cutscene_finished)
	GlobalSignals.connect("game_status", _recv_game_status)
	
	# Load the cut scene
	_curr_cutscene = Cutscenes[_curr_level].instantiate()
	add_child(_curr_cutscene)
	internal_fade_controller.play("fade_in")
	main_camera.enabled = false
##

func _input(event):
	if _can_pause and event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
	##
	
	if _in_cutscene and event.is_action_pressed("cutscene_skip"):
		GlobalSignals.emit("cutscene_interrupted")
		_in_cutscene = false
	##
##

func _on_cutscene_finished():
	_in_cutscene = false
	internal_fade_controller.play("fade_out")
##

func _recv_game_status(is_over:bool):
	_can_pause = !is_over # True means the game is done, False means it's beginning
	
	if is_over:
		_curr_level += 1
		internal_fade_controller.play("fade_out")
	##
##

func fade_out_finished():
	if _curr_cutscene != null:
		main_camera.enabled = true
		_curr_cutscene.queue_free()
		_game_scene = GameScene.instantiate()
		add_child(_game_scene)
	else:
		main_camera.enabled = true
		_game_scene.queue_free()
		_curr_cutscene = Cutscenes[_curr_level].instantiate()
		add_child(_curr_cutscene)
	##
	internal_fade_controller.play("fade_in")
##

func fade_in_finished():
	pass
##
