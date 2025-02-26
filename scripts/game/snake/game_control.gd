extends Node
class_name GameControl

const MAC = preload("res://prefabs/snake/mac.tscn")

static var GRID_WIDTH_COUNT:int = 15
static var GRID_HEIGHT_COUNT:int = 15

@export_category("Starting Game Conditions")
@export var StartPosition:Vector2i = Vector2(6, 7)

@export_category("Player Conditions")
@export var SecondsPerSegment:float = 1.5
@export var CheckForPowerupInterval:float = 1.5
@export var MovePowerupInterval:float = 3
@export var InvulnMinNumber:int = 5

@export_category("Tissue Spawn Info")
@export var MaxTissueNodes:int = 4
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

@export_category("Game Conditions")
@export var MovementTimeChanges:Dictionary = {
	100: 0.16,
	75: 0.14,
	50: 0.12,
	25: 0.10
}
@export var MacMovementTimeChanges:Dictionary = {
	100: 1.8,
	75: 1.6,
	50: 1.5,
	25: 1.3,
}
@export var MaxMacSpawn:Dictionary = {
	100: 2,
	75: 6,
	50: 10,
	25: 14
}

@onready var game_board = $Layout_Game
@onready var snake = $Snake

var neuron
var neuron_pos:Vector2i

var neuron2
var neuron_pos2:Vector2i

var powerup

var macs:Array[Mak]

var brainfolds:Array[Brainwall]
var growable_folds:Array[Brainwall]

var update_score:bool = false
var neurons_consumed:int = 0
var tissue_destroyed:int = 0
var macs_killed:int = 0
var start_time:int
var curr_timer_time:float
var curr_mac_timer_time:float

var jumble_jerry:bool = true
var jerry_health:int
var threshold:int = 100

var need_to_countdown:bool = false

var mac_spawn_time:float
var tissue_spawn_time:float

func _ready():
	curr_timer_time = MovementTimeChanges[100]
	curr_mac_timer_time = MacMovementTimeChanges[100]
	MaxAtATime = MaxMacSpawn[100]
	GlobalSignals.emit_signal("speed_up", curr_timer_time)
	GlobalSignals.connect("start_game", _on_game_start)
	
	neuron = load("res://prefabs/art/art_neuron.tscn").instantiate()
	neuron2 = load("res://prefabs/art/art_neuron.tscn").instantiate()
	powerup = load("res://prefabs/snake/powerup.tscn").instantiate()
	powerup.global_position = game_board.get_world_position_at(Vector2i(-100, -100))
	powerup.curr_position = Vector2i(-100, -100)
	add_child(neuron)
	add_child(neuron2)
	add_child(powerup)
	
	$TissueControl.initialize()
	$TissueControl.super_control = self
	$TissueControl.game_board = game_board
	
	$MacControl.super_control = self
	$MacControl.game_board = game_board
	
	jerry_health = BrainHealth
	
	start_time = 0
	set_process(false)
##

func _on_game_start():
	GlobalSignals.emit_signal("game_status", false)
	turn_on_all_timers()
	start_time = Time.get_ticks_msec()
	$InvulnTimer.start(CheckForPowerupInterval)
	need_to_countdown = false
	set_process(true)
##

func _process(_delta):
	if need_to_countdown:
		$"../StabilityStatus".delay_gamestart()
		set_process(false)
		return
	##
	
	game_board.update_time(Time.get_ticks_msec() - start_time)
	
	threshold = floori(jerry_health / float(BrainHealth) * 100)
	var timer_time = curr_timer_time
	if threshold > 50 and threshold <= 75:
		timer_time = MovementTimeChanges[75]
		curr_mac_timer_time = MacMovementTimeChanges[75]
		MaxAtATime = MaxMacSpawn[75]
	elif threshold > 25 and threshold <= 50:
		timer_time = MovementTimeChanges[50]
		curr_mac_timer_time = MacMovementTimeChanges[50]
		MaxAtATime = MaxMacSpawn[50]
	elif threshold < 25:
		timer_time = MovementTimeChanges[25]
		curr_mac_timer_time = MacMovementTimeChanges[25]
		MaxAtATime = MaxMacSpawn[25]
	##
	
	if timer_time != curr_timer_time:
		curr_timer_time = timer_time
		$"../StabilityStatus".regular_shake()
		SoundManager.play_varied("game", "rumble", randf_range(0.9, 1.1))
		GlobalSignals.emit_signal("speed_up", curr_timer_time)
		GlobalSignals.emit_signal("speed_up_macs", curr_mac_timer_time)
	##
	
	if jerry_health <= 0:
		MusicManager.stop(3)
		PlayerPrefs.Neurons = neurons_consumed
		PlayerPrefs.Tissue = tissue_destroyed
		PlayerPrefs.Macs = macs_killed
		PlayerPrefs.GameTime = Time.get_ticks_msec() - start_time
		turn_off_all_timers()
		$"../StabilityStatus".death_politician()
		GlobalSignals.emit_signal("game_won")
		SoundManager.play("game", "jerry_dead")
		set_process(false)
	##
