extends CollisionPolygon2D

signal entity_entered_vision(entity)
signal entity_exited_vision(entity)

@export var colour : Color = Color(Color.RED, 0.3)

@export var vision_range: float = 250.0 # how far the cone extends 
@export var vision_angle: float = 120.0 # cone width in degrees
@export var vision_layers: int = 1 # which collision layers to detect (must) 

@export var update_interval: float = 0.1 # how often does it check? This is primarily for performance reason?
var detected_nodes: Array = [] # current visible entities/nodes 
@export var show_vision: bool  = true # toggle vision on/off
var _timer := 0.0

func _ready(): 
	# Build the cone polygon once 
	#_update_polygon()
	set_process(true)
	
func _process(delta): 
	if not show_vision: 
		return 
	_timer += delta 
	if _timer >= update_interval: 
		_timer = 0 
		_scan_for_entities()
	queue_redraw()
	
	
# detection logic 
func _scan_for_entities(): 
	#print("Bodies: ", get_parent().get_overlapping_bodies())
	var area := get_parent() as Area2D
	var bodies = area.get_overlapping_bodies()
	
	var new_detected = []
	for body in bodies: 
		if not body is Node2D: 
			continue 
		if _is_in_cone(body): 
			new_detected.append(body)
			if body not in detected_nodes: 
				detected_nodes.append(body)
				print("VisionCone script active on:", self)
				emit_signal("entity_entered_vision", body)
	# check for exits 
	for old in detected_nodes.duplicate(): 
		if old not in new_detected: 
			detected_nodes.erase(old)
			print("VisionCone script active on:", self)
			emit_signal("entity_exited_vision", old)

#cone math: distance + angle + LOS
func _is_in_cone(entity: Node2D) -> bool: 
	var origin = global_position
	var target_pos = entity.global_position
	var to_target = target_pos - origin
	
	# 1. Distance check 
	if to_target.length() > vision_range: 
		return false 
		
	# 2. Angle check 
	var forward = Vector2.RIGHT.rotated(get_parent().global_rotation)
	var angle = forward.angle_to(to_target.normalized())
	
	if abs(angle) > deg_to_rad(vision_angle / 2.0): 
		return false 
	# 3. Raycast LOS check 
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, target_pos)
	query.exclude = [self, get_parent()] # avoid hitting the cone itself 
	var result = space.intersect_ray(query)
	
	if result.size() > 0 and result["collider"] != null: 
		# If we hit something that is not the target entity, LOS is blocked
		if result["collider"] != entity: 
			return false 
	return true 
	
	
#API methods
func get_visible_entities() -> Array: # will return Array  
	return detected_nodes.duplicate()
	
func get_closet_visible_entity() -> Node: # will return Node
	if detected_nodes.is_empty(): 
		return 
	var origin = global_position
	var closest = detected_nodes[0]
	var min_dist = origin.distance_to(closest.global_position)
	
	for node in detected_nodes: 
		var distance = origin.distance_to(node.global_position)
		if distance < min_dist: 
			min_dist = distance 
			closest = node
	return closest # returns the nearest detected entity
	
#Queries
func is_entity_visible(entity: Node) -> bool: # will retun bool 
	return entity in detected_nodes # check if specific entity is visible
	
func get_entities_by_group(group: String) -> Array: # return Array 
	return detected_nodes.filter(func(e): return e.is_in_group(group)) # filters by group (player, manager, etc.) 
	
func set_vision_parameters(range: float, angle: float) -> void: 
	# adjust vision during gameplay (runtime)
	vision_range = range
	vision_angle = angle
	#_update_polygon()
	queue_redraw() 
	
# Config 
func enable() -> void: # turn detection on 
	show_vision = true
	
func disable() -> void: # turn detection off 
	show_vision = false 

func _draw() -> void: 
	if not show_vision: return  
	var points = get_polygon()
	draw_colored_polygon(points, colour)
	
func change_colour(newColour: Color): 
	colour = newColour
	queue_redraw()
