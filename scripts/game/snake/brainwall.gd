extends Object
class_name Brainwall

var max_number_growths:int = 0
var is_alive:bool = true
var positions:Array[Vector2i]

func get_valid_positions(board_width:int, board_height:int, other_walls:Array[Brainwall]) -> Array[Vector2i]:
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

func can_grow() -> bool:
	return max_number_growths > 0
##

func remove_at(pos:Vector2i):
	var indx:int = positions.find(pos)
	positions.remove_at(indx)
	
	if indx == 0:
		is_alive = false
	##
	
	max_number_growths += 1
##
