extends CutsceneManager

@onready var animation_player = $AnimationPlayer
@onready var camera_anims = $CameraAnims

var start_close:bool = false

func initialize():
	if start_close:
		camera_anims.play("zoom_out")
	else:
		await get_tree().create_timer(1).timeout
		play_cutscene()
	##
##

func play_cutscene():
	animation_player.play("yippie")
##

func cutscene_finished():
	_emit_cutscene_finished()
	camera_anims.play("zoom_in")
##

func _on_cutscene_interrupted():
	_emit_cutscene_finished()
	camera_anims.play("zoom_in")
##
