extends Control

signal pregame_to_game
signal pregame_to_main

@onready var difficulty_label = $Pregame_MC/Pregame_VBox/Button_HBox/Button_PG_VBox/PG_HBox/ExtraButtons_VBox/HBox_PG2/Difficulty_Label
@onready var difficulty : Array = ["Beginner","Novice","Expert"]
@onready var curr_diff = 0

@onready var ap_pg = $AP_Pics
@onready var pg = 1

func _ready():
	difficulty_label.text = difficulty[curr_diff]

func _on_tutorial_button_pressed():
	pregame_to_game.emit()
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))

func _on_back_button_pressed():
	pregame_to_main.emit()
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))

func _on_skip_button_pressed():
	pg = 6
	ap_pg.play(str(pg))
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))

func _on_increase_button_pressed():
	if pg != 6:
		pg += 1
		ap_pg.play(str(pg))
	else:
		pg = 1
		ap_pg.play(str(pg))
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))

func _on_decrease_button_pressed():
	if pg != 1:
		pg -= 1
		ap_pg.play(str(pg))
	else:
		pg = 6
		ap_pg.play(str(pg))
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))

func _on_skip_check_toggled(toggled_on):
	GlobalSettings.SkipCutscene = toggled_on
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))
##

func _on_mouse_entered():
	SoundManager.play_varied("ui", "hover", randf_range(0.8, 1.1))
##

func _on_left_button_pressed():
	curr_diff -= 1
	if curr_diff < 0:
		curr_diff = difficulty.size() - 1
	GlobalSettings.DifficultyLevel = curr_diff
	difficulty_label.text = difficulty[curr_diff]
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))
##

func _on_right_button_pressed():
	curr_diff += 1
	if curr_diff >= difficulty.size():
		curr_diff = 0
	GlobalSettings.DifficultyLevel = curr_diff
	difficulty_label.text = difficulty[curr_diff]
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))
##
