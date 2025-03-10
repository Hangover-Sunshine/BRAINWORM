extends Node2D

@onready var idle = $AP_Idle
@onready var eyes = $AP_Eyes
@onready var mouth = $AP_Mouth
@onready var brows = $AP_Brows
@onready var face = $AP_Face
@onready var hit = $AP_Hit
@onready var textbox = $Skeleton/Body/Suit/TextBox
@onready var bubble = $AP_Bubble

## @onready var testing_timer = $Testing_Timer

## Stuff I need to provide variation to when he gets hit. #
var animation_length
var random_time
var ouch_eye
var ouch_brow

## Stuff I need to grab his stupid lines #
var game_lines
var script_vbox
var line1
var line2
var line3 
var can_skip:bool = false
signal is_done
signal show_prompt
var script_size = 11 # I had to manually set this. I couldn't figure out why.
@onready var lines_to_read = 0

func _ready():
	game_lines = $Skeleton/Body/Suit/TextBox
	script_vbox = $Skeleton/Body/Suit/TextBox/Control/Margin1/Margin2/VBox
	line1 = script_vbox.find_child("Line1")
	line2 = script_vbox.find_child("Line2")
	line3 = script_vbox.find_child("Line3")
	GlobalSignals.connect("player_got_damage", anim_ouch_blurb)

## Trigger only at beginning of cutscene / when not talking
func anim_relaxed():
	idle.play("Idle")
	eyes.play("Resting")
	mouth.play("Not_Talking")
	brows.play("Resting")
	face.play("Not_Talking")

## Trigger for gameplay, default idle animation during gameplay
func anim_relaxed_ramble():
	idle.play("Idle")
	eyes.play("Resting")
	mouth.play("Ramble")
	brows.play("Resting")
	
	animation_length = face.get_animation("Normal").length
	random_time = randf() * animation_length
	face.play("Normal")
	face.seek(random_time)

## Trigger for cutscene, everytime he says a line
func anim_relaxed_talking():
	can_skip = false
	idle.play("Idle")
	eyes.play("Resting")
	mouth.play("Talking")
	brows.play("Resting")
	
	animation_length = face.get_animation("Normal").length
	random_time = randf() * animation_length
	face.play("Normal")
	face.seek(random_time)
	line1.text = game_lines.cut_line1[lines_to_read]
	line1.visible = true
	if game_lines.cut_line2[lines_to_read] != "_":
		line2.text = game_lines.cut_line2[lines_to_read]
		line2.visible = true
	else:
		line2.visible = false
	line3.visible = false
	if lines_to_read == 0:
		bubble.play("Spawn")
	if lines_to_read == 4:
		$AP_Worm.play("Pos1")
	elif lines_to_read == 6:
		$AP_Worm.play("Pos2")
	elif lines_to_read == 8:
		$AP_Worm.play("Pos3")
	elif lines_to_read == 10:
		$AP_Worm.play("Pos4")
	SoundManager.play_varied("politician", "talk", randf_range(0.9, 1.1))

## Trigger everytime a Mac or Tissue dies, but not on neuron grabs.
func anim_ouch():
	ouch_eye = randi() % 2 + 1
	ouch_brow = randi() % 3 + 1
	hit.play("Hit")
	idle.play("Idle")
	eyes.play("Ouch"+str(ouch_eye))
	brows.play("Ouch"+str(ouch_brow))
	print(ouch_eye)
	
	animation_length = face.get_animation("Ouch").length
	random_time = randf() * animation_length
	face.play("Ouch")
	face.seek(random_time)
	mouth.play("Not_Talking")
	#SoundManager.play_varied("politician", "durr", randf_range(0.7, 1.2))

## Trigger when worm grabs a neuron
func anim_ouch_blurb():
	ouch_eye = randi() % 2 + 1
	ouch_brow = randi() % 3 + 1
	hit.play("Hit")
	idle.play("Idle")
	eyes.play("Ouch"+str(ouch_eye))
	brows.play("Ouch"+str(ouch_brow))
	
	animation_length = face.get_animation("Ouch").length
	random_time = randf() * animation_length
	face.play("Ouch")
	face.seek(random_time)
	mouth.play("Ouch")
	lines_to_read = randi() % game_lines.game_line1.size()
	line1.text = game_lines.game_line1[lines_to_read]
	if game_lines.game_line2[lines_to_read] != "_":
		line2.text = game_lines.game_line2[lines_to_read]
		line2.visible = true
	else:
		line2.visible = false
	if game_lines.game_line3[lines_to_read] != "_":
		line3.text = game_lines.game_line3[lines_to_read]
		line3.visible = true
	else:
		line3.visible = false
	#SoundManager.play_varied("politician", "durr", randf_range(0.7, 1.2))

func _on_ap_hit_animation_finished(anim_name):
	if anim_name == "Hit":
		anim_relaxed_ramble()

func _on_ap_mouth_animation_finished(anim_name):
	if anim_name == "Talking":
		show_prompt.emit()
		if lines_to_read <= script_size:
			lines_to_read += 1
			if lines_to_read > script_size:
				is_done.emit()
			can_skip = true

func talk_sfx():
	SoundManager.play_varied("politician", "talk", randf_range(0.9, 1.1))
##
