extends CutsceneManager

@onready var animation_player = $AnimationPlayer
@onready var camera_anims = $CameraAnims

var start_close:bool = false

var has_start:bool = false
var politician

func _ready():
	politician = $Politician
	politician.anim_relaxed()

func initialize():
	if start_close:
		camera_anims.play("zoom_out")
	else:
		await get_tree().create_timer(1).timeout
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
	if event.is_pressed() and has_start == true and politician.can_skip == true and politician.is_done == false:
		politician.anim_relaxed_talking()
	elif event.is_pressed() and has_start == true and politician.can_skip == true and politician.is_done == true:
		politician.anim_relaxed_ramble()
		cutscene_finished()
