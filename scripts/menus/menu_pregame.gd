extends Control

signal pregame_to_game
signal pregame_to_main

@onready var pg = $Pregame_MC/Pregame_Sheet

func _on_tutorial_button_pressed():
	pregame_to_game.emit()

func _on_back_button_pressed():
	pregame_to_main.emit()

func _on_skip_button_pressed():
	pg.frame = pg.sprite_frames.get_frame_count("default") - 1

func _on_increase_button_pressed():
	if pg.frame != pg.sprite_frames.get_frame_count("default") - 1:
		pg.frame += 1
	else:
		pg.frame = 0

func _on_decrease_button_pressed():
	if pg.frame != 0:
		pg.frame -= 1
	else:
		pg.frame = pg.sprite_frames.get_frame_count("default") - 1

func _on_skip_check_toggled(toggled_on):
	GlobalSettings.SkipCutscene = toggled_on
##
