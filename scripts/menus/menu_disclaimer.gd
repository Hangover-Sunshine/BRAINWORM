extends Control

signal was_disclaimed

func _on_fade_anim_player_animation_finished(anim_name):
	if anim_name == "FadeIn":
		was_disclaimed.emit()
