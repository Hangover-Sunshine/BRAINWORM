extends CanvasLayer

func _ready():
	connect_signals()

func connect_signals():
	GlobalSignals.connect("game_is_pausing", visible_percent)
	##GlobalSignals.connect("game_is_over?", visible_percent)

func visible_percent(is_pausing:bool):
	$PercentRemaining.visible = !is_pausing

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

func start_game():
	GlobalSignals.start_game.emit()
##

func change_percent():
	$PercentRemaining.rotation_degrees = randf_range(-15, 15)
	var percent_stability = floori((float($"../GameControl".jerry_health) / float($"../GameControl".max_health))*100)
	$PercentRemaining/MarginContainer/VBoxContainer/Percent_Label.text = str(percent_stability)+"%"
##

func play_three():
	SoundManager.play_varied("countdown", "3", randf_range(0.8, 1.1))
##

func play_two():
	SoundManager.play_varied("countdown", "2", randf_range(0.8, 1.1))
##

func play_one():
	SoundManager.play_varied("countdown", "1", randf_range(0.8, 1.1))
##

func play_go():
	SoundManager.play_varied("countdown", "go", randf_range(0.8, 1.1))
##
