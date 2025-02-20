extends Node2D

@onready var healthbar = $GUI_Health_Bar
@onready var number = $GUI_Health_Number
	
func _on_gui_health_bar_value_changed(value):
	number.text = str(value) +"%"
