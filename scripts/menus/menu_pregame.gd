extends Control

signal pregame_to_game
signal pregame_to_main
@onready var ap_pg = $AP_Pics
@onready var pg = 1

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
