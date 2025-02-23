extends CanvasLayer

func populate_flesh(flesh:int):
	$GUI_Flesh/Number_Flesh.text = "%02d" % flesh
##

func populate_macs(macs:int):
	$GUI_Macs/Number_Macs.text = "%02d" % macs
##

func populate_tissue(tissue:int):
	$GUI_Tissue/Number_Tissue.text = "%02d" % tissue
##

func populate_score(score:int):
	$GUI_Score/Number_Score.text = "%03d" % score
##

func populate_game_time(time):
	$GUI_Time/Number_Time.text = time
##
