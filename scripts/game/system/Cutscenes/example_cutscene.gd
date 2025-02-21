extends CutsceneManager

@onready var animation_player = $AnimationPlayer
@onready var camera_anims = $CameraAnims

var start_close:bool = false

var has_start:bool = false
var leave_cut:bool = false
var politician

func _ready():
	politician = $Politician
	politician.anim_relaxed()
	handle_signals()
	GlobalSignals.connect("cutscene_interrupted", _on_cutscene_interrupted)

func handle_signals():
	politician.is_done.connect(is_done)
	politician.show_prompt.connect(will_prompt)

func will_prompt():
	$Prompt/AP_Flash.play("Flash")
	$Prompt.visible = true

func is_done():
	leave_cut = true
	##politician.anim_relaxed_ramble()
	##cutscene_finished()

func initialize():
	if start_close:
		camera_anims.play("zoom_out")
	else:
		await get_tree().create_timer(7.5).timeout
		play_cutscene()
	##
##
func play_cutscene():
	has_start = true
	politician.anim_relaxed_talking()
##

func cutscene_finished():
	_emit_cutscene_finished()
	camera_anims.play("zoom_in")
##

func _on_cutscene_interrupted():
	_emit_cutscene_finished()
	camera_anims.play("zoom_in")
##
	
func _input(event):
	if event.is_pressed() and has_start == true and politician.can_skip == true and leave_cut == false:
		politician.anim_relaxed_talking()
		$Prompt.visible = false
		$Prompt/AP_Flash.stop()
	elif event.is_pressed() and has_start == true and politician.can_skip == true and leave_cut == true:
		politician.anim_relaxed_ramble()
		politician.bubble.play("Despawn")
		$Prompt.visible = false
		$Prompt/AP_Flash.stop()
		cutscene_finished()
