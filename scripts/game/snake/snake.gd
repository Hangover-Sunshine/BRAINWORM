extends Node2D
class_name Snake

signal move
signal invuln_over

const SNAKE_SEGMENT = preload("res://prefabs/snake/snake_segment.tscn")

const MOVE_UP:Vector2i = Vector2i(0, -1)
const MOVE_DOWN:Vector2i = Vector2i(0, 1)
const MOVE_LEFT:Vector2i = Vector2i(-1, 0)
const MOVE_RIGHT:Vector2i = Vector2i(1, 0)

var can_move:bool = false
var prev_positions:Array[Vector2i]
var curr_positions:Array[Vector2i]
var segments:Array
var move_dir:Vector2i
var invuln_time_per_segment:float

var game_board:GameBoard

var Head : Vector2i :
	get:
		return curr_positions[0]
	##
##

var X : int :
	get:
		return curr_positions[0].x
	##
##

var Y : int :
	get:
		return curr_positions[0].y
	##
##

var Length : int :
	get:
		return len(curr_positions)
	##
##

var _invuln:bool = false
var Invulnerable:bool:
	get:
		return _invuln
	set(val):
		_invuln = val
		if val:
			$InvulnTimer.start(invuln_time_per_segment * (len(curr_positions) - 3))
			$RemoveSegmentTimer.start()
		##
	##
##

func _on_player_died():
	$MovementTimer.stop()
	$RemoveSegmentTimer.stop()
	$InvulnTimer.stop()
##

func initialize(game_board:GameBoard, start_position:Vector2i):
	GlobalSignals.connect("player_died", _on_player_died)
	curr_positions = [start_position, start_position - Vector2i(1, 0), start_position - Vector2i(2, 0)]
	move_dir = Vector2i(1, 0)
	self.game_board = game_board
	
	# Put all snake in the current position
	for seg_pos in curr_positions:
		var snake_seg = SNAKE_SEGMENT.instantiate()
		add_child(snake_seg)
		segments.push_back(snake_seg)
		segments[-1].global_position = game_board.get_world_position_at(seg_pos)
	##
##

func start_timers():
	$MovementTimer.start()
##

func add_segment():
	curr_positions.push_back(curr_positions[-1])
	
	var snake_seg = SNAKE_SEGMENT.instantiate()
	snake_seg.global_position = game_board.get_world_position_at(curr_positions[-1])
	add_child(snake_seg)
	segments.push_back(snake_seg)
##

func _process(_delta):
	if can_move:
		if Input.is_action_just_pressed("down") and move_dir != MOVE_UP:
			move_dir = MOVE_DOWN
			can_move = false
		##
		if Input.is_action_just_pressed("up") and move_dir != MOVE_DOWN:
			move_dir = MOVE_UP
			can_move = false
		##
		if Input.is_action_just_pressed("left") and move_dir != MOVE_RIGHT:
			move_dir = MOVE_LEFT
			can_move = false
		##
		if Input.is_action_just_pressed("right") and move_dir != MOVE_LEFT:
			move_dir = MOVE_RIGHT
			can_move = false
		##
	##
##

func _on_movement_timer_timeout():
	can_move = true
	
	prev_positions = curr_positions.duplicate()
	curr_positions[0] += move_dir
	segments[0].global_position = game_board.get_world_position_at(curr_positions[0])
	
	for i in range(1, len(curr_positions)):
		curr_positions[i] = prev_positions[i - 1]
		segments[i].global_position = game_board.get_world_position_at(curr_positions[i])
	##
	
	move.emit()
##

func self_overlaps():
	for indx in range(1, len(curr_positions)):
		if curr_positions[indx] == Head:
			return true
		##
	##
	
	return false
##

func meets_requirements_for_invuln(min_length:int) -> bool:
	return len(curr_positions) >= min_length
##

func _on_remove_segment_timer_timeout():
	if len(curr_positions) > 4:
		$RemoveSegmentTimer.start()
	##
	segments[-1].queue_free()
	segments.remove_at(len(segments) - 1)
	curr_positions.remove_at(len(curr_positions) - 1)
##

func _on_invuln_timer_timeout():
	invuln_over.emit()
	_invuln = false
##
