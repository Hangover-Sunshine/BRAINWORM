extends Node2D
class_name Mak

signal please_move_me(mak:Mak)

@export var MovementTime:float = 1.5

@onready var movement_timer = $MovementTimer
@onready var art_mac = $Art_Mac

var _waiting:bool = true
var _indicate:bool = true
var _indicate_moving:float

var max_width:int
var max_height:int

var curr_position:Vector2i
var direction:Vector2i

func _ready():
	$MovementTimer.start(MovementTime)
	_indicate_moving = MovementTime / 2
##

func _on_movement_timer_timeout():
	if _waiting:
		$MovementTimer.start(_indicate_moving)
		_waiting = false
		return
	##
	
	if _indicate:
		_pick_direction()
		
		# 0 = N/A, 1 = Left, 2 = Up, 3 = Right, 4 = Down
		if direction == Vector2i(0, -1):
			art_mac.direction = 2
		elif direction == Vector2i(0, 1):
			art_mac.direction = 4
		elif direction == Vector2i(1, 0):
			art_mac.direction = 3
		elif direction == Vector2i(-1, 0):
			art_mac.direction = 1
		##
		
		art_mac.point_marker()
		_indicate = false
	else:
		curr_position += direction
		please_move_me.emit(self)
		art_mac.remove_marker()
		_indicate = true
	##
	$MovementTimer.start(_indicate_moving)
##

func _pick_direction():
	var directions:Array[Vector2i] = []
	
	var north = curr_position + Vector2i(0, -1)
	if north.y > 0:
		directions.push_back(Vector2i(0, -1))
	##
	
	var south = curr_position + Vector2i(0, 1)
	if south.y < max_height:
		directions.push_back(Vector2i(0, 1))
	##
	
	var east = curr_position + Vector2i(1, 0)
	if east.x < max_width:
		directions.push_back(Vector2i(1, 0))
	##
	
	var west = curr_position + Vector2i(-1, 0)
	if west.x > 0:
		directions.push_back(Vector2i(-1, 0))
	##
	
	direction = directions[randi() % len(directions)]
##
