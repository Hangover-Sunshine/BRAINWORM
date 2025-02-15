extends Control

signal main_to_pregame
signal main_to_settings
signal main_to_exit

func _on_start_button_pressed():
	main_to_pregame.emit()

func _on_settings_button_pressed():
	main_to_settings.emit()

func _on_exit_button_pressed():
	main_to_exit.emit()
