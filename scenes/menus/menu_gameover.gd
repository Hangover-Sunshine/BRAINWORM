extends Control

signal gameover_to_game
signal gameover_to_main


@onready var win_title = $GameOver_MC/GameOver_VBox/Text_Vbox/Win_Title
@onready var lose_title = $GameOver_MC/GameOver_VBox/Text_Vbox/Lose_Title
@onready var win_text = $GameOver_MC/GameOver_VBox/Text_Vbox/Win_VBox
@onready var fail_text = $GameOver_MC/GameOver_VBox/Text_Vbox/Fail_VBox

func to_lose():
	lose_title.visible = true
	fail_text.visible = true
	win_title.visible = false
	win_text.visible = false

func to_win():
	win_title.visible = true
	win_text.visible = true
	lose_title.visible = false
	fail_text.visible = false

func _on_again_button_pressed():
	gameover_to_game.emit()

func _on_leave_button_pressed():
	gameover_to_main.emit()
