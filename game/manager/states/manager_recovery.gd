extends State
class_name ManagerRecover

@export var manager: CharacterBody2D
var animated_sprite: AnimatedSprite2D
var finished_checking := false 
var target_point: Vector2
var recovering := false
var timer := 0.0

@export var check_time := 1.5
@export var move_speed := 15.0

func Enter():
	animated_sprite = manager.get_node("AnimatedSprite2D")
	manager.vision_cone.disable()

	# Step 1: play check animation
	animated_sprite.play("check_board")
	timer = check_time
	recovering = true
	finished_checking  = false

	# Step 2: find nearest waypoint
	var path = manager.current_path
	if path.is_empty():
		manager.choose_random_path()
		path = manager.current_path

	var nearest_index := 0
	var nearest_dist := INF

	for point in range(path.size()):
		var d = manager.global_position.distance_to(path[point].global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest_index = point

	manager.current_index = nearest_index
	target_point = path[nearest_index].global_position


func Physics_Update(delta):
	# Step 1: finish checking animation
	if recovering:
		timer -= delta
		if timer > 0:
			return
		recovering = false
		finished_checking = true
		manager.vision_cone.enable()
		return
	if finished_checking: 
		# Step 2: walk to nearest waypoint
		var direction = (target_point - manager.global_position).normalized()
		manager.velocity = direction * move_speed
		manager.move_and_slide()

		if manager.global_position.distance_to(target_point) < 8:
			transitioned.emit(self, "patrol")
