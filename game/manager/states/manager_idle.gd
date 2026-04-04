extends State
class_name ManagerIdle 

@export var manager: CharacterBody2D
@export var move_speed := 10.0 
var player: CharacterBody2D

var move_direction : Vector2
var wander_time: float

func randomize_wander(): 
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)

func Enter(): 
	print("Enter - begins to wander")
	player = get_tree().get_first_node_in_group("player")
	randomize_wander()

func Update(delta: float): 
	if wander_time > 0: 
		wander_time -= delta 
	else:
		randomize_wander()
		
func Physics_Update(delta: float): 
	if manager: 
		manager.velocity = move_direction * move_speed
	else: 
		print("NO MANAGER EXIST")
	var direction = player.global_position - manager.global_position
	if direction.length() < 30: 
		transitioned.emit(self, "follow")
