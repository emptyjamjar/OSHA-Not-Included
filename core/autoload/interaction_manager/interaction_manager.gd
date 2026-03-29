extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $Label

const base_text = "[E] to "

var active_areas : Array[InteractionArea] = []
var can_interact = false

#Signal for invalid interaction.
signal invalid_interact


func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	# The find method returns -1 if area is not in list
	if index != -1:
		active_areas.remove_at(index)

func invalid_interaction():
	#Mostly just for the inventory to know when to wiggle (that sounds weird).
	invalid_interact.emit()

func _process(_delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		# active_areas[0] will contain closest interactable object
		active_areas.sort_custom(_sort_by_distance_to_player)

		label.text = base_text + active_areas[0].action_name
		# Move the label to the interactable object
		label.global_position = active_areas[0].global_position
		# Offset position by the font size plus 10
		label.global_position.y -= label.size.y + 10
		label.global_position.x -= label.size.x / 2
		label.show()
	else:
		label.hide()

func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && can_interact:
		# Check if player is within an interaction area
		if active_areas.size() <= 0:
			return
		# Otherwise interact with object
		can_interact = false
		label.hide()
		
		await active_areas[0].interact.call()
		can_interact = true
		
