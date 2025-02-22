extends Node2D

# commenting out for now
@onready var label = $Timer_Ram/Label_Ram # Mica, use this label to track ram time

var tween:Tween

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


func lose_parts():
	explode()
	$AP_Worm.play("Despawn")

func is_ramming(point_in_anim):
	$AP_Ram.play("Ram")
	$AP_Ram.seek(point_in_anim, true)

func not_ramming():
	$AP_Ram.play("No_Ram")

func update_text(time_left):
	$Timer_Ram/Label_Ram.text = time_left
##

func get_time_in_ap():
	return $AP_Ram.current_animation_position
##

func turn_on_face():
	$Face.visible = true
	$Face/AP_Face.play("Blink")
##

func rotate_face(look:float):
	$Face.rotation_degrees = look
##

func move_segment(target_position, offseted):
	if offseted <= 0:
		offseted = 0.05
	##
	if tween:
		tween.kill() # Abort the previous animation
	##
	tween = create_tween()
	tween.tween_property(self, "global_position", target_position, offseted)
	#tween.tween_property(self, "global_position", target_position, offseted)\
			#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
##
