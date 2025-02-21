extends Node2D
class_name GameBoard

const CELL_SIZE:float = 64
const GRID_OFFSET:Vector2i = Vector2i(5,1)

@onready var environment:TileMap = $Background/Environment

const TILES:Dictionary = {
	0b0000:Vector2i(0,2), # nothing
	0b1111:Vector2i(3, 2), # all
	0b0100:Vector2i(1,2), # east
	0b0001:Vector2i(5,2), # west
	0b0101:Vector2i(2,2), # east_west
	0b0010:Vector2i(3,0), # south
	0b1000:Vector2i(3,4), # north
	0b1010:Vector2i(3,3), # vert_hall
	0b0110:Vector2i(2,1), # east_south
	0b0011:Vector2i(4,1), # west_south
	0b1100:Vector2i(2,3), # north_east
	0b1001:Vector2i(4,3), # north_west
	0b0111:Vector2i(1,1), # east_south_west
	0b1101:Vector2i(0,1), # north_east_west
	0b1011:Vector2i(0,0), # north_south_west
	0b1110:Vector2i(1,0), # north_east_south
}

func add_brainfold(fold_pos:Vector2i, folds:Array[Vector2i]):
	#								NORTH, EAST, SOUTH, WEST
	var cardinals:int = _surrounding_tile_check(fold_pos, folds)
	environment.set_cell(1, fold_pos + GRID_OFFSET, 2, TILES[cardinals])
	_update_nearby_tiles(cardinals, fold_pos, folds)
##

func remove_brainfold_at(fold_pos:Vector2i, folds:Array[Vector2i]):
	#								NORTH, EAST, SOUTH, WEST
	var cardinals:int = _surrounding_tile_check(fold_pos, folds)
	environment.set_cell(1, fold_pos + GRID_OFFSET)
	_update_nearby_tiles(cardinals, fold_pos, folds)
##

func _update_nearby_tiles(cardinals, fold_pos:Vector2i, folds:Array[Vector2i]):
	# Update local tiles
	var next_tile_pos:Vector2i = fold_pos + Vector2i(0, -1)
	if cardinals & 0b1000:
		var curr_coords = environment.get_cell_atlas_coords(1, next_tile_pos)
		var local_cardinals = _surrounding_tile_check(next_tile_pos, folds)
		var new_coords = TILES[local_cardinals]
		if new_coords != curr_coords:
			environment.set_cell(1, next_tile_pos + GRID_OFFSET, 2, new_coords)
		##
	##
	next_tile_pos = fold_pos + Vector2i(1, 0)
	if cardinals & 0b0100:
		var curr_coords = environment.get_cell_atlas_coords(1, next_tile_pos)
		var local_cardinals = _surrounding_tile_check(next_tile_pos, folds)
		var new_coords = TILES[local_cardinals]
		if new_coords != curr_coords:
			environment.set_cell(1, next_tile_pos + GRID_OFFSET, 2, new_coords)
		##
	##
	next_tile_pos = fold_pos + Vector2i(0, 1)
	if cardinals & 0b0010:
		var curr_coords = environment.get_cell_atlas_coords(1, next_tile_pos)
		var local_cardinals = _surrounding_tile_check(next_tile_pos, folds)
		var new_coords = TILES[local_cardinals]
		if new_coords != curr_coords:
			environment.set_cell(1, next_tile_pos + GRID_OFFSET, 2, new_coords)
		##
	##
	next_tile_pos = fold_pos + Vector2i(-1, 0)
	if cardinals & 0b0001:
		var curr_coords = environment.get_cell_atlas_coords(1, next_tile_pos)
		var local_cardinals = _surrounding_tile_check(next_tile_pos, folds)
		var new_coords = TILES[local_cardinals]
		if new_coords != curr_coords:
			environment.set_cell(1, next_tile_pos + GRID_OFFSET, 2, new_coords)
		##
	##
##

func initialize_ui():
	$GUI.visible = true
	$GUI.populate_flesh(0)
	$GUI.populate_macs(0)
	$GUI.populate_tissue(0)
	$GUI.populate_score(0)
##

func update_score(flesh:int, macs:int, tissue:int):
	$GUI.populate_flesh(flesh)
	$GUI.populate_macs(macs)
	$GUI.populate_tissue(tissue)
	$GUI.populate_score(flesh + macs * 2 + tissue * 5)
##

func update_time(milliseconds:int):
	var seconds:int = milliseconds / 1000
	var minutes:int = seconds / 60
	if seconds > 60:
		seconds -= minutes * 60
	##
	var millis:int = milliseconds % 1000 # remainder
	var strms:String = ("%02d" % millis)
	if strms.length() > 2:
		strms = strms.erase(strms.length() - 1, 1)
	##
	$GUI.populate_game_time(("%02d" % minutes) + ":" + ("%02d" % seconds) + "." + strms)
##

func update_health(value:int):
	$GUI/GUI_Health.set_healthbar_value(value)
##

func hide_ui():
	$GUI.visible = false
##

func get_world_position_at(pos:Vector2i) -> Vector2:
	return environment.map_to_local(pos + GRID_OFFSET)
##

func _surrounding_tile_check(origin:Vector2i, tiles:Array[Vector2i]) -> int:
	var cardinals:int = 0b0000
	
	if origin + Vector2i(0, -1) in tiles:
		cardinals |= 0b1000
	##
	if origin + Vector2i(1, 0) in tiles:
		cardinals |= 0b0100
	##
	if origin + Vector2i(0, 1) in tiles:
		cardinals |= 0b0010
	##
	if origin + Vector2i(-1, 0) in tiles:
		cardinals |= 0b0001
	##
	
	return cardinals
##
