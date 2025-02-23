extends Node2D
class_name GameBoard

const CELL_SIZE:float = 64
const GRID_OFFSET:Vector2i = Vector2i(5,1)

@onready var environment:TileMap = $Background/TileHolder/Environment
@onready var change_background = $GUI/GUI_Health

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
	if value <= 75 and (value > 50):
		$Background/TileHolder/AP_Flash.play("75%")
	elif value <= 50 and (value > 25):
		$Background/TileHolder/AP_Flash.play("50%")
	elif value <= 25:
		$Background/TileHolder/AP_Flash.play("25%")
##

func hide_ui():
	$GUI.visible = false
##

func get_world_position_at(pos:Vector2i) -> Vector2:
	return environment.map_to_local(pos + GRID_OFFSET)
##
