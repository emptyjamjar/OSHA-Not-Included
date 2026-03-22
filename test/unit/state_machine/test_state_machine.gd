extends GutTest
## This test script tests the state_machine.gd script, primarily on it's functionality

## Test state (mock state) for state machine
class TestState:
	extends State

	var enter_called := 0
	var exit_called := 0
	var update_called := 0

	func enter():
		enter_called += 1

	func exit():
		exit_called += 1

	func _update(delta):
		update_called += 1

## test No initial state
func test_ready_with_no_initial_state_does_not_set_current_state():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)

	var state_a = TestState.new()
	state_a.name = "Idle"
	sm.add_child(state_a)

	sm._ready()

	assert_null(sm.current_state, "current_state should remain null when no initial_state is assigned")
	assert_true(sm.states.has("idle"), "state should still be registered in the states dictionary")
	assert_eq(state_a.enter_called, 0, "enter should not be called when there is no initial state")

## Test after _ready()
func test_ready_calls_initial_state_enter_once():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)

	var idle = TestState.new()
	idle.name = "Idle"

	var walk = TestState.new()
	walk.name = "Walk"

	sm.add_child(idle)
	sm.add_child(walk)
	sm.initial_state = idle

	sm._ready()

	assert_eq(sm.current_state, idle, "current_state should be set to initial_state")
	assert_eq(idle.enter_called, 1, "initial state's enter should only be called once")

## Test transitioning between states
func test_on_child_transition_switches_to_new_state():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)

	var idle = TestState.new()
	idle.name = "Idle"

	var walk = TestState.new()
	walk.name = "Walk"

	sm.add_child(idle)
	sm.add_child(walk)
	sm.initial_state = idle

	sm._ready()
	sm.on_child_transition(idle, "Walk")

	assert_eq(idle.exit_called, 1, "old state should exit during transition")
	assert_eq(walk.enter_called, 1, "new state should enter during transition")
	assert_eq(sm.current_state, walk, "current_state should update to the new state")

## Test ignoring transitions
func test_on_child_transition_ignores_transition_from_non_current_state():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)

	var idle = TestState.new()
	idle.name = "Idle"

	var walk = TestState.new()
	walk.name = "Walk"

	sm.add_child(idle)
	sm.add_child(walk)
	sm.initial_state = idle

	sm._ready()

	# walk is not current_state here
	sm.on_child_transition(walk, "Idle")

	assert_eq(sm.current_state, idle, "current_state should remain unchanged when non-current state requests transition")
	assert_eq(idle.exit_called, 0, "current state should not exit")
	assert_eq(walk.enter_called, 0, "non-current state transition should do nothing")

## Test for process update on current state
func test_process_calls_update_on_current_state():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)

	var idle = TestState.new()
	idle.name = "Idle"

	sm.add_child(idle)
	sm.initial_state = idle
	sm._ready()

	sm._process(0.16)

	assert_eq(idle.update_called, 1, "_process should call _update on the current state")

## Test transition does nothing when target state does not exist
func test_on_child_transition_does_nothing_when_target_state_does_not_exist():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)
	var idle = TestState.new()
	idle.name = "Idle"

	sm.add_child(idle)
	sm.initial_state = idle
	sm._ready()

	sm.on_child_transition(idle, "MissingState")

	assert_eq(sm.current_state, idle, "current_state should remain unchanged when target state does not exist")
	assert_eq(idle.exit_called, 0, "current state should not exit when target state is invalid")

## Test if _process does nothing when there is no current state
func test_process_does_nothing_when_current_state_is_null():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)
	sm.current_state = null
	sm._process(0.16)

	assert_null(sm.current_state, "current_state should remain null")
	assert_true(true, "_process should safely do nothing when there is no current state")

## Test lowercase key usage
func test_ready_stores_state_names_as_lowercase_keys():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)
	var idle = TestState.new()
	idle.name = "IDLE"

	sm.add_child(idle)
	sm._ready()

	assert_true(sm.states.has("idle"), "states dictionary should use lowercase keys")
	assert_eq(sm.states["idle"], idle, "lowercase key should map to the correct state")

## Test duplicate state names overiting the previous state
func test_ready_duplicate_state_names_overwrite_previous_state():
	var sm = preload("res://game/actors/states/state_machine.gd").new()
	add_child_autofree(sm)
	var first_idle = TestState.new()
	first_idle.name = "Idle"

	var second_idle = TestState.new()
	second_idle.name = "Idle"

	sm.add_child(first_idle)
	sm.add_child(second_idle)
	sm._ready()

	assert_eq(sm.states["idle"], second_idle, "later duplicate state should overwrite earlier one in dictionary")
