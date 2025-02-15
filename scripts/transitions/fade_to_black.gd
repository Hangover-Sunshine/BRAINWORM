class_name FadeToBlackTransition
extends BaseTransition

@onready var animation_player:AnimationPlayer = $AP_TransitionAnimation

var fade_out:bool = false

func _ready():
	super()
##	

func play(direction:PLAY_DIRECTION, speed_scale:float = 1):
	animation_player.speed_scale = speed_scale
	if direction == PLAY_DIRECTION.IN:
		animation_player.play("fade")
	else:
		animation_player.play_backwards("fade")
	##
##

func _on_ap_transition_animation_animation_finished(_anim_name):
	if finished_out_transition:
		queue_free() # remove self
	##
	
	if finished_out_transition == false:
		load_level = true
		finished_out_transition = true
	##
##
