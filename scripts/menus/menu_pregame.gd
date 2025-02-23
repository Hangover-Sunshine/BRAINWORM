extends Control

signal pregame_to_game
signal pregame_to_main
@onready var ap_pg = $AP_Pics
@onready var pg = 1

func _on_tutorial_button_pressed():
	pregame_to_game.emit()

func _on_back_button_pressed():
	pregame_to_main.emit()

func _on_skip_button_pressed():
	pg = 6
	ap_pg.play(str(pg))

func _on_increase_button_pressed():
	if pg != 6:
		pg += 1
		ap_pg.play(str(pg))
	else:
		pg = 1
		ap_pg.play(str(pg))

func _on_decrease_button_pressed():
	if pg != 1:
		pg -= 1
		ap_pg.play(str(pg))
	else:
		pg = 6
		ap_pg.play(str(pg))

func _on_skip_check_toggled(toggled_on):
	GlobalSettings.SkipCutscene = toggled_on
##
