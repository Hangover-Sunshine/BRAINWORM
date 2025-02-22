extends Node2D

@onready var healthbar = $GUI_Health_Bar
@onready var number = $GUI_Health_Number

func set_healthbar_value(value:int):
	healthbar.value = value
##

func _on_gui_health_bar_value_changed(value):
	number.text = str(value) +"%"
	if value <= 75 and (value > 50):
		$AP_Flash.play("75%")
	elif value <= 50 and (value > 25):
		$AP_Flash.play("50%")
	elif value <= 25:
		$AP_Flash.play("50%")
##
