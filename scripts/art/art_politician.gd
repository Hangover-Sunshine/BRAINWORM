extends Node2D

@onready var idle = $AP_Idle
@onready var eyes = $AP_Eyes
@onready var mouth = $AP_Mouth
@onready var brows = $AP_Brows
@onready var face = $AP_Face
@onready var hit = $AP_Hit
@onready var testing_timer = $"../Testing_Timer"

var animation_length
var random_time
var ouch_eye
var ouch_brow

## Trigger only at beginning of cutscene / when not talking
func anim_relaxed():
	idle.play("Idle")
	eyes.play("Resting")
	mouth.play("Not_Talking")
	brows.play("Resting")
	face.play("Not_Talking")

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

func _on_ap_hit_animation_finished(anim_name):
	if anim_name == "Hit":
		anim_relaxed_ramble()
