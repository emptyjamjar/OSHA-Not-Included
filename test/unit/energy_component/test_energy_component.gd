extends GutTest

## This is a test script for the energy_component.gd script. It will test the energy need functions
## for the player.

# Globals
var ec:EnergyComponent

## Runs before all tests
func before_all():
	ec = EnergyComponent.new()
	#ec.MAX_ENERGY = 50.0
	#ec.energy = ec.MAX_ENERGY
	#ec.regen_rate = 1.0
	#ec.drain_rate = 1.0
	#ec.hold_time = 0.0

## Runs after all tests
func after_all():
	ec.free()

## Test initial state
## Tests the expected initial state
func test_initial_state():
	assert_eq(ec.MAX_ENERGY, 50.0, "Incorrect value, expected 50.0 when initialized")
	# energy component's energy equals MAX_ENERGY when _ready is called, not during _init
	assert_eq(ec.energy, 0.0, "Incorrect value, expected energy to be not equal MAX_ENERGY until _ready")
	assert_eq(ec.regen_rate, 5.0, "Incorrect value, expected regen energy rate to be 5.0")
	assert_eq(ec.drain_rate, 0.05, "Incorrect value, expected drain energy rate to be 0.05")
	assert_eq(ec.hold_time, 0.0, "Incorrect value, expected hold time to be 0.0")

## Test regain_energy(delta: float) -> void
## Tests the energy regeneration
func test_regain_energy():
	# normal
	ec.energy = 0.0
	ec.regain_energy(10.0)
	assert_eq(ec.energy, 50.0, "Expected regained energy to be 50.0.")
	# negative value
	ec.energy = 0.0
	ec.regain_energy(-1)
	assert_eq(ec.energy, 0.0, "Expected regained energy to be 0.0")
	# zero
	ec.energy = 0.0
	ec.regain_energy(0)
	assert_eq(ec.energy, 0.0, "Expected regained energy to be 0,0")
	# very large value
	ec.energy = 0.0
	ec.regain_energy(999999999999999999)
	assert_eq(ec.energy, 50.0, "Expected regained energy to be 50.0")

## Test energy_deduction(delta:float) -> void
## Tests the energy draining capability
func test_energy_deduction():
	## drains increases the longer the player holds the box (pulled from method)
	var internal_formula = func(delta:float)->float:
		var multiplier:float = 1.0 + ec.hold_time 
		var amount:float = ec.drain_rate * multiplier * delta
		return clamp(ec.energy - amount, 0.0, ec.MAX_ENERGY)

	# normal expected with 0 hold time
	ec.energy = 50.0
	ec.hold_time = 0.0
	ec.energy_deduction(1.0)
	assert_eq(ec.energy, internal_formula.call(1.0), "Unexpected value, expected a value of 49.95.")
	# normal expected with 1.0 hold time
	ec.energy = 50.0
	ec.hold_time = 1.0
	ec.energy_deduction(1.0)
	assert_eq(ec.energy, internal_formula.call(1.0), "Expected value, expected a value of 48.0")
	# normal expected with 99.0 hold time
	ec.energy = 50.0
	ec.hold_time = 99.0
	ec.energy_deduction(1.0)
	assert_eq(ec.energy, internal_formula.call(1.0), "Unexpected value, expected value to drain no lower than at 0.0")
	# normal expected with -1.0 hold time
	ec.energy = 50.0
	ec.hold_time = -1
	ec.energy_deduction(1.0)
	assert_eq(ec.energy, internal_formula.call(1.0), "Unexpected value, expected value to not drain and remain at 50.0")
	
	# zero
	ec.energy = 50.0
	ec.hold_time = 1.0
	ec.energy_deduction(0)
	assert_eq(ec.energy, internal_formula.call(0), "Unexpected value, expected value to not drain and remain at 50.0")
	# negative
	ec.energy = 40.0
	ec.hold_time = 1.0
	ec.energy_deduction(-1)
	assert_eq(ec.energy, internal_formula.call(-1), "Unexpected value, expected value when given a negative value to act as regen and return 42.0")
	# very large number
	ec.energy = 50
	ec.hold_time = 1.0
	ec.energy_deduction(9999999999999)
	assert_eq(ec.energy, internal_formula.call(9999999999999), "Unexpected value, expected value to be 0.0.")
	
