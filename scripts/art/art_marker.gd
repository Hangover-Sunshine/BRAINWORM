extends Node2D

@onready var body = $Marker_Body
@onready var head = $Marker_Head

## Trigger functions to mark where Mac will go. Keep behind Mac.
func add_target():
	body.emitting = true
	head.emitting = true
##

func remove_target():
	body.emitting = false
	head.emitting = false
##
