extends GutTest

## This test script is for the interaction_manager, and is designed to test it's initial state and
## any methods inside.
## Updated: 2026_03_03
# Notes:
# 1. no initial state test, as this is an autoload

# Globals
var im := InteractionManager
var cleanup:Array[Node] = []

## Run before all tests
## Reset variables to default state
func before_all():
	#var active_areas : Array[InteractionArea] = []
	#var can_interact = false
	im.player = Node2D.new()	# Mock player created for testing purposes
	im.label = Label.new()		# mock label created for testing purposes
	im.active_areas = []
	im.can_interact = false
	
	cleanup.append(im.player)
	cleanup.append(im.label)
	im.set_process(true)	# enables interaction_manager to process things
	

## Run after all tests
## Free all nodes from memory
func after_each():
	im.set_process(false)	# prevents interaction_manager from annoying processing freed memory items
	for each_node in cleanup:
		each_node.queue_free()

## Test register_area()
## Tests if a new given interaction area given is properly added to active_areas.
func test_register_area()->void:
	var new_area = InteractionArea.new()
	im.register_area(new_area)
	assert_eq(im.active_areas.has(new_area), true, "New interaction area was not properly registered.")
	new_area.free()	# frees memory to prevent orphan errors
	

## Test unregister_area()
## Tests if an area is properly unregistered/removed from active_areas
func test_unregister_area()->void:
	var new_area = InteractionArea.new()
	im.register_area(new_area)
	im.unregister_area(new_area)
	assert_eq(im.active_areas.has(new_area), false, "New interaction area was not properly unregistered.")
	new_area.free()	# frees memory to prevent orphan errors
	

## Test _sort_by_distance_to_player()
## Tests if area 1 is closer than area 2
func test_sort_by_distance_to_player()->void:
	var new_area1 = InteractionArea.new()
	var new_area2 = InteractionArea.new()
	
	im.player.global_position = Vector2(0,0)
	# Same position
	new_area1.global_position = Vector2(0,0)
	new_area2.global_position = Vector2(0,0)
	var result = im._sort_by_distance_to_player(new_area1, new_area2)
	assert_eq(result, false, "Distance between both areas are the same, but did not return false")
	# Area 2 is closer
	new_area1.global_position = Vector2(21,0)
	new_area2.global_position = Vector2(5,0)
	result = im._sort_by_distance_to_player(new_area1, new_area2)
	assert_eq(result, false, "Area 2 is closer, but did not return false")
	# Area 1 is closer
	new_area1.global_position = Vector2(21,0)
	new_area2.global_position = Vector2(22,0)
	result = im._sort_by_distance_to_player(new_area1, new_area2)
	assert_eq(result, true, "Area 1 is closer, but did not return true")
	# free memory
	new_area1.free()
	new_area2.free()
	
## Test _input()
## Tests when the correct input event is pressed, if the the player can interact
func test_input()->void:
	# internal note: this was a pain in the ass to do
	# Setup
	var mock_area = InteractionArea.new()
	mock_area.interact = func(): pass
	im.active_areas = [mock_area]
	
	im.can_interact = true
	
	# Test: simulate incorrect input
	var wrong_event = InputEventKey.new()
	wrong_event.pressed = true
	wrong_event.keycode = KEY_A
	im._input(wrong_event)
	assert_eq(im.can_interact, true, "can_interact should remain true for wrong input")
	
	# Test: simulate correct input, active_areas = 0
	im.active_areas = []
	var correct_event = InputEventAction.new()
	correct_event.action = "interact"
	correct_event.pressed = true
	im._input(correct_event)
	assert_eq(im.can_interact, true, "can_interact should remain true when no active areas")
	
	# Test: simulate correct input, active_areas > 0
	im.active_areas = [mock_area]
	im.can_interact = true
	im._input(correct_event)
	#await im.get_tree().process_frame  # Wait for async to complete
	assert_eq(im.can_interact, true, "can_interact should be true after interaction completes")
	
	# Free memory
	mock_area.free()
