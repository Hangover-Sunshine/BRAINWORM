extends Node

const TISSUE = preload("res://prefabs/snake/tissue.tscn")

@export var MaxTissueNodes:int = 12
@export var MinRangeOfGrowth = 8
@export var MaxRangeOfGrowth = 14

@export_category("Timing Information")
@export var TissueSpawnTime:float = 2
@export var DelayToSpawn:float = 12

var _time_left:float
var super_control:GameControl
var game_board:GameBoard

func initialize():
	_time_left = DelayToSpawn
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

func _on_tissue_timer_timeout():
	# Check to see if any of the tissues are empty and remove them
	for child in get_children():
		if child is Brainwall and child.segments.size() == 0:
			child.queue_free()
		##
	##
	
	var rand:int = (randi() % 100) + 1
	var fold_count:int = get_child_count() - 1
	
	if rand <= 100 / (1 + fold_count) and fold_count < MaxTissueNodes:
		var inst:Brainwall = TISSUE.instantiate()
		inst.game_board = game_board
		inst.max_number_growths = randi_range(MinRangeOfGrowth, MaxRangeOfGrowth)
		add_child(inst)
		inst.initialize(super_control.find_open_position(inst, false, true, true))
	##
	
	$TissueTimer.start(TissueSpawnTime)
##

func does_position_overlap(pos:Vector2i) -> bool:
	for tindx in range(1, get_child_count()):
		if pos in get_child(tindx).positions:
			return true
		##
	##
	
	return false
##

func remove_at(pos:Vector2i):
	for tindx in range(1, get_child_count()):
		if pos in get_child(tindx).positions:
			get_child(tindx).remove_wall_at(pos)
		##
	##
##

func start_timers():
	if _time_left == 0:
		_on_tissue_timer_timeout()
		_time_left = TissueSpawnTime
	##
	$TissueTimer.start(_time_left)
##

func stop_timers():
	_time_left = $TissueTimer.time_left
	$TissueTimer.stop()
##
