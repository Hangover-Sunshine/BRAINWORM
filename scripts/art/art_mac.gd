extends Node2D

@onready var ap_motion = $AP_Motion
@onready var ap_blink = $AP_Blink

@onready var death = $Death
@onready var trail = $Skeleton/Trail
@onready var body = $Skeleton/Body
@onready var head = $Skeleton/Head
@onready var face = $Skeleton/Face

# 0 = N/A, 1 = Left, 2 = Up, 3 = Right, 4 = Down
var direction = 0

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
	marker_body = marker.get_node("Marker_Body")
	marker_head = marker.get_node("Marker_Head")
	marker.visible = false
	marker.position = Vector2(0,0)
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

## Macs animation functions - *Keep on "Idle" even when Mac moves.
func spawn_mac():
	ap_motion.play("Spawn")
##

func idle_mac():
	ap_motion.play("Idle")
##

func kill_mac():
	ap_motion.play("Die")
##

## Trigger function, checks for number and points in direction.
## Only use when they are about to go to another space. Avoid early use.
func point_marker():
	if direction == 1:
		# going left
		marker.position = Vector2(-64,0)
		marker.visible = true
	elif direction == 2:
		# going up
		marker.position = Vector2(0,-64)
		marker.visible = true
	elif direction == 3:
		# going right
		marker.position = Vector2(64,0)
		marker.visible = true
	elif direction == 4:
		# going down
		marker.position = Vector2(0,64)
		marker.visible = true
##

## Right before Mac moves, trigger function to remove marker.
## Marker will move with Mac if triggered late.
func remove_marker():
	marker.position = Vector2(0,0)
	marker.direction = 0
	marker.visible = false
##
