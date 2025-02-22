extends Node2D

# commenting out for now
@onready var label = $Timer_Ram/Label_Ram # Mica, use this label to track ram time

var tween:Tween

func lose_parts():
	$AP_Worm.play("Despawn")

func is_ramming(point_in_anim):
	$AP_Ram.play("Ram")
	$AP_Ram.seek(point_in_anim, true)

func not_ramming():
	$AP_Ram.play("No_Ram")

func update_text(time_left):
	$Timer_Ram/Label_Ram.text = time_left
##

func get_time_in_ap():
	return $AP_Ram.current_animation_position
##

func move_segment(target_position, offseted):
	if offseted <= 0:
		offseted = 0.05
	##
	if tween:
		tween.kill() # Abort the previous animation
	##
	tween = create_tween()
	tween.tween_property(self, "global_position", target_position, offseted)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
##
