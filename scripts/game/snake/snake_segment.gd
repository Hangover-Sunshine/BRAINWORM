extends Sprite2D

@onready var label = $Timer_Ram/Label_Ram # Mica, use this label to track ram time

func lose_parts():
	$AP_Worm.play("Despawn")

func is_ramming():
	$AP_Ram.play("Ram")

func not_ramming():
	$AP_Ram.play("No_Ram")
