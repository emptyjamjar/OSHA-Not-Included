extends State
class_name ManagerPatrol

@export var manager: CharacterBody2D
var player: CharacterBody2D
var animated_sprite : AnimatedSprite2D 
@export var move_speed := 40.0
var move_direction : Vector2
var index := 0
var wait_timer := 0.0

# for checking animation midway along the path 
var checking := false 
var check_timer := 0.0
@export var check_chance := 0.3 # 30% chance to stop and check 
@export var check_min_time := 1.0 # seconds
@export var check_max_time := 2.5

func Enter():
	player = get_tree().get_first_node_in_group("player")
	animated_sprite = manager.get_node("AnimatedSprite2D")
	wait_timer = 0.0
	checking = false 
	check_timer = 0.0
	
func Physics_Update(delta: float) -> void:
	# If player is visible, stop patrolling
	if manager.vision_cone.is_entity_visible(player):
		transitioned.emit(self, "follow")
		return
	# checking animation 
	if checking: 
		animated_sprite.play("check_board")
		check_timer -= delta
		if check_timer <= 0.0: 
			# done checking : re-enable vision + resume patrol
			checking = false
			manager.vision_cone.enable()
		return
	# normal behaviour
	if manager.waiting: 
		return
	var path = manager.current_path
	if path.is_empty(): 
		print("WARNING: current_path is empty")
		manager.choose_random_path()
		return 
	# ensure index is valid
	if manager.current_index >= path.size(): 
		# print("WARNING: index out of range")
		manager.wait_after_finished_a_path()
		manager.choose_random_path()
		return 
		
	# move toward the current waypoint
	var target = path[manager.current_index].global_position 
	var direction = (target - manager.global_position).normalized() 
	manager.velocity = direction * move_speed
	manager.move_and_slide()
	
	if manager.global_position.distance_to(target) < 8: 
		wait_timer += delta
		manager.velocity = Vector2()
		manager.current_index += 1 
		if randf() < check_chance: 
			_start_checking()
			return 
		# Finish path 
		if manager.current_index >= path.size(): 
			manager.wait_after_finished_a_path()
			manager.choose_random_path()
			return
	
func _start_checking():
	checking = true
	check_timer = randf_range(check_min_time, check_max_time)
	manager.vision_cone.disable()
	animated_sprite.play("check_board")
	
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
