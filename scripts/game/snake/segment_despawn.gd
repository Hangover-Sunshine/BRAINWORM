extends Node2D

func explode():
	var splatter = $FX_Splatter
	var timer = splatter.get_node("Timer")
	timer.start()
	splatter.emitting = true
	
	$AP_Worm.play("Despawn")
	$DespawnTimer.start()
##

func _on_despawn_timer_timeout():
	queue_free()
##
