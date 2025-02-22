extends Camera2D

@onready var camera = $"../Camera" 
@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0
@export var shakeDuration: float = 0.5 #adjustable duration in seconds

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0
var shake_timer: float = 0.0

func apply_shake():
	shake_strength = randomStrength
	shake_timer = shakeDuration

func _process(delta):
	if shake_strength > 0:
		shake_timer -= delta
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		offset = randomOffset()
	else:
		shake_strength = 0

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength),
	rng.randf_range(-shake_strength,shake_strength))

