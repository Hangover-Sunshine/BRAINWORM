extends Node2D
class_name Snake

signal move
signal invuln_over

const HEAD_RECTS:Dictionary = {
	MOVE_UP: Rect2(SEG_WIDTH * 0, SEG_HEIGHT * 1, SEG_WIDTH, SEG_HEIGHT),
	MOVE_DOWN: Rect2(SEG_WIDTH * 1, SEG_HEIGHT * 1, SEG_WIDTH, SEG_HEIGHT),
	MOVE_LEFT: Rect2(SEG_WIDTH * 2, SEG_HEIGHT * 0, SEG_WIDTH, SEG_HEIGHT),
	MOVE_RIGHT: Rect2(SEG_WIDTH * 3, SEG_HEIGHT * 0, SEG_WIDTH, SEG_HEIGHT),
}

const FACE_DIRECTIONS:Dictionary = {
	MOVE_UP: 180,
	MOVE_DOWN: 0,
	MOVE_LEFT: 90,
	MOVE_RIGHT: 270
}

const BODY_SEGMENTS:Dictionary = {
	[MOVE_UP, MOVE_DOWN]: Rect2(SEG_WIDTH * 0, SEG_HEIGHT * 0, SEG_WIDTH, SEG_HEIGHT),
	[MOVE_DOWN, MOVE_UP]: Rect2(SEG_WIDTH * 0, SEG_HEIGHT * 0, SEG_WIDTH, SEG_HEIGHT),
	
	[MOVE_UP, MOVE_LEFT]: Rect2(SEG_WIDTH * 1, SEG_HEIGHT * 2, SEG_WIDTH, SEG_HEIGHT),
	[MOVE_LEFT, MOVE_UP]: Rect2(SEG_WIDTH * 1, SEG_HEIGHT * 2, SEG_WIDTH, SEG_HEIGHT),
	
	[MOVE_UP, MOVE_RIGHT]: Rect2(SEG_WIDTH * 0, SEG_HEIGHT * 2, SEG_WIDTH, SEG_HEIGHT),
	[MOVE_RIGHT, MOVE_UP]: Rect2(SEG_WIDTH * 0, SEG_HEIGHT * 2, SEG_WIDTH, SEG_HEIGHT),
	
	[MOVE_RIGHT, MOVE_DOWN]: Rect2(SEG_WIDTH * 2, SEG_HEIGHT * 1, SEG_WIDTH, SEG_HEIGHT),
	[MOVE_DOWN, MOVE_RIGHT]: Rect2(SEG_WIDTH * 2, SEG_HEIGHT * 1, SEG_WIDTH, SEG_HEIGHT),
	
	[MOVE_LEFT, MOVE_DOWN]: Rect2(SEG_WIDTH * 3, SEG_HEIGHT * 1, SEG_WIDTH, SEG_HEIGHT),
	[MOVE_DOWN, MOVE_LEFT]: Rect2(SEG_WIDTH * 3, SEG_HEIGHT * 1, SEG_WIDTH, SEG_HEIGHT),
	
	[MOVE_RIGHT, MOVE_LEFT]: Rect2(SEG_WIDTH * 1, SEG_HEIGHT * 0, SEG_WIDTH, SEG_HEIGHT),
	[MOVE_LEFT, MOVE_RIGHT]: Rect2(SEG_WIDTH * 1, SEG_HEIGHT * 0, SEG_WIDTH, SEG_HEIGHT),
}

const SNAKE_SEGMENT = preload("res://prefabs/snake/snake_segment.tscn")

const MOVE_UP:Vector2i = Vector2i(0, -1)
const MOVE_DOWN:Vector2i = Vector2i(0, 1)
const MOVE_LEFT:Vector2i = Vector2i(-1, 0)
const MOVE_RIGHT:Vector2i = Vector2i(1, 0)

const SEG_WIDTH:int = 64
const SEG_HEIGHT:int = 64

var can_change_dir:bool = true
var prev_positions:Array[Vector2i]
var curr_positions:Array[Vector2i]
var old_segments:Array
var segments:Array
var invuln_time_per_segment:float

var prev_move_dir:Vector2i
var move_dir:Vector2i

var game_board:GameBoard
var curr_move_time:float

var is_dead:bool = false
var invuln_time_left:float = 0

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
			var sid = len(curr_positions) - 1
			
			# Guarantee to clear the screen of old parts
			if len(old_segments) > 0:
				for seg in old_segments:
					seg.lose_parts()
				##
			##
			
			while sid > 2:
				segments[sid].region_rect = Rect2(64 * 2, 64 * 2, 64, 64)
				old_segments.push_front(segments[sid])
				segments.remove_at(sid)
				curr_positions.remove_at(sid)
				prev_positions.remove_at(sid)
				sid -= 1
			##
			
			for i in range(0, 3):
				segments[i].is_ramming(0)
			##
		##
	##
##

