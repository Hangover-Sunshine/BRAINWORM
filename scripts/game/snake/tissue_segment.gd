extends Sprite2D

var texture_rect:Rect2

func _ready():
	self.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
##

func explode():
	var splatter = $FX_Splatter
	var timer = splatter.get_node("Timer")
	timer.start()
	splatter.emitting = true
	var global_position = splatter.global_position
	var game_scene = get_tree().root.find_child("GameScene", true, false)
	if game_scene:
		var game_control = game_scene.find_child("GameControl", true, false)
		if game_control:
			splatter.get_parent().remove_child(splatter)
			game_control.add_child(splatter)
			splatter.global_position = global_position
##

func play_grow_animation(rect:Rect2):
	texture_rect = rect
	$AP.play("Spawn")
##

func swap_to_actual():
	region_rect = texture_rect
##

func change_texture_to(rect:Rect2):
	region_rect = rect
##

func kill():
	$AP.play("Despawn")
	explode()
##
