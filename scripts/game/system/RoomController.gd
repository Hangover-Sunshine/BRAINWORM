extends Node2D

var _current_room:Room = null
var _surrounding_rooms:Array[Room] = []

func _ready():
	_current_room = get_child(0)
	
	# TODO: Block-load this and add as children
	
	# Attach all children nodes as potential
	for child in get_children(): # TODO: replace with an array of surrounding rooms
		# Turn off rooms that are not the current room -- don't let enemies wander/take up
		#	cycles
		if child != _current_room:
			pass
		##
		child.connect("transfer_to", _transfer_to)
		child.process_mode = Node.PROCESS_MODE_PAUSABLE
	##
##

func _background_loading(load_rooms:Array[Room]):
	pass
##

func _release_rooms():
	pass
##

func _transfer_to(next_room:Room, spawn_pos:Vector2, direction:Door.Direction):
	get_tree().paused = true
	
	var new_room_target_pos:Vector2 = _current_room.global_position
	var lerp_direction:Vector2 = next_room.global_position.direction_to(_current_room.global_position)
	
	var x_sign:int = sign(lerp_direction.x)
	var y_sign:int = sign(lerp_direction.y)
	
	# Which way to go for the original room?
	var old_room_target_pos:Vector2
	if x_sign != 0:
		if x_sign == 1: # room needs to go right
			old_room_target_pos = Vector2(2900, 540)
		else: # room needs to go left
			old_room_target_pos = Vector2(-980, 540)
		##
	else:
		if y_sign == 1: # room needs to go up
			pass
		else: # room needs to go down
			pass
		##
	##
##
