extends Sprite2D

var texture_rect:Rect2

func _ready():
	self.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
##