func _on_player_died():
	stop_timers()
	set_process(false)
	is_dead = true
##

func initialize(gb:GameBoard, start_position:Vector2i, start_time_timer:float):
	GlobalSignals.connect("player_died", _on_player_died)
	GlobalSignals.connect("speed_up", _on_speed_up)
	curr_positions = [start_position, start_position - Vector2i(1, 0), start_position - Vector2i(2, 0)]
	move_dir = Vector2i(1, 0)
	game_board = gb
	curr_move_time = start_time_timer
	
	# Put all snake in the current position
	for seg_pos in curr_positions:
		var snake_seg = SNAKE_SEGMENT.instantiate()
		add_child(snake_seg)
		segments.push_back(snake_seg)
		segments[-1].global_position = game_board.get_world_position_at(seg_pos)
	##
	
	draw_snake()
	segments[0].turn_on_face()
	segments[0].rotate_face(FACE_DIRECTIONS[move_dir])
##

func start_timers():
	$MovementTimer.start(curr_move_time)
	if invuln_time_left > 0:
		$InvulnTimer.start(invuln_time_left)
		invuln_time_left = 0
	##
	if len(old_segments) > 0:
		$RemoveSegmentTimer.start()
	##
##

func stop_timers():
	$MovementTimer.stop()
	invuln_time_left = $InvulnTimer.time_left
	$InvulnTimer.stop()
	$RemoveSegmentTimer.stop()
##

func add_segment():
	curr_positions.push_back(curr_positions[-1])
	
	var snake_seg = SNAKE_SEGMENT.instantiate()
	snake_seg.global_position = game_board.get_world_position_at(curr_positions[-1])
	add_child(snake_seg)
	if Invulnerable:
		snake_seg.is_ramming(segments[0].get_time_in_ap())
	##
	segments.push_back(snake_seg)
##

func _process(_delta):
	if can_change_dir and Input.is_action_just_pressed("down") and (Head + MOVE_DOWN) != curr_positions[1]:
		move_dir = MOVE_DOWN
	##
	if can_change_dir and Input.is_action_just_pressed("up") and (Head + MOVE_UP) != curr_positions[1]:
		move_dir = MOVE_UP
	##
	if can_change_dir and Input.is_action_just_pressed("left") and (Head + MOVE_LEFT) != curr_positions[1]:
		move_dir = MOVE_LEFT
	##
	if can_change_dir and Input.is_action_just_pressed("right") and (Head + MOVE_RIGHT) != curr_positions[1]:
		move_dir = MOVE_RIGHT
	##
	
	if Invulnerable:
		var time_left = "%02d" % $InvulnTimer.time_left
		for seg in segments:
			seg.update_text(time_left)
		##
	##
##

func _on_movement_timer_timeout():
	if is_dead:
		return
	##
	can_change_dir = false
	
	prev_positions = curr_positions.duplicate()
	curr_positions[0] += move_dir
	
	# Prevent the player from being drawn out of the scene
	if X < 0 or X > GameControl.GRID_WIDTH_COUNT or Y < 0 or Y > GameControl.GRID_HEIGHT_COUNT - 1:
		move.emit()
		return
	##
	
	segments[0].global_position = game_board.get_world_position_at(curr_positions[0])
	#segments[0].move_segment(game_board.get_world_position_at(curr_positions[0]), curr_move_time / 2)
	segments[0].rotate_face(FACE_DIRECTIONS[move_dir])
	
	for i in range(1, len(curr_positions)):
		curr_positions[i] = prev_positions[i - 1]
		segments[i].global_position = game_board.get_world_position_at(curr_positions[i])
		#segments[i].move_segment(game_board.get_world_position_at(curr_positions[i]), curr_move_time / 2)
	##
	
	draw_snake()
	prev_move_dir = move_dir
	
	move.emit()
	can_change_dir = true
	$MovementTimer.start(curr_move_time)
##

func draw_snake():
	if prev_move_dir != move_dir:
		segments[0].region_rect = HEAD_RECTS[move_dir]
	##
	
	for sid in range(1, len(segments) - 1):
		var ahead = curr_positions[sid - 1] - curr_positions[sid]
		var behind = curr_positions[sid + 1] - curr_positions[sid]
		segments[sid].region_rect = BODY_SEGMENTS[[ahead, behind]]
	##
	
	segments[-1].region_rect = HEAD_RECTS[curr_positions[-1] - curr_positions[-2]]
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
	if len(old_segments) > 0:
		$RemoveSegmentTimer.start()
	else:
		return
	##
	old_segments[-1].lose_parts()
	old_segments.remove_at(len(old_segments) - 1)
##

func _on_invuln_timer_timeout():
	invuln_over.emit()
	_invuln = false
	for i in range(len(curr_positions)):
		segments[i].not_ramming()
	##
##

func _on_speed_up(new_speed):
	curr_move_time = new_speed
##
