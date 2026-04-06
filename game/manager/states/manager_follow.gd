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
	update_animation()
	manager.velocity = direction.normalized() * move_speed
	#if direction.length() > 25: 
		## move manager towards the player
		#manager.velocity = direction.normalized() * move_speed
	#else: 
		## stands still
		#manager.velocity = Vector2()
		 #
	#if direction.length() > 50: 
		#transitioned.emit(self, "idle")

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
	 
