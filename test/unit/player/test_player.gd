extends GutTest

## This test script runs test on the player.gd script.


# These aren't used as far as I know?

#@onready var energy_component: EnergyComponent = $EnergyComponent
#@onready var needs_component: NeedsComponent = $NeedsComponent

# Reference for default values
#@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
#@export var move_speed := 150
#@export var push_speed := 20
#@export var sprint_speed := 1.5
#var player_needs: bool = true
#var is_lifting: bool = false
#var last_direction = Vector2.DOWN

var player:Player

## Runs just before running all the tests
func before_all():
	player = Player.new()
	player.energy_component = EnergyComponent.new()
	player.needs_component = NeedsComponent.new()
	player.animated_sprite = AnimatedSprite2D.new()

## Runs after all tests are done
func after_all():
	player.energy_component.free()
	player.needs_component.free()
	player.animated_sprite.free()
	player.free()

func before_each():
	var move_speed := 150
	var push_speed := 20
	var sprint_speed := 1.5
	var player_needs: bool = true
	var is_lifting: bool = false
	var last_direction = Vector2.DOWN
	player.move_speed = move_speed
	player.push_speed = push_speed
	player.sprint_speed = sprint_speed
	player.player_needs = player_needs
	player.is_lifting = is_lifting
	player.last_direction = last_direction

## Test player interaction manager setup
func test_ready_sets_interaction_manager_values():
	InteractionManager.player = player
	InteractionManager.can_interact = true

	assert_eq(InteractionManager.player, player, "_ready should register player in InteractionManager")
	assert_true(InteractionManager.can_interact, "_ready should enable interaction")
	
	InteractionManager.player = null
	InteractionManager.can_interact = false
