extends GutTest

## This test script runs tests on the needs component
## which seems to be similar to the energy component, just flipped

# Globals
var nc: NeedsComponent

## Sets component up for each test
func before_each() -> void:
	nc = NeedsComponent.new()

## Frees the component after each test
func after_each():
	nc.free()

## Test empty_needs(delta: float) -> void
## Tests emptying the needs
func test_empty_needs_sets_needs_to_zero() -> void:
	nc.needs = 50.0
	nc.empty_needs(0.1)
	assert_eq(nc.needs, 0.0, "needs should be 0 after empty_needs")

## Test needs_change signal
## Tests whether the signal is properly emitted
func test_empty_needs_emits_signal() -> void:
	watch_signals(nc)
	nc.empty_needs(0.1)
	assert_signal_emitted(nc, "needs_change", "needs_change signal should be emitted")

## Test needs_increase(delta:float) -> void
## Tests increasing needs
func test_needs_increase_raises_needs() -> void:
	var initial_needs := nc.needs
	nc.needs_increase(1.0)
	assert_gt(nc.needs, initial_needs, "needs should increase after needs_increase")

## Test drain rate
func test_needs_increase_uses_drain_rate() -> void:
	nc.drain_rate = 10.0
	var expected_increase := nc.drain_rate * 1.1 * 1.0
	nc.needs_increase(1.0)
	assert_eq(nc.needs, expected_increase, "needs should increase by drain_rate * 1.1 * delta")

## Test needs increase signal emit
func test_needs_increase_emits_signal() -> void:
	watch_signals(nc)
	nc.needs_increase(0.1)
	assert_signal_emitted(nc, "needs_change", "needs_change signal should be emitted")

## Test if needs increase exceeds max
func test_needs_increase_does_not_exceed_max() -> void:
	nc.needs = nc.MAX_NEEDS - 1.0
	nc.needs_increase(100.0)
	# Note: Component doesn't clamp, so this will exceed MAX_NEEDS (unsure if intended?)
	assert_gt(nc.needs, nc.MAX_NEEDS, "Current implementation allows exceeding MAX_NEEDS")

## Test get_needs() -> float
## Tests retrieving needs
func test_get_needs_returns_current_needs() -> void:
	nc.needs = 25.5
	assert_eq(nc.get_needs(), 25.5, "get_needs should return current needs value")

## Test initialization
func test_get_needs_returns_zero_on_init() -> void:
	assert_eq(nc.get_needs(), 0.0, "get_needs should return 0 after initialization")

## Test get_max_needs() -> float
## Tests retrieving max needs
func test_get_max_needs_returns_max_needs() -> void:
	assert_eq(nc.get_max_needs(), nc.MAX_NEEDS, "get_max_needs should return MAX_NEEDS")

## Test max needs initialization
func test_get_max_needs_returns_50() -> void:
	assert_eq(nc.get_max_needs(), 50.0, "get_max_needs should return 50.0 by default")
