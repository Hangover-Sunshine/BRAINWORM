extends CharacterBody2D

@export var PlayerWalkSpeed:float = 200

func _physics_process(_delta):
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("left"):
		velocity.x -= PlayerWalkSpeed
	##
	if Input.is_action_pressed("right"):
		velocity.x += PlayerWalkSpeed
	##
	
	if Input.is_action_pressed("up"):
		velocity.y -= PlayerWalkSpeed
	##
	if Input.is_action_pressed("down"):
		velocity.y += PlayerWalkSpeed
	##
	
	move_and_slide()
##
