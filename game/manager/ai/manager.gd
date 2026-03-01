extends CharacterBody2D
class_name Manager

var waiting := false 
var wait_time := 0.0
var wait_timer := 0.0 

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
	
# game.tscn 
# (0,0) is the top left of the current viewport or root node 
# X increase to the right
# Y increase downward
@export var patrol_paths_at_root: Node2D
var path_container: Array = []
var current_path: Array = []
var current_index := 0 

func _ready() -> void:
	if patrol_paths_at_root == null:
		print("No path to begin with -- Break from here") 
		return 
	for path_node in patrol_paths_at_root.get_children(): 
		var points_num := []
		for points in path_node.get_children(): 
			if points is Node2D: 
				points_num.append(points)
		path_container.append(points_num)
	print(path_container)
	choose_random_path()
		
func choose_random_path(): 
	if path_container.size() <= 0:
		print("Has no path in the path_container") 
		return 
	current_path = path_container[randi() % path_container.size()]
	current_index = 0
	waiting = false 
	wait_timer = 0.0

func wait_after_finished_a_path(): 
	waiting = true 
	wait_time = randf_range(0.5, 1.0) #random wait duration 
	wait_timer = 0.0
	
func _physics_process(delta: float) -> void:
	if waiting: 
		wait_timer += delta
		velocity = Vector2()
		if wait_timer >= wait_time: 
			choose_random_path()
		return 
	move_and_slide()
