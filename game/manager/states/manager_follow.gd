extends State
class_name ManagerFollow

@export var manager: CharacterBody2D
var player: CharacterBody2D
var animated_sprite : AnimatedSprite2D
var move_direction: Vector2
@export var move_speed := 40.0

func Enter():
	animated_sprite = manager.get_node("AnimatedSprite2D")
	player = get_tree().get_first_node_in_group("player")
	
func Physics_Update(delta: float) -> void:
	# get the direction between player and manager
	var direction = player.global_position - manager.global_position
	move_direction = direction
	update_animation()
	manager.velocity = direction.normalized() * move_speed
	# in case lost or touch player 
	if not manager.vision_cone.is_entity_visible(player): 
		transitioned.emit(self, "recovery")
		return 
	

func update_animation(): 
	if move_direction == Vector2.ZERO: 
		return # no movement, keep current animation 
	
	if abs(move_direction.x) > abs(move_direction.y): 
		# horizontal movement
		if move_direction.x > 0: 
			animated_sprite.flip_h = false
			animated_sprite.play("move_right")
		else: 
			animated_sprite.flip_h = true
			animated_sprite.play("move_right")
	else: 
		# vertical movement
		if move_direction.y > 0: 
			animated_sprite.play("move_down")
		else: 
			animated_sprite.play("move_up")
	 
