class_name Player extends CharacterBody2D


@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var viewport_rect = get_viewport_rect()

@export var move_speed := 250
@export var push_speed := 100
@export var sprint_speed := 2

#wasd is the movement for move_(direction). 
func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
	
	if (Input.is_action_pressed("sprint")):
		move_and_collide(input_direction * delta * (move_speed * sprint_speed))
	else:
		move_and_collide(input_direction * delta * move_speed)

	var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
