extends Node2D

@onready var ap_motion = $AP_Motion
@onready var ap_blink = $AP_Blink

@onready var death = $Death
@onready var trail = $Skeleton/Trail
@onready var body = $Skeleton/Body
@onready var head = $Skeleton/Head
@onready var face = $Skeleton/Face

# Declaring variables to hold the marker and its parts
var marker
var marker_body
var marker_head
##

# Declaring variables to hold colors.
var mac_color = 0
var lite_color = Color8(1,1,1,1)
var mid_color = Color8(1,1,1,1)
var dark_color = Color8(1,1,1,1) 
##

func _ready():
	marker = $Art_Marker
	marker.emitted = true
	marker_body = marker.get_node("Marker_Body")
	marker_head = marker.get_node("Marker_Head")
	randomize_color()

func randomize_color():
	mac_color = randi() % 4
	if mac_color == 0:
		# purple
		lite_color = Color8(234,173,237,255)
		mid_color = Color8(144,94,169,255)
		dark_color = Color8(64,47,74,255)
		death.color = lite_color
		trail.color = lite_color
		body.color = lite_color
		head.color = mid_color 
		face.modulate = dark_color
		marker_body.color = lite_color
		marker_head.color = mid_color
	elif mac_color == 1:
		# green
		lite_color = Color8(156,243,199,255)
		mid_color = Color8(30,188,115,255)
		dark_color = Color8(22,90,76,255)
		death.color = lite_color
		trail.color = lite_color
		body.color = lite_color
		head.color = mid_color
		face.modulate = dark_color
		marker_body.color = lite_color
		marker_head.color = mid_color
	elif mac_color == 2:
		# orange
		lite_color = Color8(255,191,140,255)
		mid_color = Color8(249,155,81,255)
		dark_color = Color8(178,60,64,255)
		death.color = lite_color
		trail.color = lite_color
		body.color = lite_color
		head.color = mid_color
		face.modulate = dark_color
		marker_body.color = lite_color
		marker_head.color = mid_color
	elif mac_color == 3:
		# blue
		lite_color = Color8(147,196,247,255)
		mid_color = Color8(77,155,230,255)
		dark_color = Color8(50,51,83,255)
		death.color = lite_color
		trail.color = lite_color
		body.color = lite_color
		head.color = mid_color
		face.modulate = dark_color
		marker_body.color = lite_color
		marker_head.color = mid_color
##

## Macs animation functions - *Use "Idle" for when Mac idles and moves.
func spawn_mac():
	ap_motion.play("Spawn")
##

func idle_mac():
	ap_motion.play("Idle")
##

func kill_mac():
	ap_motion.play("Die")
##
