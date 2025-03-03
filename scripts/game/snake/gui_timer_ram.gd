extends MarginContainer

@onready var label_ram = $Label_Ram

func show_label():
	visible = true
##

func hide_label():
	visible = false
##

func update_text(text):
	label_ram.text = text
##
