extends Control

signal pause_to_game
signal pause_to_settings
signal pause_to_main

func _on_cont_button_pressed():
	pause_to_game.emit()
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))

func _on_settings_button_pressed():
	pause_to_settings.emit()
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))

func _on_leave_button_pressed():
	pause_to_main.emit()
	SoundManager.play_varied("ui", "click", randf_range(0.8, 1.1))

func _on_mouse_entered():
	SoundManager.play_varied("ui", "hover", randf_range(0.8, 1.1))
##
