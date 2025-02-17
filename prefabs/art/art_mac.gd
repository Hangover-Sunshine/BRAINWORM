extends Node2D

@onready var ap_motion = $AP_Motion
@onready var ap_blink = $AP_Blink

## Macs animation functions - *Use "Idle" for when Mac idles and moves.
func spawn_mac():
	ap_motion.play("Spawn")
##

func idle_mac():
	ap_motion.play("Idle")
##

func kill_mac():
	ap_motion.play("Die")
##
