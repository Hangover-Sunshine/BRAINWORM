extends Node2D

var texture_rect:Rect2

func play_grow_animation(rect:Rect2):
	texture_rect = rect
	# NOTE: Brian -- here is where you call the animation player's growth play thing
	# Once your animation is done, you have the tile rect stuff here
	
	# TODO: REPLACE THIS WITH AP CALL!
	$TissueSegment/AP.play("Spawn")
##

# NOTE: Brian -- in your animation player, call this function once you're done!
func swap_to_actual():
	$TissueSegment.region_rect = texture_rect
##

# NOTE: Brian -- Don't worry about this one, I need it for updating tiles.
func change_texture_to(rect:Rect2):
	$TissueSegment.region_rect = rect
##

func kill():
	# NOTE: You're responsible for cleaning this segment up
	#	The tissue parent has already forgotten you by this point.
	# TODO: REPLACE THIS WITH AN ANIM, THEN QUEUE FREE
	$TissueSegment/AP.play("Despawn")
##
