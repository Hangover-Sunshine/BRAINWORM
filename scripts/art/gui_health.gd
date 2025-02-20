extends Node2D

@onready var healthbar = $GUI_Health_Bar
@onready var number = $GUI_Health_Number

func set_healthbar_value(value:int):
	healthbar.value = value
##

func _on_gui_health_bar_value_changed(value):
	number.text = str(value) +"%"

