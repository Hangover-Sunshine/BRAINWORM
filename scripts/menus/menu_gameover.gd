extends Control

signal gameover_to_game
signal gameover_to_main

@onready var win_title = $GameOver_MC/GameOver_VBox/Text_Vbox/Win_Title
@onready var lose_title = $GameOver_MC/GameOver_VBox/Text_Vbox/Lose_Title
@onready var win_text = $GameOver_MC/GameOver_VBox/Text_Vbox/Win_VBox
@onready var fail_text = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox
@onready var caption0 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption0
@onready var caption1 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption1
@onready var caption2 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption2
@onready var caption3 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption3
@onready var caption4 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption4

@onready var mc = $GameOver_MC
@onready var background = $Background
@onready var vignette = $Filter_Vignette_Overall
@onready var number_stage = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/Number_Stage
@onready var number_neuron = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Neuron/Number_Neuron
@onready var number_macs = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Macs/Number_Macs
@onready var number_tissue = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Tissue/Number_Tissue
@onready var stats_vbox = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox

var curr_fact
var curr_intro = 4 #I'm to lazy to figure out a better way to write this
var total_fact = 30
var fact_start: Array = ["Fun fact: ","Did you know...","Hey, guess what?","Fun factoid: "]

func _ready():
	GlobalSignals.connect("game_scores", _on_recv_game_scores)
	to_win()
##

func to_lose():
	mc.add_theme_constant_override("margin_left", -180)
	curr_fact = randi() % total_fact
	background.visible = false
	vignette.visible = false
	lose_title.visible = true
	caption0.text = fact_start[randi() % curr_intro]
	caption1.text = fail_text.fact_start[curr_fact]
	caption2.text = fail_text.fact_mid[curr_fact]
	caption3.text = fail_text.fact_end[curr_fact]
	caption4.text = fail_text.fact_sources[curr_fact]
	fail_text.visible = true
	win_title.visible = false
	win_text.visible = false
	stats_vbox.visible = false
##

func to_win():
	mc.add_theme_constant_override("margin_left", 60)
	background.visible = true
	vignette.visible = true
	win_title.visible = true
	win_text.visible = true
	lose_title.visible = false
	fail_text.visible = false
	stats_vbox.visible = true
##

func _on_again_button_pressed():
	gameover_to_game.emit()
##

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
