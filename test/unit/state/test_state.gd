extends GutTest

## This is a test script for the state.gd script

## NOTE: Since the script is more like an interface, this test script
## will test the initialization of it only.

## Test init
func test_initialization():
	var new_state:State = State.new()
	assert_not_null(new_state, "Expected State Object")
	new_state.free()
