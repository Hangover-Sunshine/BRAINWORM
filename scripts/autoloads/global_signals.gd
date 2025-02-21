extends Node

# CUTSCENES ###############################
signal cutscene_finished
signal cutscene_interrupted
# CUTSCENES ###############################

# GAMEPLAY ###############################
signal game_status(is_over:bool)
signal game_won
signal player_died
signal player_got_damage
signal game_scores(neurons:int, macs:int, tissue:int, time:int)

signal speed_up(new_time:float)
# GAMEPLAY ###############################
