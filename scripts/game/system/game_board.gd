extends Node2D

const CELL_SIZE:float = 64
const GRID_OFFSET:Vector2i = Vector2i(7,1)

@onready var environment:TileMap = $Background/Environment

const TILES:Dictionary = {
	[false,false,false,false]:Vector2i(0,2), # nothing
	[true,true,true,true]: Vector2i(3, 2), # all
	[false,true,false,false]:Vector2i(1,2), # east
	[false,false,false,true]:Vector2i(5,2), # west
	[false,true,false,true]:Vector2i(2,2), # east_west
	[false,false,true,false]:Vector2i(3,0), # south
	[true,false,false,false]:Vector2i(3,4), # north
	[true,false,true,false]:Vector2i(3,3), # vert_hall
	[false,true,true,false]:Vector2i(2,1), # east_south
	[false,false,true,true]:Vector2i(4,1), # west_south
	[true,true,false,false]:Vector2i(2,3), # north_east
	[true,false,false,true]:Vector2i(4,3), # north_west
	[false,true,true,true]:Vector2i(1,1), # east_south_west
	[true,true,false,true]:Vector2i(0,1), # north_east_west
	[true,false,true,true]:Vector2i(0,0), # north_south_west
	[true,true,true,false]:Vector2i(1,0), # north_east_south
}

func add_brainfold(fold_pos:Vector2i, folds:Array[Vector2i]):
	var tile:Vector2i
	
	#								NORTH, EAST, SOUTH, WEST
	var cardinals:Array[bool] = _surrounding_tile_check(fold_pos, folds)
	
	environment.set_cell(1, fold_pos + GRID_OFFSET, 2, TILES[cardinals])
	
	# Update local tiles
	var next_tile_pos:Vector2i = fold_pos + Vector2i(0, -1)
	if cardinals[0]:
		print("here!")
		var curr_coords = environment.get_cell_atlas_coords(1, next_tile_pos)
		var local_cardinals = _surrounding_tile_check(next_tile_pos, folds)
		var new_coords = TILES[local_cardinals]
		if new_coords != curr_coords:
			environment.set_cell(1, next_tile_pos + GRID_OFFSET, 2, new_coords)
		##
	##
	next_tile_pos = fold_pos + Vector2i(1, 0)
	if cardinals[1]:
		var curr_coords = environment.get_cell_atlas_coords(1, next_tile_pos)
		var local_cardinals = _surrounding_tile_check(next_tile_pos, folds)
		var new_coords = TILES[local_cardinals]
		if new_coords != curr_coords:
			environment.set_cell(1, next_tile_pos + GRID_OFFSET, 2, new_coords)
		##
	##
	next_tile_pos = fold_pos + Vector2i(0, 1)
	if cardinals[2]:
		var curr_coords = environment.get_cell_atlas_coords(1, next_tile_pos)
		var local_cardinals = _surrounding_tile_check(next_tile_pos, folds)
		var new_coords = TILES[local_cardinals]
		if new_coords != curr_coords:
			environment.set_cell(1, next_tile_pos + GRID_OFFSET, 2, new_coords)
		##
	##
	next_tile_pos = fold_pos + Vector2i(-1, 0)
	if cardinals[3]:
		var curr_coords = environment.get_cell_atlas_coords(1, next_tile_pos)
		var local_cardinals = _surrounding_tile_check(next_tile_pos, folds)
		var new_coords = TILES[local_cardinals]
		if new_coords != curr_coords:
			environment.set_cell(1, next_tile_pos + GRID_OFFSET, 2, new_coords)
		##
	##
##

func initialize_ui(game_data:Dictionary, stage:int):
	$GUI.visible = true
	$GUI.populate_flesh(game_data["flesh"])
	$GUI.populate_macs(game_data["macs"])
	$GUI.populate_tissue(game_data["tissue"])
	$GUI.populate_stage(stage)
	$GUI.populate_score(0)
##

func hide_ui():
	$GUI.visible = false
##

func get_world_position_at(pos:Vector2i) -> Vector2:
	return environment.map_to_local(pos + GRID_OFFSET)
##

func _surrounding_tile_check(origin:Vector2i, tiles:Array[Vector2i]):
	var cardinals:Array[bool] = [false, false, false, false]
	
	if origin + Vector2i(0, -1) in tiles:
		cardinals[0] = true
	##
	if origin + Vector2i(1, 0) in tiles:
		cardinals[1] = true
	##
	if origin + Vector2i(0, 1) in tiles:
		cardinals[2] = true
	##
	if origin + Vector2i(-1, 0) in tiles:
		cardinals[3] = true
	##
	
	return cardinals
##