##

func initialize_ui():
	game_board.initialize_ui()
	$"../StabilityStatus".delay_gamestart()
##

func hide_ui():
	game_board.hide_ui()
##

func initialize_board():
	snake.initialize(game_board, StartPosition, curr_timer_time)
	snake.connect("move", _on_player_move)
	snake.connect("invuln_over", _on_invuln_timer_timeout)
	snake.invuln_time_per_segment = SecondsPerSegment
	
	generate_neuron()
	generate_neuron2()
##

func _on_player_move():
	check_for_edge()
	check_for_self()
	check_for_neuron()
	check_for_powerup()
	check_for_enemy()
	
	var remove = []
	for elem in range(len(brainfolds)):
		if brainfolds[elem] == null or brainfolds[elem].is_alive == false:
			remove.push_back(elem)
			if brainfolds[elem] != null:
				brainfolds[elem].queue_free()
			##
		##
	##
	
	for id in remove:
		brainfolds.remove_at(id)
	##
	
	remove = []
	for elem in range(len(macs)):
		if macs[elem] == null or macs[elem].is_alive == false:
			remove.push_back(elem)
			if macs[elem] != null:
				macs[elem].queue_free()
			##
		##
	##
	
	for id in remove:
		macs.remove_at(id)
	##
	
	check_for_tissue_eating_neuron()
	check_for_tissue_eating_powerup()
	
	if update_score:
		game_board.update_score(neurons_consumed, macs_killed, tissue_destroyed)
		game_board.update_health(floori(jerry_health / float(BrainHealth) * 100))
		update_score = false
	##
##

func check_for_edge():
	if snake.X < 0 or snake.X > GRID_WIDTH_COUNT or\
		snake.Y < 0 or snake.Y > GRID_HEIGHT_COUNT - 1:
		player_has_died()
	##
##

func check_for_self():
	if snake.self_overlaps():
		player_has_died()
	##
##

func player_has_died():
	SoundManager.play_varied("game", "player_dead", randf_range(0.8, 1.1))
	set_process(false)
	turn_off_all_timers()
	snake._on_player_died()
	$"../StabilityStatus".death_worm()
	await get_tree().create_timer(2).timeout
	GlobalSignals.emit_signal("player_died")
	GlobalSignals.emit_signal("game_scores",
									neurons_consumed, macs_killed, tissue_destroyed,
									Time.get_ticks_msec() - start_time)
##

func check_for_enemy():
	var gameover:bool = false
	
	if $TissueControl.does_position_overlap(snake.Head):
		if snake.Invulnerable:
			$TissueControl.remove_at(snake.Head)
			tissue_destroyed += 1
			SoundManager.play_varied("game", "tear", randf_range(0.8, 1.1))
			
			if jumble_jerry:
				$JumblingJerryTimer.start()
				GlobalSignals.player_got_damage.emit()
				jumble_jerry = false
			##
		else:
			gameover = true
		##
	##
	
	if snake.Invulnerable:
		var remove = []
		for makIndx in range(len(macs)):
			if macs[makIndx] != null and snake.Head == macs[makIndx].curr_position:
				macs[makIndx].kill_it()
				remove.push_back(makIndx)
			##
			if macs[makIndx] == null and not(makIndx in remove):
				remove.push_back(makIndx)
			##
		##
		
		for m in remove:
			SoundManager.play_varied("game", "splat", randf_range(0.8, 1.1))
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
		player_has_died()
	##
##

func check_for_neuron():
	if neuron_pos == snake.Head:
		jerry_health -= CostOfNeuron
		snake.add_segment()
		generate_neuron()
		update_score = true
		neurons_consumed += 1
		
		if jumble_jerry:
			$JumblingJerryTimer.start()
			GlobalSignals.player_got_damage.emit()
			jumble_jerry = false
		##
		
		SoundManager.play_varied("game", "nom", randf_range(0.8, 1.1))
	##
	
	if neuron_pos2 == snake.Head:
		jerry_health -= CostOfNeuron
		snake.add_segment()
		generate_neuron2()
		update_score = true
		neurons_consumed += 1
		
		if jumble_jerry:
			$JumblingJerryTimer.start()
			GlobalSignals.player_got_damage.emit()
			jumble_jerry = false
		##
		
		SoundManager.play_varied("game", "nom", randf_range(0.8, 1.1))
	##
##

func check_for_powerup():
	if powerup.curr_position == snake.Head:
		snake.Invulnerable = true
		$InvulnTimer.one_shot = true
		$InvulnTimer.start(SecondsPerSegment * (snake.Length - 2))
		powerup.kill()
		SoundManager.play_varied("game", "nom", randf_range(0.8, 1.1))
	##
##

