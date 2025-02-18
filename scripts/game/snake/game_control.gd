extends Node

const GRID_WIDTH_COUNT:int = 16
const GRID_HEIGHT_COUNT:int = 15

const MOVE_UP:Vector2i = Vector2i(0, -1)
const MOVE_DOWN:Vector2i = Vector2i(0, 1)
const MOVE_LEFT:Vector2i = Vector2i(-1, 0)
const MOVE_RIGHT:Vector2i = Vector2i(1, 0)

@export var StartPosition:Vector2i = Vector2(6, GRID_HEIGHT_COUNT / 2)
@export var Countdown:int = 5

@onready var game_board = $Layout_Game

var can_move:bool = false
var prev_positions:Array[Vector2i]
var curr_positions:Array[Vector2i]
var segments:Array[Vector2i]
var move_dir:Vector2i

func initialize_board(game_data:Dictionary, stage:int):
	# initialize the UI
	game_board.initialize_ui(game_data, stage)
	
	# If no data exists, then make some!
	if game_data["snake"].size() == 0:
		game_data["snake"] = [StartPosition,
								StartPosition - Vector2i(1, 0),
								StartPosition - Vector2i(2, 0)]
	##
	
	# Put all snake in the current position
	for segment in game_data["snake"]:
		curr_positions.push_back(segment)
	##
	
	# Which way were they going last?
	move_dir = game_data["dir"]
	
	# TODO: Begin count down
##

func add_segment(position:Vector2i):
	curr_positions.push_back(position)
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
	can_move = true
	prev_positions = [] + curr_positions
	curr_positions[0] += move_dir
	for i in range(1, len(curr_positions)):
		curr_positions[i] = prev_positions[i - 1]
	##
##
