extends Node

const TISSUE = preload("res://prefabs/snake/tissue.tscn")

@export var MaxTissueNodes:int = 12
@export var MinRangeOfGrowth = 8
@export var MaxRangeOfGrowth = 14

@export_category("Timing Information")
@export var TissueSpawnTime:float = 2
@export var TissueGrowthTime:float = 2
@export var DelayToSpawn:float = 12

var _add_time_left:float
var _growth_time_left:float
var super_control:GameControl
var game_board:GameBoard

var non_tissue_child_count:int

func initialize():
	_add_time_left = DelayToSpawn
	_growth_time_left = DelayToSpawn
	non_tissue_child_count = get_child_count()
##

func get_active_tissues():
	var children:Array[Brainwall] = []
	
	for child in get_children():
		if child is Brainwall:
			children.push_back(child)
		##
	##
	
	return children
##

func does_position_overlap(pos:Vector2i) -> bool:
	for tindx in range(non_tissue_child_count, get_child_count()):
		if pos in get_child(tindx).positions:
			return true
		##
	##
	
	return false
##

func remove_at(pos:Vector2i):
	for tindx in range(non_tissue_child_count, get_child_count()):
		if pos in get_child(tindx).positions:
			get_child(tindx).remove_wall_at(pos)
		##
	##
##

func start_timers():
	if _add_time_left == 0:
		_on_tissue_timer_timeout()
		_add_time_left = TissueSpawnTime
	##
	$TissueTimer.start(_add_time_left)
##

func stop_timers():
	_add_time_left = $TissueTimer.time_left
	$TissueTimer.stop()
##

func spawn_tissue_cell(num_tissues:int):
	var rand:int = (randi() % 100) + 1
	
	if rand <= 100 / (1 + num_tissues) and num_tissues < MaxTissueNodes:
		var inst:Brainwall = TISSUE.instantiate()
		inst.game_board = game_board
		inst.max_number_growths = randi_range(MinRangeOfGrowth, MaxRangeOfGrowth)
		add_child(inst)
		var position:Vector2i = super_control.find_open_position(inst, false, true, true)
		inst.initialize(position)
		
		for tissue in get_active_tissues():
			if tissue.is_alive == false and position in tissue.positions:
				tissue.remove_wall_at(position)
			##
		##
	##
##

func _on_tissue_timer_timeout():
	# Check to see if any of the tissues are empty and remove them
	var awaiting_free:int = 0
	for child in get_children():
		if child is Brainwall:
			if child.segments.size() == 0:
				child.queue_free()
				awaiting_free += 1
				continue
			##
			if child.is_alive == false:
				awaiting_free += 1
			##
		##
	##
	
	var r = randi() % 100 + 1
	
	if get_child_count() - non_tissue_child_count == 0 or r <= 50:
		spawn_tissue_cell(get_child_count() - non_tissue_child_count - awaiting_free)
	else:
		check_for_growth()
	##
	
	$TissueTimer.start(TissueSpawnTime)
##

func check_for_growth():
	var children = get_active_tissues()
	
	# Quick check - can any of them actually grow?
	for tissue in children:
		if tissue.is_alive == false:
			children.remove_at(children.find(tissue))
		##
	##
	
	# If none, spawn a new cell and move along
	if len(children) == 0:
		spawn_tissue_cell(0)
		$TissueTimer.start(TissueSpawnTime)
		return
	##
	
	# Otherwise, go for an attempt at expanding
	var selected = children[randi() % len(children)]
	children.remove_at(children.find(selected))
	selected.grow_wall(children)
	
	$TissueTimer.start(TissueSpawnTime)
##
