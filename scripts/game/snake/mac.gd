extends Node2D
class_name Mak

signal please_move_me(mak:Mak)

@export var MovementTime:float = 1.5

@onready var movement_timer = $MovementTimer
@onready var art_mac = $Art_Mac

var _waiting:bool = true
var _indicate:bool = true
var _indicate_moving:float
var _delay_indicate_moving:float = 0

var is_alive:bool = true
var max_width:int
var max_height:int

var curr_position:Vector2i
var direction:Vector2i

var last_global_position:Vector2

var tween:Tween

func _ready():
	GlobalSignals.connect("player_died", _on_player_died)
	GlobalSignals.connect("speed_up_macs", _on_mac_movespeed_changed)
	$Art_Mac.spawn_mac()
##

func _on_player_died():
	$MovementTimer.stop()
	art_mac.remove_marker()
	set_process(false)
	is_alive = false
##

func initialize(movement_time:float):
	_indicate_moving = movement_time / 2
	$MovementTimer.start(MovementTime)
##

func _on_movement_timer_timeout():
	if is_alive == false:
		return
	##
	
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
		last_global_position = global_position
		curr_position += direction
		please_move_me.emit(self)
		art_mac.remove_marker()
		_indicate = true
		if _delay_indicate_moving != 0:
			_indicate_moving = _delay_indicate_moving
			_delay_indicate_moving = 0
		##
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

func move(new_global_position:Vector2):
	if tween:
		tween.kill() # Abort the previous animation
	##
	tween = create_tween()
	tween.tween_property(self, "global_position", new_global_position, 0.4).set_trans(Tween.TRANS_ELASTIC)
##

func kill_it():
	if is_alive == false:
		return
	##
	
	is_alive = false
	
	art_mac.remove_marker()
	art_mac.kill_mac()
	$MovementTimer.stop()
	$MovementTimer.disconnect("timeout", _on_movement_timer_timeout)
	$MovementTimer.start(1.5)
	await $MovementTimer.timeout
	queue_free()
##

func _on_mac_movespeed_changed(new_time:float):
	if _indicate:
		_delay_indicate_moving = new_time / 2
	else:
		_indicate_moving = new_time / 2
	##
##

func start_timer():
	$MovementTimer.start()
##

func stop_timer():
	$MovementTimer.stop()
##
