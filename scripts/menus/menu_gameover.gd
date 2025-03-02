extends Control

signal gameover_to_game
signal gameover_to_main

@onready var cutscene_over : bool = false

@onready var win_title = $GameOver_MC/GameOver_VBox/Text_Vbox/Win_Title
@onready var lose_title = $GameOver_MC/GameOver_VBox/Text_Vbox/Lose_Title
@onready var win_text = $GameOver_MC/GameOver_VBox/Text_Vbox/Win_VBox
@onready var lose_text = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox
@onready var stats_vbox = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox

@onready var caption0 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption0
@onready var caption1 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption1
##@onready var caption2 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption2
##@onready var caption3 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption3
##@onready var caption4 = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox/Caption4

@onready var mc = $GameOver_MC
@onready var background = $Background
@onready var vignette = $Filter_Vignette_Overall
@onready var number_stage = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/Number_Stage
@onready var number_neuron = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Neuron/Number_Neuron
@onready var number_macs = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Macs/Number_Macs
@onready var number_tissue = $GameOver_MC/GameOver_VBox/Text_Vbox/Stats_Vbox/HBox_Stats/VBox_Tissue/Number_Tissue


##var curr_fact
##var curr_intro = 4 #I'm to lazy to figure out a better way to write this
##var total_fact = 30
##var fact_start: Array = ["Fun fact: ","Did you know...","Hey, guess what?","Fun factoid: "]
var encourage: Array = [
	"Don't let this worm its way into your head!",
	"Shake off those brain bugs and try again!",
	"Wriggle your way to victory next time!",
	"No brain freeze, just brain tease—try again!",
	"This worm's got nothing on you—go again!",
	"Keep digging—you're close!",
	"Don't let this one burrow too deep—go again!",
	"One more try to outsmart the squirmy foe!",
	"A little brain squiggle won't stop you!",
	"Stay sharp! You'll outwit it next time!"
]

func _ready():
	GlobalSignals.connect("game_scores", _on_recv_game_scores)
##

func to_lose():
	mc.add_theme_constant_override("margin_left", -180)
	##curr_fact = randi() % total_fact
	background.visible = false
	vignette.visible = false
	lose_title.visible = true
	lose_text.visible = true
	caption0.visible = true
	caption0.text = encourage[randi() % encourage.size()]
	##caption1.text = lose_text.fact_start[curr_fact]
	##caption2.text = lose_text.fact_mid[curr_fact]
	##caption3.text = lose_text.fact_end[curr_fact]
	##caption4.text = lose_text.fact_sources[curr_fact]
	win_title.visible = false
	win_text.visible = false
	stats_vbox.visible = false
##

func to_win():
	_on_recv_game_scores(PlayerPrefs.Neurons, PlayerPrefs.Macs, PlayerPrefs.Tissue, PlayerPrefs.GameTime)
	$AP_Newspaper.play("Newspaper")
	mc.add_theme_constant_override("margin_left", 60)
	background.visible = true
	vignette.visible = true
	win_title.visible = true
	win_text.visible = true
	lose_title.visible = false
	lose_text.visible = false
	caption0.visible = false
	stats_vbox.visible = true
##

func _on_again_button_pressed():
	gameover_to_game.emit()
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))
##

func _on_leave_button_pressed():
	gameover_to_main.emit()
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))
##

func _on_recv_game_scores(neurons:int, macs:int, tissue:int, time:int):
	var score:int = neurons + macs * 2 + tissue * 5
	
	# NOTE: Magic number -- 2 minutes or 120,000 ms
	var past_time_lose_bonus:int = 2 * 60 * 1000
	var time_modifier = past_time_lose_bonus / time
	
	if background.visible:
		score += 10000 * time_modifier
	##
	
	number_stage.text = "%03d" % score
	number_neuron.text = "%02d" % neurons
	number_macs.text = "%02d" % macs
	number_tissue.text = "%02d" % tissue
##

func _on_mouse_entered():
	SoundManager.play_varied("ui", "hover", randf_range(0.8, 1.1))
##

func play_newspaper_sound():
	SoundManager.play("ui", "newspaper")
##

func play_win_song():
	MusicManager.play("OST", "drunk_elephants")
##

func play_norm_song():
	MusicManager.play("OST", "space_jazz")
##

func _input(event):
	if event.is_pressed() and cutscene_over == true:
		cutscene_over = false
		$AP_Newspaper.play("Newspaper_Fade")
		$Prompt.visible = false
		$Prompt/AP_Flash.stop()

func _on_ap_newspaper_animation_finished(anim_name):
	if anim_name == "Newspaper":
		cutscene_over = true
		$Prompt.visible = true
		$Prompt/AP_Flash.play("Flash")
