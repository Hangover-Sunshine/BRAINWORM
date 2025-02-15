extends Node2D
class_name Room

signal transfer_to(next_room:String, direction:Door.Direction)

# Direction -> ID -> Door (object ref)
var _doors:Dictionary = {
	Door.Direction.NORTH: {},
	Door.Direction.SOUTH: {},
	Door.Direction.EAST: {},
	Door.Direction.WEST: {},
}

func populate_doors():
	for child in get_children():
		if child is Door:
			child.get_player_start_position()
			child.connect("player_touched_door", _player_touched_door)
			
			var currId = _doors[child.DoorDirection].keys().size()
			_doors[child.DoorDirection][currId] = child
		##
	##
##

func get_door_player_spawn(direction:Door.Direction, door_id:int) -> Vector2:
	if _doors[direction].has(door_id):
		return _doors[direction][door_id].player_start
	##
	return Vector2.INF # An error occured
##

func _player_touched_door(linked_room:String, to_door_id:int, direction:Door.Direction):
	transfer_to.emit(linked_room, to_door_id, direction)
	for child in get_children():
		if child is Door:
			child.collision_mask = 0
		##
	##
##
