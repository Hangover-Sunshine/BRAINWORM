extends Sprite2D

var texture_rect:Rect2

func play_grow_animation(rect:Rect2):
	texture_rect = rect
	# NOTE: Brian -- here is where you call the animation player's growth play thing
	# Once your animation is done, you have the tile rect stuff here
	
	# TODO: REPLACE THIS WITH AP CALL!
	swap_to_actual()
##

# NOTE: Brian -- in your animation player, call this function once you're done!
func swap_to_actual():
	region_rect = texture_rect
##

# NOTE: Brian -- Don't worry about this one, I need it for updating tiles.
func change_texture_to(rect:Rect2):
	region_rect = rect
##
