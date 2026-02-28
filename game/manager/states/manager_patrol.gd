extends State
class_name ManagerPatrol

@export var manager: CharacterBody2D
var player: CharacterBody2D
@export var move_speed := 40.0

var index := 0
var wait_timer := 0.0

func Enter():
	player = get_tree().get_first_node_in_group("player")
	wait_timer = 0.0
	
func Physics_Update(delta: float) -> void:
	var target = manager.patrol_points[index].pos 
	var direction = (target - manager.global_position).normalized() 
	manager.velocity = direction * move_speed
	manager.move_and_slide()
	
	if manager.global_position.distance_to(target) < 8: 
		wait_timer += delta
		manager.velocity = Vector2()
		if wait_timer >= manager.patrol_points[index].wait:
			index = (index + 1) % manager.patrol_points.size() 
			wait_timer = 0.0
			
	
