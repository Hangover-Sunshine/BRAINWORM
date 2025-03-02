extends Node2D


func explode():
	var splatter = $FX_Splatter
	var timer = splatter.get_node("Timer")
	timer.start()
	splatter.emitting = true
	#var global_pos = splatter.global_position
	#var game_scene = get_tree().root.find_child("GameScene", true, false)
	#if game_scene:
		#var game_control = game_scene.find_child("GameControl", true, false)
		#if game_control:
			#splatter.get_parent().remove_child(splatter)
			#game_control.add_child(splatter)
			#splatter.global_position = global_pos
		##
	##
	$AP_Worm.play("Despawn")
##
