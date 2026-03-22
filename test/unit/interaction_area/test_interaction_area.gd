extends GutTest

## This test script is for the interaction_area.gd script which contains the interaction area
## for items and other interactable objects.
## Since this is a component talking to an autoload, some careful testing is needed.
var _area: InteractionArea
var _registered: bool = false

func _on_area_registered(area: InteractionArea) -> void:
	if area == _area:
		_registered = true

func _on_area_unregistered(area: InteractionArea) -> void:
	if area == _area:
		_registered = false

func before_each() -> void:
	_area = InteractionArea.new()

func after_each() -> void:
	_area.free()

## Tests if registering an area when a trespasser node appears inside functions
func test_register_area() -> void:
	# create a node to act as a trespasser
	var trespasser = Node2D.new()
	# register into the area the trespasser node
	_area._on_body_entered(trespasser)
	# confirm that the _area in InteractionManager is in the active areas
	assert_true(InteractionManager.active_areas.has(_area), "Area should be registered after body entered")
	# manually remove _area from InteractionManager in active areas
	InteractionManager.active_areas.erase(_area)
	# free trespasser node
	trespasser.free()

## Tests if after registering a trespasser node, that it can unregister the area
func test_unregister_area()->void:
	# create a node to act as a trespasser
	var trespasser = Node2D.new()
	# register into the area the trespasser node
	_area._on_body_entered(trespasser)
	# unregister the trespasser node from the area
	_area._on_body_exited(trespasser)
	# confirm that the _area in InteractionManager is not in active areas
	assert_false(InteractionManager.active_areas.has(_area), "Area should be unregistered after body exited")
	# free trespasser node
	trespasser.free()
	
	
