extends GutTest

## This test script runs tests on the sanity component
## which manages the player's sanity level and milestones

# Globals
var sc: SanityComponent

## Run before each test
func before_each():
	sc = SanityComponent.new()

## Run after each test
func after_each():
	sc.free()

## Test increase(amount: int) -> void
func test_increase_raises_sanity() -> void:
	sc.value = 50
	sc.increase(10)
	assert_eq(sc.value, 60, "sanity should increase by 10")

## Test if increasing emits signal
func test_increase_emits_signal() -> void:
	watch_signals(sc)
	sc.increase(5)
	assert_signal_emitted(sc, "sanity_changed", "sanity_changed signal should be emitted")

## Test decrease(amount: int) -> void
func test_decrease_lowers_sanity() -> void:
	sc.value = 50
	sc.decrease(10)
	assert_eq(sc.value, 40, "sanity should decrease by 10")

## Test if decreasing will emit signal
func test_decrease_emits_signal() -> void:
	watch_signals(sc)
	sc.decrease(5)
	assert_signal_emitted(sc, "sanity_changed", "sanity_changed signal should be emitted")

## Test set_milestone(threshold: int, effect_name: String) -> void
func test_set_milestone_adds_to_dictionary() -> void:
	sc.set_milestone(50, "horror_effect")
	assert_true(sc.milestones.has(50), "milestone should be added to dictionary")
	assert_eq(sc.milestones.get(50), "horror_effect", "milestone should store correct effect name")

## Test if milestone emits the proper signal
func test_set_milestone_emits_signal() -> void:
	watch_signals(sc)
	sc.set_milestone(50, "horror_effect")
	assert_signal_emitted(sc, "milestone_reached", "milestone_reached signal should be emitted")

## Test remove_milestone(threshold: int) -> bool
func test_remove_milestone_returns_true_on_success() -> void:
	sc.set_milestone(50, "horror_effect")
	var result := sc.remove_milestone(50)
	assert_true(result, "remove_milestone should return true when successful")

## Test if removing a non-existent milestone can happen
func test_remove_milestone_returns_false_on_failure() -> void:
	var result := sc.remove_milestone(999)
	assert_false(result, "remove_milestone should return false when milestone doesn't exist")

## Test check_milestones() -> Dictionary
func test_check_milestones_returns_all_milestones() -> void:
	sc.set_milestone(50, "effect_1")
	sc.set_milestone(25, "effect_2")
	var result := sc.check_milestones()
	assert_eq(result.size(), 2, "check_milestones should return all milestones")

## Test checking if milestones even contains the correct data
func test_check_milestones_returns_correct_data() -> void:
	sc.set_milestone(50, "horror_effect")
	var result := sc.check_milestones()
	assert_eq(result.get(50), "horror_effect", "should return correct effect for threshold")

## Test trigger_effect(node : Node) -> bool
func test_trigger_effect_returns_true() -> void:
	var dummy_node := Node.new()
	var result := sc.trigger_effect(dummy_node)
	assert_true(result, "trigger_effect should return true")
	dummy_node.free() # free component from memroy
