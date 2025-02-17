extends CutsceneManager

@onready var animation_player = $AnimationPlayer

func cutscene_finished():
	_emit_cutscene_finished()
	animation_player.play("camera_zoom_in")
##

func _play_cutscene():
	animation_player.play("yippie")
##

func _on_cutscene_interrupted():
	_emit_cutscene_finished()
	animation_player.play("cancel")
	animation_player.play("camera_zoom_in")
##
