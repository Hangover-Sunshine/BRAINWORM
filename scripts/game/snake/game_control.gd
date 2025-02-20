extends Node

const SNAKE_SEGMENT = preload("res://prefabs/snake/snake_segment.tscn")
const MAC = preload("res://prefabs/snake/mac.tscn")

const GRID_WIDTH_COUNT:int = 15
const GRID_HEIGHT_COUNT:int = 14

@export_category("Starting Game Conditions")
@export var Countdown:int = 5
@export var StartPosition:Vector2i = Vector2(6, 7)

@export_category("Player Conditions")
@export var SecondsPerSegment:float = 1.5
@export var CheckForPowerupInterval:float = 1.5
@export var InvulnMinNumber:int = 5

@export_category("Tissue Spawn Info")
@export var MinRangeOfGrowth:int = 4
@export var MaxRangeOfGrowth:int = 8
@export var PlayerSafetySquare:int = 2

@export_category("Mak Spawning Info")
@export var MaxAtATime:int = 8
@export var PlayerSpawnSafetySquare:int = 4

@export_category("Win Conditions")
@export var BrainHealth:int = 200
@export var CostOfNeuron:int = 2
@export var CostOfTissue:int = 5

@onready var game_board = $Layout_Game
@onready var snake = $Snake

var neuron
var neuron_pos:Vector2i

var powerup
var powerup_pos:Vector2i

var macs:Array

var brainfold_spawns:int = 0
var brainfolds:Array[Brainwall]
var growable_folds:Array[Brainwall]

var update_score:bool = false
var neurons_consumed:int = 0
var tissue_destroyed:int = 0
var macs_killed:int = 0
var start_time:int

func _ready():
	neuron = load("res://prefabs/art/art_neuron.tscn").instantiate()
	powerup = load("res://prefabs/art/art_ram.tscn").instantiate()
	powerup.global_position = game_board.get_world_position_at(Vector2i(-100, -100))
	powerup_pos = Vector2i(-100, -100)
	add_child(neuron)
	add_child(powerup)
	
	$InvulnTimer.start(CheckForPowerupInterval)
	
	#$TissueTimer.start()
	#$MacTimer.start()
	start_time = 0
	set_process(false)
##

func _process(_delta):
	game_board.update_time(Time.get_ticks_msec() - start_time)
##

func initialize_ui():
	game_board.initialize_ui()
	snake.start_timers()
	start_time = Time.get_ticks_msec()
	set_process(true)
##

func hide_ui():
	game_board.hide_ui()
##

func initialize_board():
	snake.initialize(game_board, StartPosition)
	snake.connect("move", _on_player_move)
	snake.connect("invuln_over", _on_invuln_timer_timeout)
	snake.invuln_time_per_segment = SecondsPerSegment
	
	generate_neuron()
	
	# TODO: Begin count down
##

func _on_player_move():
	check_for_edge()
	check_for_self()
	check_for_enemy()
	check_for_neuron()
	check_for_powerup()
	check_for_tissue_eating_neuron()
	
	if update_score:
		game_board.update_score(neurons_consumed, macs_killed, tissue_destroyed)
		update_score = false
	##
##

func check_for_edge():
	if snake.X < 0 or snake.X > GRID_WIDTH_COUNT or\
		snake.Y < 0 or snake.Y > GRID_HEIGHT_COUNT:
		GlobalSignals.emit_signal("player_died")
	##
##

func check_for_self():
	if snake.self_overlaps():
		GlobalSignals.emit_signal("player_died")
	##
##

func check_for_enemy():
	var gameover:bool = false
	
	if snake.Invulnerable:
		var remove = []
		for tissue in brainfolds:
			if snake.Head in tissue.positions:
				tissue.remove_at(snake.Head)
				game_board.remove_brainfold_at(snake.Head, tissue.positions)
				if len(tissue.positions) == 0:
					remove.push_back(brainfolds.find(tissue))
				##
			##
		##
		
		for t in remove:
			brainfolds.remove_at(t)
			brainfold_spawns -= 1
			tissue_destroyed += 1
			update_score = true
		##
		
		remove.clear()
		for makIndx in range(len(macs)):
			if snake.Head == macs[makIndx].curr_position:
				macs[makIndx].kill_it()
				remove.push_back(makIndx)
			##
		##
		
		for m in remove:
			macs.remove_at(m)
			macs_killed += 1
			update_score = true
		##
		
		return
	##
	
	for tissue in brainfolds:
		if snake.Head in tissue.positions:
			gameover = true
		##
	##
	
	if gameover == false:
		for mak in macs:
			if snake.Head == mak.curr_position:
				gameover = true
			##
		##
	##
	
	if gameover:
		GlobalSignals.emit_signal("player_died")
	##
##

func check_for_neuron():
	if neuron_pos == snake.Head:
		snake.add_segment()
		generate_neuron()
		update_score = true
		neurons_consumed += 1
	##
##

func check_for_powerup():
	if powerup_pos == snake.Head:
		snake.Invulnerable = true
		$InvulnTimer.one_shot = true
		$InvulnTimer.start(SecondsPerSegment * (snake.Length - 2))
		powerup_pos = Vector2i(-100, -100)
		powerup.global_position = game_board.get_world_position_at(powerup_pos)
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
		
		for pos in snake.curr_positions:
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
			
			if (position - snake.Head).length() <= PlayerSafetySquare or position in snake.curr_positions:
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
		if len(valid_positions) == 0:
			return
		##
		
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
		
		if position in snake.curr_positions or \
			(position - snake.Head).length() <= PlayerSpawnSafetySquare:
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
	var r = randi() % 100
	if snake.meets_requirements_for_invuln(InvulnMinNumber) and r <= 30:
		generate_powerup()
	##
	$InvulnTimer.start(CheckForPowerupInterval)
##

func generate_powerup():
	var position:Vector2i
	var regen_food:bool = true
	while regen_food:
		regen_food = false
		position = Vector2i(randi_range(0, GRID_WIDTH_COUNT), randi_range(0, GRID_HEIGHT_COUNT))
		
		for pos in snake.curr_positions:
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
	
	powerup_pos = position
	powerup.global_position = game_board.get_world_position_at(position)
##
