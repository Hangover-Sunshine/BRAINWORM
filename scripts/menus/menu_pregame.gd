extends Control

signal pregame_to_game
signal pregame_to_main

func _on_tutorial_button_pressed():
	pregame_to_game.emit()

func _on_back_button_pressed():
	pregame_to_main.emit()
