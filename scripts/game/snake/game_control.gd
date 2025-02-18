extends Node

const SNAKE_SEGMENT = preload("res://prefabs/snake/snake_segment.tscn")

const GRID_WIDTH_COUNT:int = 15
const GRID_HEIGHT_COUNT:int = 14

const MOVE_UP:Vector2i = Vector2i(0, -1)
const MOVE_DOWN:Vector2i = Vector2i(0, 1)
const MOVE_LEFT:Vector2i = Vector2i(-1, 0)
const MOVE_RIGHT:Vector2i = Vector2i(1, 0)

@export var StartPosition:Vector2i = Vector2(6, 7)
@export var Countdown:int = 5

@onready var game_board = $Layout_Game

var _known_loss:bool = false
var can_move:bool = false
var prev_positions:Array[Vector2i]
var curr_positions:Array[Vector2i]
var segments:Array
var move_dir:Vector2i

var neuron
var neuron_pos:Vector2i
var macs:Array
var mac_positions:Array

var brainfold_positions:Array[Vector2i]

func _ready():
	neuron = load("res://prefabs/art/art_neuron.tscn").instantiate()
	add_child(neuron)
	#brainfold_positions.push_back(Vector2i(4, 4))
	#game_board.add_brainfold(Vector2i(4, 4), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(5, 4))
	#game_board.add_brainfold(Vector2i(5, 4), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(4, 5))
	#game_board.add_brainfold(Vector2i(4, 5), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(3, 4))
	#game_board.add_brainfold(Vector2i(3, 4), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(4, 3))
	#game_board.add_brainfold(Vector2i(4, 3), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(3, 3))
	#game_board.add_brainfold(Vector2i(3, 3), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(3, 5))
	#game_board.add_brainfold(Vector2i(3, 5), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(5, 5))
	#game_board.add_brainfold(Vector2i(5, 5), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(5, 3))
	#game_board.add_brainfold(Vector2i(5, 3), brainfold_positions)
	#brainfold_positions.push_back(Vector2i(8,4))
	#game_board.add_brainfold(Vector2i(8, 4), brainfold_positions)
##

func initialize_ui(game_data:Dictionary, stage:int):
	game_board.initialize_ui(game_data, stage)
	$MoveTimer.start()
##

func hide_ui():
	game_board.hide_ui()
##

func initialize_board(game_data:Dictionary):
	# If no data exists, then make some!
	if game_data["snake"].size() == 0:
		game_data["snake"] = [StartPosition,
								StartPosition - Vector2i(1, 0),
								StartPosition - Vector2i(2, 0),
								StartPosition - Vector2i(3, 0),
								StartPosition - Vector2i(4, 0)]
	##
	
	# Put all snake in the current position
	for segment in range(len(game_data["snake"])):
		curr_positions.push_back(game_data["snake"][segment])
		
		var snake_seg = SNAKE_SEGMENT.instantiate()
		add_child(snake_seg)
		segments.push_back(snake_seg)
		segments[segment].global_position = game_board.get_world_position_at(curr_positions[segment])
	##
	
	#segments[0].is_head = true
	#segments[-1].is_tail = true
	
	# Which way were they going last?
	move_dir = game_data["dir"]
	
	generate_neuron()
	
	# TODO: Begin count down
##

func add_segment(position:Vector2i):
	curr_positions.push_back(position)
	
	var snake_seg = SNAKE_SEGMENT.instantiate()
	snake_seg.global_position = game_board.get_world_position_at(position)
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

func _on_timer_timeout():
	if _known_loss:
		return
	##
	
	can_move = true
	
	prev_positions = curr_positions.duplicate()
	curr_positions[0] += move_dir
	segments[0].global_position = game_board.get_world_position_at(curr_positions[0])
	
	for i in range(1, len(curr_positions)):
		curr_positions[i] = prev_positions[i - 1]
		segments[i].global_position = game_board.get_world_position_at(curr_positions[i])
	##
	
	check_for_edge()
	check_for_self()
	check_for_enemy()
	check_for_neuron()
##

func check_for_edge():
	if curr_positions[0].x < 0 or curr_positions[0].x > GRID_WIDTH_COUNT or\
		curr_positions[0].y < 0 or curr_positions[0].y > GRID_HEIGHT_COUNT:
		GlobalSignals.emit_signal("player_died")
		set_process(false)
		$MoveTimer.stop()
		_known_loss = true
	##
##

func check_for_self():
	for i in range(1, len(curr_positions)):
		if curr_positions[0] == curr_positions[i]:
			GlobalSignals.emit_signal("player_died")
			set_process(false)
			$MoveTimer.stop()
			_known_loss = true
		##
	##
##

func check_for_enemy():
	pass
##

func check_for_neuron():
	if neuron_pos == curr_positions[0]:
		add_segment(curr_positions[-1])
		generate_neuron()
	##
##

func generate_neuron():
	var position:Vector2i
	var regen_food:bool = true
	while regen_food:
		regen_food = false
		position = Vector2i(randi_range(0, GRID_WIDTH_COUNT), randi_range(0, GRID_HEIGHT_COUNT))
		
		for pos in curr_positions:
			if pos == position:
				regen_food = true
				break
			##
		##
		
		# TODO: Check if it is overlapped by a tissue
	##
	
	neuron_pos = position
	neuron.global_position = game_board.get_world_position_at(position)
##
