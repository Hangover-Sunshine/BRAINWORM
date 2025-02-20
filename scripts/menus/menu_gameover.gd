extends Control

signal gameover_to_game
signal gameover_to_main

@onready var win_title = $GameOver_MC/GameOver_VBox/Text_Vbox/Win_Title
@onready var lose_title = $GameOver_MC/GameOver_VBox/Text_Vbox/Lose_Title
@onready var win_text = $GameOver_MC/GameOver_VBox/Text_Vbox/Win_VBox
@onready var fail_text = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox
@onready var background = $Background
@onready var vignette = $Filter_Vignette_Overall
@onready var number_stage = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/Number_Stage
@onready var number_neuron = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Neuron/Number_Neuron
@onready var number_macs = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Macs/Number_Macs
@onready var number_tissue = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Tissue/Number_Tissue

func _ready():
	GlobalSignals.connect("game_scores", _on_recv_game_scores)
##

func to_lose():
	background.visible = false
	vignette.visible = false
	lose_title.visible = true
	fail_text.visible = false #keeping off since player can lose a lot
	win_title.visible = false
	win_text.visible = false
##

func to_win():
	background.visible = true
	vignette.visible = true
	win_title.visible = true
	win_text.visible = true
	lose_title.visible = false
	fail_text.visible = false
##

func _on_again_button_pressed():
	gameover_to_game.emit()

func _on_leave_button_pressed():
	gameover_to_main.emit()
##

func _on_recv_game_scores(neurons:int, macs:int, tissue:int, time:int):
	var score:int = neurons + macs * 2 + tissue * 5
	
	# NOTE: Magic number -- 3 minutes or 180,000 ms
	var past_time_lose_bonus:int = 3 * 60 * 1000
	var time_modifier:int = past_time_lose_bonus / time
	
	if background.visible:
		score += 1000000 * time_modifier
	##
	
	number_stage.text = "%011d" % score
	number_neuron.text = "%03d" % neurons
	number_macs.text = "%03d" % macs
	number_tissue.text = "%03d" % tissue
##
