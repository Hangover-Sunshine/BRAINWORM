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
		
		art_mac.point_marker()
		_indicate = false
	else:
		curr_position += direction
		please_move_me.emit(self)
		art_mac.remove_marker()
		_indicate = true
	##
##

func _pick_direction():
	var directions:Array[Vector2i] = []
	
##
