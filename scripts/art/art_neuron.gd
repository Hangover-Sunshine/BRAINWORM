extends Node2D

@onready var skeleton = $Skeleton
@onready var ap_motion = $AP_Motion

## Trigger functions for animations.
func spawn_ram():
	skeleton.visible = true
	ap_motion.play("Spawn")
##

func idle_ram():
	ap_motion.play("Idle")
##
