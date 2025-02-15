extends Area2D
class_name Door

enum Direction {
	NORTH,	# 0
	EAST,	# 1
	WEST,	# 2
	SOUTH	# 3
}

signal player_touched_door(linked_room:String, linked_door_id:int, door_id:Direction)

@export_file var LinkedRoom:String
@export var LinkToDoorID:int = 0
@export var DoorDirection:Direction = Direction.NORTH

var player_start:Vector2

func get_player_start_position():
	for child in get_children():
		if child is Marker2D:
			player_start = child.global_position
		##
	##
##

func _on_body_entered(body):
	player_touched_door.emit(LinkedRoom, LinkToDoorID, DoorDirection)
##
