extends State
class_name ManagerPatrol

@export var manager: CharacterBody2D
var player: CharacterBody2D
@export var move_speed := 40.0

# Compute the bouding box of all tiles you've painted 


var index := 0
var wait_timer := 0.0

func Enter():
	player = get_tree().get_first_node_in_group("player")
	wait_timer = 0.0
	
func Physics_Update(delta: float) -> void:
	if manager.waiting: 
		return
	var path = manager.current_path
	if path.is_empty(): 
		print("WARNING: current_path is empty")
		return 
	if manager.current_index >= path.size(): 
		# print("WARNING: index out of range")
		manager.wait_after_finished_a_path()
		return 
	var target = path[manager.current_index].global_position 
	var direction = (target - manager.global_position).normalized() 
	manager.velocity = direction * move_speed
	manager.move_and_slide()
	
	if manager.global_position.distance_to(target) < 8: 
		wait_timer += delta
		manager.velocity = Vector2()
		manager.current_index += 1 
		#if manager.current_index >= path.size(): 
			#manager.choose_random_path()
		#else: 
			## wait time logic here
			#pass 
			
	
