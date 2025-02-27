extends Node

const MAC = preload("res://prefabs/snake/mac.tscn")

@export_category("Timing Information")
@export var SpawnTime:float = 2
@export var DelayToSpawn:float = 12

var max_at_a_time:int = 4

var _time_left:float = 0
var super_control:GameControl
var game_board:GameBoard

var _curr_mac_move_time:float = 1.8

func initialize():
	_time_left = DelayToSpawn
##

func get_active_macs():
	var children:Array[Mak] = []
	
	for child in get_children():
		if child is Mak:
			children.push_back(child)
		##
	##
	
	return children
##

func does_position_overlap(pos:Vector2i):
	var active = get_active_macs()
	
	for mac in active:
		if mac.curr_position == pos:
			return mac
		##
	##
	
	return null
##

func remove(mac:Mak):
	var active = get_active_macs()
	active[active.find(mac)].kill_it()
##

func _on_mac_timer_timeout():
	var rand = randi() % 100 + 1
	if get_child_count() - 1 >= max_at_a_time or rand > 50:
		$MacTimer.start(SpawnTime)
		return
	##
	
	var new_mac:Mak = MAC.instantiate()
	new_mac.max_width = GameBoard.GRID_WIDTH_COUNT
	new_mac.max_height = GameBoard.GRID_HEIGHT_COUNT
	
	var position:Vector2i = super_control.find_open_position(new_mac, true, true, false)
	
	new_mac.curr_position = position
	new_mac.global_position = game_board.get_world_position_at(position)
	new_mac.connect("please_move_me", _listen_for_mak_movement)
	add_child(new_mac)
	new_mac.initialize(_curr_mac_move_time)
	$MacTimer.start(SpawnTime)
##

func start_timers():
	if _time_left == 0:
		_on_mac_timer_timeout()
		_time_left = SpawnTime
	##
	$MacTimer.start(_time_left)
	for child in get_children():
		if child is Brainwall:
			child.start_timer()
		##
	##
##

func stop_timers():
	_time_left = $MacTimer.time_left
	$MacTimer.stop()
	
	for child in get_children():
		if child is Mak:
			child.stop_timer()
		##
	##
##

func _listen_for_mak_movement(mak:Mak):
	mak.move(game_board.get_world_position_at(mak.curr_position))
##