func check_for_tissue_eating_neuron():
	for tissue in brainfolds:
		if tissue != null and neuron_pos in tissue.positions:
			generate_neuron()
		##
		if tissue != null and neuron_pos2 in tissue.positions:
			generate_neuron2()
		##
	##
	
	for mak in macs:
		if mak != null and neuron_pos == mak.curr_position:
			generate_neuron()
		##
		if mak != null and neuron_pos2 == mak.curr_position:
			generate_neuron2()
		##
	##
##

func check_for_tissue_eating_powerup():
	for tissue in brainfolds:
		if powerup.curr_position in tissue.positions:
			generate_powerup()
		##
	##
##

func generate_neuron():
	var position:Vector2i
	var regen_position:bool = true
	
	while regen_position:
		regen_position = false
		position = Vector2i(randi_range(0, GRID_WIDTH_COUNT),
							randi_range(0, GRID_HEIGHT_COUNT - 1))
		
		for pos in snake.curr_positions:
			if pos == position:
				regen_position = true
				break
			##
		##
		
		for tissue in brainfolds:
			if position in tissue.positions:
				regen_position = true
				break
			##
		##
		
		if position == powerup.curr_position or position == neuron_pos2:
			regen_position = true
		##
	##
	
	neuron_pos = position
	neuron.global_position = game_board.get_world_position_at(position)
	neuron.spawn_ram()
##

func generate_neuron2():
	var position:Vector2i
	var regen_food:bool = true
	while regen_food:
		regen_food = false
		position = Vector2i(randi_range(0, GRID_WIDTH_COUNT), randi_range(0, GRID_HEIGHT_COUNT - 1))
		
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
		
		if position == powerup.curr_position or position == neuron_pos:
			regen_food = true
		##
	##
	
	neuron_pos2 = position
	neuron2.global_position = game_board.get_world_position_at(position)
	neuron2.spawn_ram()
##

func _on_invuln_timer_timeout():
	if powerup.curr_position == Vector2i(-100, -100):
		var r = randi() % 100 - snake.Length
		if snake.Invulnerable == false and snake.meets_requirements_for_invuln(InvulnMinNumber)\
			and r <= 35:
			generate_powerup()
		##
		$InvulnTimer.start(CheckForPowerupInterval)
	else:
		if (powerup.curr_position - snake.Head).length() > 10:
			generate_powerup()
		##
		$InvulnTimer.start(MovePowerupInterval)
	##
##

func generate_powerup():
	var position:Vector2i
	var regen_food:bool = true
	while regen_food:
		regen_food = false
		position = Vector2i(randi_range(0, GRID_WIDTH_COUNT), randi_range(0, GRID_HEIGHT_COUNT - 1))
		
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
		
		if position == neuron_pos:
			regen_food = true
		##
	##
	
	powerup.curr_position = position
	powerup.global_position = game_board.get_world_position_at(powerup.curr_position)
	powerup.spawn()
##

func _on_jumbling_jerry_timer_timeout():
	jumble_jerry = true
##

func turn_on_all_timers():
	$InvulnTimer.start(CheckForPowerupInterval)
	$MacControl.start_timers()
	$TissueControl.start_timers()
	snake.start_timers()
##

func turn_off_all_timers():
	mac_spawn_time = $MacTimer.time_left
	tissue_spawn_time = $TissueTimer.time_left
	$InvulnTimer.stop()
	$MacControl.stop_timers()
	$TissueControl.stop_timers()
	snake.stop_timers()
##

func countdown():
	turn_off_all_timers()
	need_to_countdown = true
##

func find_open_position(obj_self, macs_poses:bool, tissue_poses:bool, offset:bool) -> Vector2i:
	var position:Vector2i
	var regen_position:bool = true
	
	var taken_positions:Array[Vector2i] = []
	
	if tissue_poses:
		for t in $TissueControl.get_active_tissues():
			if t == obj_self:
				continue
			##
			
			var start:int = 0
			
			if offset and t.is_alive:
				start = 1
				
				# Can't spawn in a box around the root node
				for x in range(-1, 1):
					for y in range(-1, 1):
						taken_positions.push_back(t.positions[0] + Vector2i(x, y))
					##
				##
			##
			
			for pos in range(start, len(t.positions)):
				if not(t.positions[pos] in taken_positions):
					taken_positions.push_back(t.positions[pos])
				##
			##
		##
	##
	
	if macs_poses:
		for mac in $MacControl.get_active_macs():
			taken_positions.push_back(mac.curr_position)
		##
	##
	
	for snegment in range(1, len(snake.curr_positions)):
		taken_positions.push_back(snake.curr_positions[snegment])
	##
	
	for x in range(-1, 1):
		for y in range(-1, 1):
			var pos = snake.curr_positions[0] + Vector2i(x, y)
			if not(pos in taken_positions):
				taken_positions.push_back(pos)
			##
		##
	##
	
	while regen_position:
		regen_position = false
		position = Vector2i(randi_range(0, GRID_WIDTH_COUNT),
							randi_range(0, GRID_HEIGHT_COUNT - 1))
		
		if position in taken_positions:
			regen_position = true
		##
	##
	
	return position
##
