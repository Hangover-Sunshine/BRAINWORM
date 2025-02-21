extends Node2D

var curr_position:Vector2i

func spawn():
	$Art_Ram.spawn_ram()
	$SpawnTimer.start()
	await $SpawnTimer.timeout
	$Art_Ram.idle_ram()
##

func kill():
	curr_position = Vector2i(-100, -100)
	global_position = Vector2(-100, -100)
##
