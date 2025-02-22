extends CanvasLayer

# Trigger everytime player before goes into gameplay
func delay_gamestart():
	$AP_Stability.play("321")

# Trigger during major stability intervals
func regular_shake():
	$AP_Stability.play("Regular")

# Trigger when politician dies
func death_politician():
	$AP_Stability.play("Death_Politician")

# Trigger when worm dies
func death_worm():
	$AP_Stability.play("Death_Worm")
##

#Don't trigger, this is to a function for AP_Stability
func shake():
	$"../Camera".apply_shake()
##
