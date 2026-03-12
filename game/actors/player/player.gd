class_name Player extends CharacterBody2D

## Player controller: mainly responsible for movement
## and animation.

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var energy_component: EnergyComponent = $EnergyComponent
@onready var needs_component: NeedsComponent = $NeedsComponent
@onready var sanity_component: SanityComponent = $SanityComponent
@onready var sanity_area: Area2D = $SanityArea
@onready var viewport_rect = get_viewport_rect()

@export var move_speed := 150
@export var slow_speed := 125
@export var push_speed := 20
@export var sprint_speed := 1.5
var player_needs: bool = true
var is_lifting: bool = false
var last_direction = Vector2.DOWN

# Used for the idle timer component attached to the player,
# hopefully with minimal player gd changes
var idle: bool = true


func _init() -> void:
	add_to_group("player")


func _ready() -> void:
	InteractionManager.player = self
	InteractionManager.can_interact = true


func _physics_process(_delta: float) -> void:
	# wasd is the movement for move_(direction). 
	var direction = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
	
	if direction != Vector2.ZERO:
		idle = false
		last_direction = direction
		
		if abs(direction.x) > abs(direction.y):
			animated_sprite.play("move_right" if direction.x > 0 else "move_left")
		else:
			animated_sprite.play("move_down" if direction.y > 0 else "move_up")
	else:
		idle = true
		# last_direction determines idle animation
		if abs(last_direction.x) > abs(last_direction.y):
			animated_sprite.play("idle_right" if last_direction.x > 0 else "idle_left")
		else:
			animated_sprite.play("idle_down" if last_direction.y > 0 else "idle_up")

	if energy_component.draining:
		if (Input.is_action_pressed("sprint")):
			animated_sprite.speed_scale = 1.5
			velocity = direction * slow_speed * sprint_speed
			move_and_slide()
		else:
			animated_sprite.speed_scale = 1
			velocity = direction * slow_speed
			move_and_slide()
	else:
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
	const HUD_LEFT = 96.0
	position.x = clamp(position.x, HUD_LEFT + sprite_width_half, screen_size.x - sprite_width_half)
	position.y = clamp(position.y, 0 + sprite_height_half, screen_size.y - sprite_height_half)
	
	
	
func _process(_delta: float) -> void:
	#connects the bathroom to the player needs
	if player_needs:
		needs_component.rising = true
	else:
		needs_component.rising = false
	


## Returns the full dimensions of the player's animated sprite in a Vector2i
func get_animated_sprite_dimensions() -> Vector2i:
	return animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame).get_size()


func _on_sanity_area_area_entered(area: Area2D) -> void:
	for overlapped_body in sanity_area.get_overlapping_bodies():
		if overlapped_body.is_in_group("Manager"):
			sanity_component.decrease(10)
