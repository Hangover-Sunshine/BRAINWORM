extends Node2D
class_name Room

signal transfer_to(next_room:Room, spawn_pos:Vector2, direction:Door.Direction)

@export var ConnectedRoom:Room
@onready var player_start = $DoorArea/PlayerStart

func _ready():
	for child in get_children():
		if child is Door:
			child.connect("player_touched_door", _player_touched_door)
		##
	##
##

func _player_touched_door(direction:Door.Direction):
	transfer_to.emit(ConnectedRoom, ConnectedRoom.player_start.global_position, direction)
##
