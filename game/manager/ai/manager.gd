extends CharacterBody2D
class_name Manager

var waiting := false 
var wait_time := 0.0
var wait_timer := 0.0 


# game.tscn 
# (0,0) is the top left of the current viewport or root node 
# X increase to the right
# Y increase downward
@export var patrol_paths_at_root: Node2D
@export var out_bounds_area: Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision_cone = $VisionCone/CollisionPolygon2D

var path_container: Array = []
var current_path: Array = []
var current_index := 0 

func _ready() -> void:
	add_to_group("agents")
	vision_cone.entity_entered_vision.connect(_on_entity_seen)
	vision_cone.entity_exited_vision.connect(_on_entity_lost)
	self.hide()
	await get_tree().create_timer(5).timeout
	self.show()
	
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
	#print("Manager starting inside polygon?", out_bounds_area.overlaps_body(self))
	# Connect out-of-bounds signal 
	if out_bounds_area: 
		print("Entered")
		out_bounds_area.connect("agent_entered", Callable(self, "_on_out_of_bounds"))
		
func _on_entity_seen(entity): 
	if entity.is_in_group("player"): 
		$StateMachine.on_child_transition($StateMachine.current_state, "follow")

func _on_entity_lost(entity): 
	if entity.is_in_group("player"): 
		$StateMachine.on_child_transition($StateMachine.current_state, "idle")

func _on_out_of_bounds(agent): 
	print("Reaching this point")
	if agent != self: 
		return 
	# 1. Respawn
	visible = false 
	set_physics_process(false)
	velocity = Vector2()
	# 2. Choose new path 
	choose_random_path()
	# 3. Teleport to start of new path 
	if current_path.size() > 0: 
		global_position = current_path[0].global_position 
	# 4. Reset patrol state 
	waiting = false 
	wait_timer = 0.0
	current_index = 0 
	# 5. Respawn 
	visible = true 
	set_physics_process(true)
	
	
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
	rotate_vision_cone()
	move_and_slide()

func rotate_vision_cone(): 
	var dir := velocity
	# If not moving, don't rotate 
	if dir.length() < 0.1: 
		return 
	# Horizontal movement
	if abs(dir.x) > abs(dir.y): 
		if dir.x > 0: 
			$VisionCone.rotation = 0 # facing right 
		else: 
			$VisionCone.rotation = PI # facing left
	else: 
		if dir.y > 0: 
			$VisionCone.rotation = PI / 2 # down 
		else: 
			$VisionCone.rotation = -PI / 2 # up 
	
