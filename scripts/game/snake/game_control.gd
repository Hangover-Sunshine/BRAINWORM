extends Node

const SNAKE_SEGMENT = preload("res://prefabs/snake/snake_segment.tscn")
const MAC = preload("res://prefabs/snake/mac.tscn")

const GRID_WIDTH_COUNT:int = 15
const GRID_HEIGHT_COUNT:int = 14

const MOVE_UP:Vector2i = Vector2i(0, -1)
const MOVE_DOWN:Vector2i = Vector2i(0, 1)
const MOVE_LEFT:Vector2i = Vector2i(-1, 0)
const MOVE_RIGHT:Vector2i = Vector2i(1, 0)

@export var StartPosition:Vector2i = Vector2(6, 7)
@export var Countdown:int = 5
@export var SecondsPerSegment:float = 1.5

@export_category("Tissue Spawn Info")
@export var MinRangeOfGrowth:int = 4
@export var MaxRangeOfGrowth:int = 8
@export var PlayerSafetySquare:int = 2

@export_category("Mak Spawning Info")
@export var MaxAtATime:int = 8
@export var PlayerSpawnSafetySquare:int = 4

@onready var game_board = $Layout_Game

var _known_loss:bool = false
var can_move:bool = false
var prev_positions:Array[Vector2i]
var curr_positions:Array[Vector2i]
var segments:Array
var move_dir:Vector2i
var invuln:bool = false

var neuron
var neuron_pos:Vector2i

var powerup
var powerup_pos:Vector2i

var macs:Array

var brainfold_spawns:int = 0
var brainfolds:Array[Brainwall]
var growable_folds:Array[Brainwall]

func _ready():
	neuron = load("res://prefabs/art/art_neuron.tscn").instantiate()
	powerup = load("res://prefabs/art/art_ram.tscn").instantiate()
	powerup.global_position = game_board.get_world_position_at(Vector2i(2, 2))
	powerup_pos = Vector2i(2, 2)
	add_child(neuron)
	add_child(powerup)
	
	$TissueTimer.start()
	$MacTimer.start()
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
								StartPosition - Vector2i(2, 0)]
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
	check_for_powerup()
	check_for_tissue_eating_neuron()
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
	var gameover:bool = false
	
	if invuln:
		var remove = []
		for tissue in brainfolds:
			if curr_positions[0] in tissue.positions:
				tissue.remove_at(curr_positions[0])
				game_board.remove_brainfold_at(curr_positions[0], tissue.positions)
				if len(tissue.positions) == 0:
					remove.push_back(brainfolds.find(tissue))
				##
			##
		##
		
		for t in remove:
			brainfolds.remove_at(t)
		##
		
		remove.clear()
		for makIndx in range(len(macs)):
			if curr_positions[0] == macs[makIndx].curr_position:
				macs[makIndx].kill_it()
				remove.push_back(makIndx)
			##
		##
		
		for m in remove:
			macs.remove_at(m)
		##
		
		return
	##
	
	for tissue in brainfolds:
		if curr_positions[0] in tissue.positions:
			gameover = true
		##
	##
	
	for mak in macs:
		if curr_positions[0] == mak.curr_position:
			gameover = true
		##
	##
	
	if gameover:
		GlobalSignals.emit_signal("player_died")
		set_process(false)
		$MoveTimer.stop()
		_known_loss = true
	##
##

func check_for_neuron():
	if neuron_pos == curr_positions[0]:
		add_segment(curr_positions[-1])
		generate_neuron()
	##
##

func check_for_powerup():
	if powerup_pos == curr_positions[0]:
		invuln = true
		$InvulnTimer.start(SecondsPerSegment * (len(curr_positions) - 3))
		print("here")
	##
##

func check_for_tissue_eating_neuron():
	for tissue in brainfolds:
		if neuron_pos in tissue.positions:
			generate_neuron()
		##
	##
	
	for mak in macs:
		if neuron_pos == mak.curr_position:
			generate_neuron()
		##
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
		
		for tissue in brainfolds:
			if position in tissue.positions:
				regen_food = true
				break
			##
		##
	##
	
	neuron_pos = position
	neuron.global_position = game_board.get_world_position_at(position)
##

func _on_tissue_timer_timeout():
	var rand:int = (randi() % 100) + 1
	
	if rand <= 100 / (1 + brainfold_spawns):
		var inst:Brainwall = Brainwall.new()
		inst.max_number_growths = randi_range(MinRangeOfGrowth, MaxRangeOfGrowth)
		var position:Vector2i
		var find_position:bool = true
		
		while find_position:
			find_position = false
			
			position = Vector2i(randi_range(0, GRID_WIDTH_COUNT), randi_range(0, GRID_HEIGHT_COUNT))
			
			if (position - curr_positions[0]).length() <= PlayerSafetySquare or position in curr_positions:
				find_position = true
			##
			
			for existing_walls in brainfolds:
				# Take over dead walls
				if existing_walls.is_alive == false:
					continue
				##
				
				# Otherwise, wall is alive, can't touch it or be near it
				if position in existing_walls.positions or (position - existing_walls.get_root()).length() <= 2:
					find_position = true
				##
			##
		##
		
		brainfolds.push_back(inst)
		growable_folds.push_back(inst)
		
		inst.positions.push_back(position)
		game_board.add_brainfold(position, inst.positions)
		
		brainfold_spawns += 1
	else:
		# NOTE: Pick a random one and grow
		rand = randi() % len(growable_folds)
		var inst:Brainwall = growable_folds[rand]
		
		var valid_positions:Array[Vector2i] = inst.get_valid_positions(GRID_WIDTH_COUNT,
																		GRID_HEIGHT_COUNT,
																		brainfolds)
		var position:Vector2i = valid_positions[randi() % len(valid_positions)]
		
		inst.positions.push_back(position)
		inst.max_number_growths -= 1
		
		if inst.max_number_growths == 0:
			growable_folds.remove_at(rand)
		##
		
		game_board.add_brainfold(position, inst.positions)
	##
##

func _on_mac_timer_timeout():
	if len(macs) >= MaxAtATime:
		return
	##
	
	var new_mac:Mak = MAC.instantiate()
	new_mac.max_width = GRID_WIDTH_COUNT
	new_mac.max_height = GRID_HEIGHT_COUNT
	var find_pos:bool = true
	var position:Vector2i
	
	while find_pos:
		find_pos = false
		position = Vector2i(randi_range(0, GRID_WIDTH_COUNT), randi_range(0, GRID_HEIGHT_COUNT))
		
		if position in curr_positions or (position - curr_positions[0]).length() <= PlayerSpawnSafetySquare:
			find_pos = true
		##
	##
	
	new_mac.curr_position = position
	new_mac.global_position = game_board.get_world_position_at(position)
	new_mac.connect("please_move_me", _listen_for_mak_movement)
	macs.push_back(new_mac)
	add_child(new_mac)
##

func _listen_for_mak_movement(mak:Mak):
	mak.global_position = game_board.get_world_position_at(mak.curr_position)
##

func _on_invuln_timer_timeout():
	invuln = false
##
