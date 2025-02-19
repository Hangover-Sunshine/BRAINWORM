extends Node2D

@export var Cutscenes:Array[PackedScene]
@export var GameScene:PackedScene

@onready var internal_fade_controller = $InternalFadeController
@onready var game_over = $GameOver

var _game_scene

var _curr_level:int = 0

var _curr_cutscene:CutsceneManager
var _in_cutscene:bool = true
var _can_pause:bool = false

func _ready():
	Verho.connect("loaded_scene", _new_scene_loaded)
	GlobalSignals.connect("cutscene_finished", _on_cutscene_finished)
	GlobalSignals.connect("game_status", _recv_game_status)
	GlobalSignals.connect("player_died", _player_died)
	$PauseMenu/HubPause.connect("unpause", _unpause_game)
	
	# Load the cut scene
	_curr_cutscene = Cutscenes[_curr_level].instantiate()
	add_child(_curr_cutscene)
	_curr_cutscene.initialize()
	internal_fade_controller.play("fade_in")
##

func _input(event):
	if _can_pause and event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		$PauseMenu.visible = get_tree().paused
	##
	
	if _in_cutscene and event.is_action_pressed("cutscene_skip"):
		GlobalSignals.emit_signal("cutscene_interrupted")
		_in_cutscene = false
	##
##

func _new_scene_loaded(new_scene:String):
	if new_scene != self.name:
		self.queue_free()
	##
##

func _player_died():
	_game_scene.freeze()
	_game_scene.hide_ui()
	#_game_scene.clear_game()
	_can_pause = false
	game_over.visible = true
	$GameOver/MenuGameover.to_lose()
	$GameOver/GameOverAnimPlayer.play("fade")
##

func _unpause_game():
	get_tree().paused = false
	$PauseMenu.visible = get_tree().paused
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
	else:
		pass
	##
##

func fade_out_finished():
	if _curr_cutscene != null:
		_curr_cutscene.queue_free()
		_game_scene = GameScene.instantiate()
		add_child(_game_scene)
	else:
		_in_cutscene = true
		_game_scene.queue_free()
		_curr_cutscene = Cutscenes[_curr_level].instantiate()
		add_child(_curr_cutscene)
		if _curr_level == 0:
			_curr_cutscene.start_close = false
		else:
			_curr_cutscene.start_close = true
		_curr_cutscene.initialize()
		##
	##
	internal_fade_controller.play("fade_in")
##

func fade_in_finished():
	pass
##

func _on_menu_gameover_gameover_to_game():
	_game_scene.game_restarting()
	game_over.visible = false
	_curr_level = 0
	internal_fade_controller.play("fade_out")
	$GameOver/ColorRect.color = Color("2c0917", 0)
	$GameOver/MenuGameover.modulate = Color("ffffff", 0)
##

func _on_menu_gameover_gameover_to_main():
	Verho.change_scene("scenes/menus/hub_menu", "", "BlackFade")
	# NOTE: let the menu take care of unpausing
##
