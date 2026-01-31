extends CharacterBody2D


@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

@export var move_speed := 250
@export var push_speed := 100

func _physics_process(delta: float) -> void:
	var move_vec = Vector2()
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	if Input.is_action_pressed("move_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("move_down"):
		move_vec.y += 1
		
	move_and_collide(move_vec * delta * move_speed)

	
