extends Node2D
class_name Brainwall

const TISSUE_SEGMENT = preload("res://prefabs/snake/tissue_segment.tscn")

static var TILES:Dictionary = {
	0b0000:Vector2i(0,2), # nothing
	0b1111:Vector2i(3,2), # all
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

var game_board:GameBoard
var max_number_growths:int = 0
var is_alive:bool = true
var positions:Array[Vector2i]
var segments:Array

func initialize(base_pos):
	positions.push_back(base_pos)
	
	var inst = TISSUE_SEGMENT.instantiate()
	inst.global_position = game_board.get_world_position_at(base_pos)
	segments.push_back(inst)
	var posOffset:Vector2i = TILES[0b0000]
	inst.play_grow_animation(Rect2(64 * posOffset.x, 64 * posOffset.y, 64, 64))
	add_child(inst)
##

func grow_wall(others:Array[Brainwall]) -> bool:
	if is_alive == false:
		return false
	##
	
	var valid_positions:Array[Vector2i] =\
			get_valid_positions(GameControl.GRID_WIDTH_COUNT, GameControl.GRID_HEIGHT_COUNT, others)
	
	if len(valid_positions) == 0:
		return false
	##
	
	var add_pos:Vector2i = valid_positions[randi() % len(valid_positions)]
	
	positions.push_back(add_pos)
	max_number_growths -= 1
	
	var inst = TISSUE_SEGMENT.instantiate()
	segments.push_back(inst)
	var posOffset:Vector2i = TILES[_surrounding_tile_check(add_pos)]
	inst.global_position = game_board.get_world_position_at(add_pos)
	inst.play_grow_animation(Rect2(64 * posOffset.x, 64 * posOffset.y, 64, 64))
	add_child(inst)
	
	_update_nearby_tiles(_surrounding_tile_check(add_pos), posOffset, add_pos)
	
	return !(max_number_growths == 0)
##

func remove_wall_at(pos:Vector2i):
	var indx = positions.find(pos)
	
	positions[indx] = Vector2i(-1, -1)
	_update_nearby_tiles(_surrounding_tile_check(pos), segments[indx].region_rect.position, pos)
	
	positions.remove_at(indx)
	segments[indx].kill()
	segments.remove_at(indx)
	
	max_number_growths += 1
	
	if indx == 0:
		is_alive = false
	##
##

func get_valid_positions(board_width:int, board_height:int, other_walls:Array[Brainwall]) -> Array[Vector2i]:
	if len(positions) == 0:
		return []
	##
	
	var valid_positions:Array[Vector2i] = []
	var curr_pos:Vector2i = positions[-1]
	
	var east = curr_pos + Vector2i(1, 0)
	if not(east in positions) and east.x <= board_width:
		var not_going_into_others:bool = true
		
		for other in other_walls:
			if east in other.positions:
				not_going_into_others = false
			##
		##
		
		if not_going_into_others:
			valid_positions.push_back(east)
		##
	##
	
	var west = curr_pos + Vector2i(-1, 0)
	if not(west in positions) and west.x > 0:
		var not_going_into_others:bool = true
		
		for other in other_walls:
			if west in other.positions:
				not_going_into_others = false
			##
		##
		
		if not_going_into_others:
			valid_positions.push_back(west)
		##
	##
	
	var north = curr_pos + Vector2i(0, -1)
	if not(north in positions) and north.y > 0:
		var not_going_into_others:bool = true
		
		for other in other_walls:
			if north in other.positions:
				not_going_into_others = false
			##
		##
		
		if not_going_into_others:
			valid_positions.push_back(north)
		##
	##
	
	var south = curr_pos + Vector2i(0, 1)
	if not(south in positions) and south.y < board_height:
		var not_going_into_others:bool = true
		
		for other in other_walls:
			if south in other.positions:
				not_going_into_others = false
			##
		##
		
		if not_going_into_others:
			valid_positions.push_back(south)
		##
	##
	
	return valid_positions
##

func get_root():
	if is_alive:
		return positions[0]
	else:
		return Vector2i(-1, -1)
	##
##

func _update_nearby_tiles(cardinals, posOffset:Vector2i, fold_pos:Vector2i):
	# Update local tiles
	var next_tile_pos:Vector2i = fold_pos + Vector2i(0, -1)
	if cardinals & 0b1000:
		_change_sprite(next_tile_pos)
	##
	next_tile_pos = fold_pos + Vector2i(1, 0)
	if cardinals & 0b0100:
		_change_sprite(next_tile_pos)
	##
	next_tile_pos = fold_pos + Vector2i(0, 1)
	if cardinals & 0b0010:
		_change_sprite(next_tile_pos)
	##
	next_tile_pos = fold_pos + Vector2i(-1, 0)
	if cardinals & 0b0001:
		_change_sprite(next_tile_pos)
	##
##

func _change_sprite(next_tile_pos:Vector2i):
	var indx = positions.find(next_tile_pos)
	var curr_coords = Vector2i(segments[indx].region_rect.position.x / 64,
		segments[indx].region_rect.position.y / 64)
	var local_cardinals = _surrounding_tile_check(next_tile_pos)
	var new_coords = TILES[local_cardinals]
	if new_coords != curr_coords:
		segments[indx].change_texture_to(Rect2(64 * new_coords.x, 64 * new_coords.y, 64, 64))
	##
##

func _surrounding_tile_check(origin:Vector2i) -> int:
	var cardinals:int = 0b0000
	
	if origin + Vector2i(0, -1) in positions:
		cardinals |= 0b1000
	##
	if origin + Vector2i(1, 0) in positions:
		cardinals |= 0b0100
	##
	if origin + Vector2i(0, 1) in positions:
		cardinals |= 0b0010
	##
	if origin + Vector2i(-1, 0) in positions:
		cardinals |= 0b0001
	##
	
	return cardinals
##
