extends CanvasLayer

func populate_flesh(flesh:int):
	$GUI_Flesh/Number_Flesh.text = str(flesh)
##

func populate_macs(macs:int):
	$GUI_Macs/Number_Macs.text = str(macs)
##

func populate_tissue(tissue:int):
	$GUI_Tissue/Number_Tissue.text = str(tissue)
##

func populate_stage(stage:int):
	$GUI_Macs/Number_Macs.text = str(stage)
##

func populate_score(score:int):
	$GUI_Score/Number_Score.text = "%09d" % score
##

func populate_game_time(time):
	$GUI_Time/Number_Time.text = time
##
