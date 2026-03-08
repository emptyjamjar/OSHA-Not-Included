extends GutTest

## This is a test script for the health_component.gd script, which represents the health/hp
## of the player.

# globals
var hc:HealthComponent

## runs before all tests
func before_each():
	hc = HealthComponent.new()

## runs after all tests
func after_each():
	hc.free()

func test_initial_state():
	hc.health = 100.0
	assert_eq(hc.MAX_HEALTH, 100.0, "Unexpected value at inital state, expected 100.0.")
	assert_eq(hc.health, 100.0, "Unexpected value at inital state, expected 100.0")

## test is_dead() -> bool
func test_is_dead():
	# yes, hp=0.0
	hc.health = 0.0
	assert_eq(hc.is_dead(), true, "Expected true, player should be dead.")
	# yes, hp=-99.0
	hc.health = -99.0
	assert_eq(hc.is_dead(), true, "Expected true, player should be dead.")
	# no, hp=100.0
	hc.health = 100.0
	assert_eq(hc.is_dead(), false, "Expected false, player should be alive.")
	

## Test set_health(value: float) -> void
func test_set_health():
	hc.health = 0.0
	# hp=100.0
	hc.set_health(100.0)
	assert_eq(hc.health, 100.0, "Unexpected value, expected 100.0")
	# hp=0.0
	hc.set_health(0.0)
	assert_eq(hc.health, 0.0, "Unexpected value, expected 0.0")
	# hp=-1.0
	hc.set_health(-1.0)
	assert_eq(hc.health, 0.0, "Unexpected value, expected 0.0")
	# hp=99999999999
	hc.set_health(99999999999.0)
	assert_eq(hc.health, 100.0, "Unexpected value, expected 100.0")

## Test get_health() -> float
func test_get_health():
	# check for null/inital value
	assert_not_null(hc.health, "Initial value unexpectedly has health before being initalized.")
	
	# get health after change
	hc.health = 99.0
	assert_eq(hc.health, 99.0, "Unexpected value, health should be 99.0")

## Test set_max_health(value: float) -> void
func test_set_max_health():
	# set to 100
	hc.set_max_health(100.0)
	assert_eq(hc.MAX_HEALTH, 100.0, "Unexpected value, max health should be 100.0")
	# set to 0
	hc.set_max_health(0.0)
	assert_eq(hc.MAX_HEALTH, 1.0, "Unexpected value, max health should be 1.0")
	# set to negative number
	hc.set_max_health(-99.0)
	assert_eq(hc.MAX_HEALTH, 1.0, "Unexpected value, max health should be 1.0")
	# set to really large number 999999999999
	hc.set_max_health(999999999999.0)
	assert_eq(hc.MAX_HEALTH, 999999999999.0, "Unexpected value, max health should be 999999999999.0")
	
## Test get_max_health() -> float
func test_get_max_health():
	# get initial max health
	assert_eq(hc.get_max_health(), 100.0, "Unexpected value, expected max health to be 100.0")
	# get changed max health
	hc.MAX_HEALTH = 150.0
	assert_eq(hc.get_max_health(), 150.0, "Unexpected value, expected max health to be 150.0")
	
## Test damage(amount: float) -> void
## tests damage from monsters/entity behavior
func test_damage():
	# 0 damage
	hc.set_health(100.0)
	hc.damage(0.0)
	assert_eq(hc.health, 100.0, "Unexpected value, expected no damage to occur.")
	
	# negative damage
	hc.set_health(100.0)
	hc.damage(-5)
	assert_eq(hc.health, 100.0, "Unexpected value, expected no damage to occur.")
	
	# positive damage
	hc.set_health(100.0)
	hc.damage(10.0)
	assert_eq(hc.health, 90.0, "Unexpected value, expected health to be 90.0")
	
	# damage higher than HP
	hc.set_health(100.0)
	hc.damage(110.0)
	assert_eq(hc.health, 0.0, "Unexpected value, expected health to be 0.0")
	
	# damage when player health already 0
	hc.set_health(0.0)
	hc.damage(100.0)
	assert_eq(hc.health, 0.0, "Unexpected value, expected health to remain at 0.0")
	
## Test heal(amount: float) -> void
## tests healing the characters health
func test_heal():
	# heal=10, hp=0, max=100
	hc.health=0.0
	hc.MAX_HEALTH=100.0
	hc.heal(10.0)
	assert_eq(hc.health, 10.0, "Unexpected value, after heal hp should be 10.0")
	# heal=10, hp=100, max100
	hc.health=100.0
	hc.MAX_HEALTH=100.0
	hc.heal(10.0)
	assert_eq(hc.health, 100.0, "Unexpected value, after heal hp should stay 100.0")
	# heal=10 hp=1, max=1
	hc.health=1.0
	hc.MAX_HEALTH=1.0
	hc.heal(10.0)
	assert_eq(hc.health, 1.0, "Unexpected value, after heal hp should be 1.0")
	# heal=100 hp=50, max=100
	hc.health=50.0
	hc.MAX_HEALTH=100.0
	hc.heal(100.0)
	assert_eq(hc.health, 100.0, "Unexpected value, after heal hp should be 100.0")
	# heal=-100, hp=50, max=100, shouldnt heal?
	hc.health=50.0
	hc.MAX_HEALTH=100.0
	hc.heal(-100.0)
	assert_eq(hc.health, 50.0, "Unexpected value, after heal hp should be 50.0")
