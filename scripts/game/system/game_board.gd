extends Node2D

const CELL_SIZE:float = 64
const GRID_OFFSET:Vector2i = Vector2i(7,1)

@onready var environment:TileMap = $Background/Environment

func _ready():
	pass
##

func initialize(game_data:Dictionary, stage:int):
	$GUI.visible = true
	$GUI.populate_flesh(game_data["flesh"])
	$GUI.populate_macs(game_data["macs"])
	$GUI.populate_tissue(game_data["tissue"])
	$GUI.populate_stage(stage)
	$GUI.populate_score(0)
##

func place_worm_part(indx:int, pos:Vector2i):
	print(environment.map_to_local(pos + GRID_OFFSET))
##
