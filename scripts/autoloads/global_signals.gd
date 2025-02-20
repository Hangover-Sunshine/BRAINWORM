extends Node

# CUTSCENES ###############################
signal cutscene_finished
signal cutscene_interrupted
# CUTSCENES ###############################

# GAMEPLAY ###############################
signal game_status(is_over:bool)
signal player_died
signal game_scores(neurons:int, macs:int, tissue:int, time:int)
# GAMEPLAY ###############################
