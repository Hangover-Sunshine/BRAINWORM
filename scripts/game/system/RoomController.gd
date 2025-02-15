extends Node2D

signal finished_lerp

@export var RoomTransferSpeed:float = 10

@onready var player = $"../Player"

const CURR_ROOM_POSITION:Vector2 = Vector2(960, 540)
const LEFT_RIGHT_OFFSET:Vector2 = Vector2(1940, 0)
const UP_DOWN_OFFSET:Vector2 = Vector2(0, 1110)

const STARTING_POSITIONS:Dictionary = {
	Door.Direction.EAST: CURR_ROOM_POSITION + LEFT_RIGHT_OFFSET,
	Door.Direction.WEST: CURR_ROOM_POSITION - LEFT_RIGHT_OFFSET,
	Door.Direction.NORTH: CURR_ROOM_POSITION - UP_DOWN_OFFSET,
	Door.Direction.SOUTH: CURR_ROOM_POSITION + UP_DOWN_OFFSET,
}

var _current_room:Room = null
var _surrounding_rooms:Array[Room] = []

var _allow_lerp:bool = false
var _send_curr_room_to:Vector2
var _next_room:Room = null
var player_start_pos:Vector2

func _ready():
	_current_room = get_child(0)
	_current_room.populate_doors()
	_current_room.connect("transfer_to", _transfer_to)
##

func _physics_process(delta):
	if _allow_lerp:
		_next_room.global_position = _next_room.global_position.move_toward(CURR_ROOM_POSITION, RoomTransferSpeed)
		_current_room.global_position = _current_room.global_position.move_toward(_send_curr_room_to, RoomTransferSpeed)
		
		if _next_room.global_position == CURR_ROOM_POSITION:
			_allow_lerp = false
			player.visible = true
			finished_lerp.emit()
		##
	##
##

func _background_loading(load_rooms:Array[Room]):
	pass
##

func _transfer_to(next_room:String, to_door_id:int, direction:Door.Direction):
	get_tree().paused = true
	
	# TODO: Slight fade...
	
	if ResourceLoader.exists(next_room):
		_next_room = ResourceLoader.load(next_room).instantiate()
	##
	
	if _next_room == null:
		printerr("Uhhh you fucked up! Couldn't load:", next_room)
		return
	##
	
	# Inverse the direction...
	
	_next_room.visible = false
	call_deferred("add_child", _next_room)
	await _next_room.ready
	
	var actual_dir:Door.Direction
	match direction:
		Door.Direction.NORTH:
			actual_dir = Door.Direction.SOUTH
		Door.Direction.SOUTH:
			actual_dir = Door.Direction.NORTH
		Door.Direction.EAST:
			actual_dir = Door.Direction.WEST
		Door.Direction.WEST:
			actual_dir = Door.Direction.EAST
		_:
			printerr("Uuhh what?")
			return
		##
	##
	_next_room.global_position = STARTING_POSITIONS[actual_dir]
	_next_room.populate_doors()
	var spawn_position:Vector2 = _next_room.get_door_player_spawn(actual_dir, to_door_id)
	
	if spawn_position == Vector2.INF:
		printerr("This door (ID ", to_door_id, ") does not exist in direction ", actual_dir, 
			" (opposite of door facing) / ", direction, " (the way the door faces where player entered)!")
		return
	##
	_next_room.visible = true
	
	player.visible = false
	
	var lerp_direction:Vector2 = _next_room.global_position.direction_to(_current_room.global_position)
	
	var x_sign:int = sign(lerp_direction.x)
	var y_sign:int = sign(lerp_direction.y)
	
	# Which way to go for the original room?
	if x_sign != 0:
		if x_sign == 1: # room needs to go right
			_send_curr_room_to = CURR_ROOM_POSITION + LEFT_RIGHT_OFFSET
			player_start_pos = spawn_position + LEFT_RIGHT_OFFSET
		else: # room needs to go left
			_send_curr_room_to = CURR_ROOM_POSITION - LEFT_RIGHT_OFFSET
			player_start_pos = spawn_position - LEFT_RIGHT_OFFSET
		##
	else:
		if y_sign == 1: # room needs to go up
			_send_curr_room_to = CURR_ROOM_POSITION - UP_DOWN_OFFSET
			player_start_pos = spawn_position - UP_DOWN_OFFSET
		else: # room needs to go down
			_send_curr_room_to = CURR_ROOM_POSITION + UP_DOWN_OFFSET
			player_start_pos = spawn_position + UP_DOWN_OFFSET
		##
	##
	
	# Block-lerp
	_allow_lerp = true
	player.global_position = player_start_pos
	await finished_lerp
	player.visible = true
	
	# Release all old rooms
	_current_room.queue_free()
	
	# Our current room
	_current_room = _next_room
	_current_room.connect("transfer_to", _transfer_to)
	_next_room = null
	
	get_tree().paused = false
##
