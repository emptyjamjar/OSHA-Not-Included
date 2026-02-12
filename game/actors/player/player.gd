class_name Player extends CharacterBody2D


@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var viewport_rect = get_viewport_rect()

@export var move_speed := 250
@export var push_speed := 100
@export var sprint_speed := 1.5

func _init() -> void:
	add_to_group("player")

#wasd is the movement for move_(direction). 
func _physics_process(delta: float) -> void:
	var direction = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
	
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			animated_sprite.play("move_right" if direction.x > 0 else "move_left")
		else:
			animated_sprite.play("move_down" if direction.y > 0 else "move_up")
	else:
		animated_sprite.play("idle")
	
	if (Input.is_action_pressed("sprint")):
		animated_sprite.speed_scale = 1.5
		velocity = direction * move_speed * sprint_speed
		move_and_slide()
	else:
		animated_sprite.speed_scale = 1
		velocity = direction * move_speed
		move_and_slide()

	var screen_size = get_viewport_rect().size
	var sprite_width_half = get_animated_sprite_dimensions().x / 2.0
	var sprite_height_half = get_animated_sprite_dimensions().y / 2.0
	position.x = clamp(position.x, 0 + sprite_width_half, screen_size.x - sprite_width_half)
	position.y = clamp(position.y, 0 + sprite_height_half, screen_size.y - sprite_height_half)


## Returns the full dimensions of the player's animated sprite in a Vector2i
func get_animated_sprite_dimensions() -> Vector2i:
	return animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame).get_size()
