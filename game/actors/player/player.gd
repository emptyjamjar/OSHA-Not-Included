class_name Player extends CharacterBody2D


@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var viewport_rect = get_viewport_rect()

@export var move_speed := 250
@export var push_speed := 100
@export var sprint_speed := 2

#wasd is the movement for move_(direction). 
func _physics_process(delta: float) -> void:
	var move_vec = Vector2()
	if Input.is_action_pressed("sprint"):
		if Input.is_action_pressed("move_left"):
			move_vec.x -= 1 * sprint_speed
		if Input.is_action_pressed("move_right"):
			move_vec.x += 1 * sprint_speed
		if Input.is_action_pressed("move_up"):
			move_vec.y -= 1 * sprint_speed
		if Input.is_action_pressed("move_down"):
			move_vec.y += 1 * sprint_speed
	else:
		if Input.is_action_pressed("move_left"):
			move_vec.x -= 1
		if Input.is_action_pressed("move_right"):
			move_vec.x += 1
		if Input.is_action_pressed("move_up"):
			move_vec.y -= 1
		if Input.is_action_pressed("move_down"):
			move_vec.y += 1
		
	move_and_collide(move_vec * delta * move_speed)
	var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
