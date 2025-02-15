extends Area2D
class_name Door

enum Direction {
	NORTH,
	EAST,
	WEST,
	SOUTH
}

signal player_touched_door(door_id:Direction)

@export var DoorDirection:Direction = Direction.NORTH

func _on_body_entered(body):
	player_touched_door.emit(DoorDirection)
##
