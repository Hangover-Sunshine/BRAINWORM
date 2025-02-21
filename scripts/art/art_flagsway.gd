extends Sprite2D

@onready var ap = $AP_Flag

# Called when the node enters the scene tree for the first time.
func _ready():
	var animation_length = ap.get_animation("Sway").length
	var random_time = randf() * animation_length
	ap.play("Sway")
	ap.seek(random_time)
