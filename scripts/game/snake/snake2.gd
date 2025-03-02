extends Node2D

signal move
signal invuln_over
signal snake_done_exploding

const SEGMENT_DESPAWN = preload("res://prefabs/snake/segment_despawn.tscn")

const MOVE_UP:Vector2i = Vector2i(0, -1)
const MOVE_DOWN:Vector2i = Vector2i(0, 1)
const MOVE_LEFT:Vector2i = Vector2i(-1, 0)
const MOVE_RIGHT:Vector2i = Vector2i(1, 0)

@onready var snake = $Line2D

var can_change_dir:bool = true
var prev_positions:Array[Vector2i]
var curr_positions:Array[Vector2i]
var old_positions:Array[Vector2i]
var old_segments:Array
var segments:Array
var invuln_time_per_segment:float

var prev_move_dir:Vector2i
var move_dir:Vector2i

var game_board:GameBoard
var curr_move_time:float

var is_dead:bool = false
var invuln_time_left:float = 0

var invuln_sfx
var not_triggered:bool = true

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
			
			for i in range(len(curr_positions) - 1, 2, -1):
				var seg = SEGMENT_DESPAWN.instantiate()
				add_child(seg)
				seg.explode()
				seg.global_position = game_board.get_world_position_at(curr_positions[i])
				curr_positions.remove_at(i)
			##
			
			for i in range(len(snake.points) - 1, 3, -1):
				snake.remove_point(i)
			##
		##
	##
##

func initialize(gb:GameBoard, start_position:Vector2i, start_time_timer:float):
	invuln_sfx = SoundManager.instance("snake", "invuln")
	GlobalSignals.connect("player_died", _on_player_died)
	curr_positions = [start_position, start_position - Vector2i(1, 0), start_position - Vector2i(2, 0)]
	move_dir = Vector2i(1, 0)
	game_board = gb
	curr_move_time = start_time_timer
	
	# Put all snake in the current position
	for seg_pos in range(1, len(curr_positions)):
		snake.points[seg_pos + 1] = game_board.get_world_position_at(curr_positions[seg_pos])
	##
	snake.points[0] = game_board.get_world_position_at(curr_positions[0])
	snake.points[1] = game_board.get_world_position_at(curr_positions[0]) + Vector2(-8, 0)
	
	draw_snake()
	set_process(false)
##

func draw_snake():
	for seg_pos in range(1, len(curr_positions)):
		snake.points[seg_pos + 1] = game_board.get_world_position_at(curr_positions[seg_pos])
	##
	snake.points[0] = game_board.get_world_position_at(curr_positions[0])
	
	var offset:Vector2
	if move_dir == MOVE_RIGHT:
		offset = Vector2(-8, 0)
	elif move_dir == MOVE_LEFT:
		offset = Vector2(8, 0)
	elif move_dir == MOVE_UP:
		offset = Vector2(0, 8)
	else:
		offset = Vector2(0, -8)
	##
	snake.points[1] = game_board.get_world_position_at(curr_positions[0]) + offset
##

func add_segment():
	curr_positions.push_back(curr_positions[-1])
	snake.add_point(game_board.get_world_position_at(curr_positions[-1]))
	#if Invulnerable:
		#snake_seg.is_ramming(segments[0].get_time_in_ap())
	##
##

func start_timers():
	$MovementTimer.start(curr_move_time)
	if invuln_time_left > 0:
		$InvulnTimer.start(invuln_time_left)
		invuln_time_left = 0
		invuln_sfx.process_mode = PROCESS_MODE_INHERIT
	##
	if len(old_segments) > 0:
		$RemoveSegmentTimer.start()
	##
	set_process(true)
##

func stop_timers():
	set_process(false)
	$MovementTimer.stop()
	invuln_time_left = $InvulnTimer.time_left
	$InvulnTimer.stop()
	invuln_sfx.process_mode = PROCESS_MODE_DISABLED
##

func meets_requirements_for_invuln(min_length:int) -> bool:
	return len(curr_positions) >= min_length
##

func self_overlaps():
	for indx in range(1, len(curr_positions)):
		if curr_positions[indx] == Head:
			return true
		##
	##
	
	return false
##

func _process(_delta):
	if can_change_dir and Input.is_action_just_pressed("down") and (Head + MOVE_DOWN) != curr_positions[1]:
		move_dir = MOVE_DOWN
		if prev_move_dir != move_dir:
			SoundManager.play_varied("game", "move", randf_range(0.8, 1.1))
		##
		can_change_dir = false
	##
	if can_change_dir and Input.is_action_just_pressed("up") and (Head + MOVE_UP) != curr_positions[1]:
		move_dir = MOVE_UP
		if prev_move_dir != move_dir:
			SoundManager.play_varied("game", "move", randf_range(0.8, 1.1))
		##
		can_change_dir = false
	##
	if can_change_dir and Input.is_action_just_pressed("left") and (Head + MOVE_LEFT) != curr_positions[1]:
		move_dir = MOVE_LEFT
		if prev_move_dir != move_dir:
			SoundManager.play_varied("game", "move", randf_range(0.8, 1.1))
		##
		can_change_dir = false
	##
	if can_change_dir and Input.is_action_just_pressed("right") and (Head + MOVE_RIGHT) != curr_positions[1]:
		move_dir = MOVE_RIGHT
		if prev_move_dir != move_dir:
			SoundManager.play_varied("game", "move", randf_range(0.8, 1.1))
		##
		can_change_dir = false
	##
	
	if can_change_dir == false:
		var head:Vector2 = snake.points[1]
		
		if move_dir == MOVE_UP:
			head.y += -8
		elif move_dir == MOVE_DOWN:
			head.y += 8
		elif move_dir == MOVE_LEFT:
			head.x += -8
		elif move_dir == MOVE_RIGHT:
			head.x += 8
		##
		
		snake.points[0] = head
	##
	
	#if Invulnerable:
		#var time_left = "%02d" % $InvulnTimer.time_left
		#for seg in segments:
			#seg.update_text(time_left)
		###
		#if not_triggered and $InvulnTimer.time_left < 1:
			#invuln_sfx.trigger()
			#not_triggered = false
		##
	##
##

func _on_movement_timer_timeout():
	if is_dead:
		return
	##
	
	prev_positions = curr_positions.duplicate()
	curr_positions[0] += move_dir
	
	# Prevent the player from being drawn out of the scene
	if X < 0 or X > GameControl.GRID_WIDTH_COUNT or Y < 0 or Y > GameControl.GRID_HEIGHT_COUNT - 1:
		move.emit()
		return
	##
	
	for i in range(1, len(curr_positions)):
		curr_positions[i] = prev_positions[i - 1]
	##
	
	draw_snake()
	prev_move_dir = move_dir
	move.emit()
	can_change_dir = true
	$MovementTimer.start(curr_move_time)
##

func _on_player_died():
	stop_timers()
	set_process(false)
	is_dead = true
	invuln_sfx.release()
	old_segments = segments
##

func _on_invuln_timer_timeout():
	invuln_over.emit()
	GlobalSignals.player_ramming.emit(false)
	_invuln = false
	# TODO: Turn it off
##
