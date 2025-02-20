extends Node2D

@onready var idle = $AP_Idle
@onready var eyes = $AP_Eyes
@onready var mouth = $AP_Mouth
@onready var brows = $AP_Brows
@onready var face = $AP_Face
@onready var hit = $AP_Hit
@onready var textbox = $Skeleton/Body/Suit/TextBox

@onready var testing_timer = $Testing_Timer

var animation_length
var random_time
var ouch_eye
var ouch_brow

var game_lines
var script_vbox
var line1
var line2
var line3 

func _ready():
	anim_relaxed_ramble()
	game_lines = $Skeleton/Body/Suit/TextBox
	script_vbox = $Skeleton/Body/Suit/TextBox/Control/Margin1/Margin2/VBox
	line1 = script_vbox.find_child("Line1")
	line2 = script_vbox.find_child("Line2")
	line3 = script_vbox.find_child("Line3")

## Trigger only at beginning of cutscene / when not talking
func anim_relaxed():
	idle.play("Idle")
	eyes.play("Resting")
	mouth.play("Not_Talking")
	brows.play("Resting")
	face.play("Not_Talking")
	textbox.visible = false

## Trigger for gameplay, when he is doing his speech
func anim_relaxed_ramble():
	idle.play("Idle")
	eyes.play("Resting")
	mouth.play("Ramble")
	brows.play("Resting")
	
	animation_length = face.get_animation("Normal").length
	random_time = randf() * animation_length
	face.play("Normal")
	face.seek(random_time)
	textbox.visible = false

## Trigger for cutscene, everytime he says a line
func anim_relaxed_talking():
	idle.play("Idle")
	eyes.play("Resting")
	mouth.play("Talking")
	brows.play("Resting")
	
	animation_length = face.get_animation("Normal").length
	random_time = randf() * animation_length
	face.play("Normal")
	face.seek(random_time)

## Trigger everytime something dies (i.e., neuron, maks, tissue).
func anim_ouch():
	ouch_eye = randi() % 3 + 1
	ouch_brow = randi() % 3 + 1
	hit.play("Hit")
	idle.play("Idle")
	eyes.play("Ouch"+str(ouch_eye))
	brows.play("Ouch"+str(ouch_brow))
	
	animation_length = face.get_animation("Ouch").length
	random_time = randf() * animation_length
	face.play("Ouch")
	face.seek(random_time)
	mouth.play("Not_Talking")

## Trigger when he grabs a neuron
func anim_ouch_blurb():
	ouch_eye = randi() % 3 + 1
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
	var lines_to_read = randi() % game_lines.game_line1.size()-1
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

func _on_ap_hit_animation_finished(anim_name):
	if anim_name == "Hit":
		anim_relaxed_ramble()
		testing_timer.start

func _on_testing_timer_timeout():
	anim_ouch_blurb()
	testing_timer.stop
