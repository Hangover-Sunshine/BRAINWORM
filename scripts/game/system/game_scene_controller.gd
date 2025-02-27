extends Node2D

@export var Cutscene:PackedScene
@export var GameScene:PackedScene

@onready var internal_fade_controller = $InternalFadeController
@onready var game_over = $GameOver

var _game_scene
var _win_scene

var _curr_cutscene:CutsceneManager
var _in_cutscene:bool = false
var _can_pause:bool = false
var restart:bool = false

var bus:int = -1

func _ready():
	Verho.connect("loaded_scene", _new_scene_loaded)
	GlobalSignals.connect("cutscene_finished", _on_cutscene_finished)
	GlobalSignals.connect("game_status", _recv_game_status)
	GlobalSignals.connect("game_won", _on_game_won)
	GlobalSignals.connect("player_died", _player_died)
	$PauseMenu/HubPause.connect("unpause", _unpause_game)
	
	bus = AudioServer.get_bus_index("Music")
	
	if GlobalSettings.SkipCutscene:
		_game_scene = GameScene.instantiate()
		add_child(_game_scene)
		GlobalSettings.SkipCutscene = false
		internal_fade_controller.play("fade_in")
	else:
		# Load the cut scene
		_curr_cutscene = Cutscene.instantiate()
		add_child(_curr_cutscene)
		_curr_cutscene.initialize()
		internal_fade_controller.play("fade_in")
		
		await get_tree().create_timer(3).timeout
		_in_cutscene = true
	##
##

func _input(event):
	if _can_pause and event.is_action_pressed("pause"):
		GlobalSignals.game_is_pausing.emit(!get_tree().paused)
		get_tree().paused = !get_tree().paused
		$PauseMenu.visible = get_tree().paused
		
		if get_tree().paused == false:
			_game_scene.countdown()
			_can_pause = false
		##
		
		if get_tree().paused:
			# apply filter
			AudioServer.add_bus_effect(bus, AudioEffectLowPassFilter.new())
		else:
			# remove filter
			AudioServer.remove_bus_effect(bus, 0)
		##
	##
	
	if _in_cutscene and event.is_action_pressed("cutscene_skip"):
		$CutsceneSkipTimer.start(1.5)
	elif _in_cutscene and event.is_action_released("cutscene_skip"):
		$CutsceneSkipTimer.stop()
	##
##

func _new_scene_loaded(new_scene:String):
	if new_scene != self.name:
		self.queue_free()
	##
##

func _player_died():
	_game_scene.freeze()
	_can_pause = false
	game_over.visible = true
	$GameOver/MenuGameover.to_lose()
	$GameOver/GameOverAnimPlayer.play("fade")
##

func _unpause_game():
	_can_pause = false
	_game_scene.countdown()
	
	GlobalSignals.game_is_pausing.emit(false)
	get_tree().paused = false
	$PauseMenu.visible = false
	AudioServer.remove_bus_effect(bus, 0)
##

func _on_cutscene_finished():
	_in_cutscene = false
	internal_fade_controller.play("fade_out")
##

func _recv_game_status(is_over:bool):
	_can_pause = !is_over # True means the game is done, False means it's beginning
##

func fade_out_finished():
	if _curr_cutscene != null and restart == false:
		_curr_cutscene.queue_free()
		_game_scene = GameScene.instantiate()
		add_child(_game_scene)
		internal_fade_controller.play("fade_in")
	elif _curr_cutscene == null and _win_scene == null:
		_in_cutscene = true
		_game_scene.queue_free()
		await get_tree().create_timer(1.5).timeout
		_game_scene = GameScene.instantiate()
		add_child(_game_scene)
		internal_fade_controller.play("fade_in")
	elif _curr_cutscene == null and _win_scene != null:
		_game_scene.queue_free()
		await get_tree().create_timer(1.5).timeout
		add_child(_win_scene)
		_win_scene.to_win()
		_win_scene.connect("gameover_to_game", _on_gameover_to_game)
		_win_scene.connect("gameover_to_main", _on_menu_gameover_gameover_to_main)
		internal_fade_controller.play("fade_in_white")
	##
	if restart:
		restart = false
	##
##

func _on_gameover_to_game():
	Verho.change_scene("scenes/game_control_scene", "", "BlackFade")
##

func _on_menu_gameover_gameover_to_game():
	_game_scene.game_restarting()
	game_over.visible = false
	internal_fade_controller.play("fade_out")
	$GameOver/ColorRect.color = Color("2c0917", 0)
	$GameOver/MenuGameover.modulate = Color("ffffff", 0)
##

func _on_menu_gameover_gameover_to_main():
	Verho.change_scene("scenes/menus/hub_menu", "", "BlackFade")
##

func _on_game_won():
	internal_fade_controller.play("fade_out_white")
	_win_scene = load("res://scenes/menus/menu_gameover.tscn").instantiate()
##

func _on_cutscene_skip_timer_timeout():
	GlobalSignals.emit_signal("cutscene_interrupted")
	_in_cutscene = false
##
