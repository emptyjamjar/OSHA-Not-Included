extends Area2D

signal entity_entered_vision 
signal entity_exited_vision 

var vision_range: float # how far the cone extends 
var vision_angle: float # cone width in degrees
var vision_layers: int # which collision layers to detect (must) 

var update_interval: float # how often does it check? This is primarily for performance reason?
var detected_nodes: Array # current visible entities/nodes 
var show_vision: bool # toggle vision on/off

#API methods
func get_visible_entities() -> void: # will return Array  
	pass # returns all entities/nodes in cone 
	
func get_closet_visible_entity() -> void: # will return Node 
	pass # returns the nearest detected entity
	
#Queries
func is_entity_visible(entity: Node) -> void: # will retun bool 
	pass # check if specific entity is visible
	
func get_entities_by_group(group: String) -> void: # return Array 
	pass # filters by group (player, manager, etc.) 
	
func set_vision_parameters(range: float, angle: float) -> void: 
	pass # adjust vision during gameplay (runtime) 
	
# Config 
func enable() -> void: # turn detection on 
	show_vision = true
	
func disable() -> void: # turn detection off 
	show_vision = false 
	
