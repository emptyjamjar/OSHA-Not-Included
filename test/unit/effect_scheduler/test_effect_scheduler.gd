extends GutTest

## Unit tests for the EffectScheduler component. These tests cover the basic functionality of the EffectScheduler.

# Global scheduler #
var scheduler:EffectScheduler

# global mock effect data #
var mock_effect_data:MockEffectData

# Variables that mock effects will manipulate to track their behavior during testing #
class MockEffectData:
	var has_entered:bool = false
	var has_updated:bool = false
	var has_physics_updated:bool = false
	var has_exited:bool = false

	var value_on_enter:int = 0
	var value_on_update:int = 0
	var value_on_physics_update:int = 0
	var value_on_exit:int = 0

	var generic_value:int = 0

	func reset() -> void:
		has_entered = false
		has_updated = false
		has_physics_updated = false
		has_exited = false

		value_on_enter = 0
		value_on_update = 0
		value_on_physics_update = 0
		value_on_exit = 0

		generic_value = 0

var global_mock_data:MockEffectData

# mock effect classes for testing #

## Mock effect 1
## Does something on enter(), update(), and exit()
## Type is buff
## duration of 2 seconds
## repeats for a total of 2 cycles
## cooldown of 1 second
## Behavior:
## - increments value_on_enter by 1 on enter()
## - increments value_on_update by 1 on update()
## - increments value_on_physics_update by 1 on physics_update()
## - increments value_on_exit by 1 on exit()
class MockEffect1 extends Effect:
	var data: MockEffectData
	func _init():
		self._effect_name = "MockEffect1"
		self._type = Type.BUFF
		self._duration = 2.0
		self._enable_timing = true
		self._repeat_max = 2
		self._enable_repeat = true
		self._cooldown_duration = 1.0
		self._enable_cooldown = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data

	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect1"
		self._type = Type.BUFF
		self._duration = 2.0
		self._enable_timing = true
		self._repeat_max = 2
		self._enable_repeat = true
		self._cooldown_duration = 1.0
		self._enable_cooldown = true
	
	# overrides parent
	func enter(_delta: float = 0.0) -> void:
		super.enter(_delta) # called parent for signal
		data.has_entered = true
		data.value_on_enter += 1
	
	func update(delta: float = 0.0) -> void:
		data.has_updated = true
		data.value_on_update += 1
	
	func physics_update(delta: float = 0.0) -> void:
		data.has_physics_updated = true
		data.value_on_physics_update += 1
	
	func exit(_delta: float = 0.0) -> void:
		super.exit(_delta) # called parent for signal
		data.has_exited = true
		data.value_on_exit += 1

## Mock effect 2
## Does something on enter(), update(), exit(), and physics_update()
## Type is hazard
## duration of 1 second
## repeats for a total of 3 cycles
## cooldown of 2 seconds
## Behavior:
## - increments generic_value by 1 on enter()
## - increments generic_value by 2 on update()
## - increments generic_value by 3 on physics_update()
## - increments generic_value by 4 on exit()
class MockEffect2 extends Effect:
	var data: MockEffectData
	func _init():
		self._effect_name = "MockEffect2"
		self._type = Type.HAZARD
		self._duration = 1.0
		self._enable_timing = true
		self._repeat_max = 3
		self._enable_repeat = true
		self._cooldown_duration = 2.0
		self._enable_cooldown = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect2"
		self._type = Type.HAZARD
		self._duration = 1.0
		self._enable_timing = true
		self._repeat_max = 3
		self._enable_repeat = true
		self._cooldown_duration = 2.0
		self._enable_cooldown = true
	
	# overrides parent
	func enter(_delta: float = 0.0) -> void:
		super.enter(_delta) # called parent for signal
		data.generic_value += 1
	
	func update(delta: float = 0.0) -> void:
		data.generic_value += 2
	
	func physics_update(delta: float = 0.0) -> void:
		data.generic_value += 3
	
	func exit(_delta: float = 0.0) -> void:
		super.exit(_delta) # called parent for signal
		data.generic_value += 4

## Mock effect 3
## Does something on update() only
## Type is buff
## is persistent
## Behavior:
## - increments generic_value by 1 on update()
## - decrements value_on_update by 1 on update()
class MockEffect3 extends Effect:
	var data: MockEffectData
	func _init():
		self._effect_name = "MockEffect3"
		self._type = Type.BUFF
		self._is_persistent = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect3"
		self._type = Type.BUFF
		self._is_persistent = true
	
	func update(delta: float = 0.0) -> void:
		data.generic_value += 1
		data.value_on_update -= 1

## Mock effect 4
## Does something on enter() and update()
## Type is environmental
## is persistent and unique.
## Behavior:
## - increments generic_value by 1 on enter()
## - increments value_on_update by 1 on update()
class MockEffect4 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect4"
		self._type = Type.ENVIRONMENTAL
		self._is_persistent = true
		self._is_unique = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect4"
		self._type = Type.ENVIRONMENTAL
		self._is_persistent = true
		self._is_unique = true
	
	func enter(_delta: float = 0.0) -> void:
		super.enter(_delta) # called parent for signal
		data.generic_value += 1
	
	func update(delta: float = 0.0) -> void:
		data.value_on_update += 1

## Mock effect 5
## Does something on enter() and exit()
## Type is object
## behavior:
## - increments generic_value by 1 on enter()
## - increments generic_value by 2 on exit()
class MockEffect5 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect5"
		self._type = Type.OBJECT

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect5"
		self._type = Type.OBJECT

	func enter(_delta: float = 0.0) -> void:
		super.enter(_delta) # called parent for signal
		data.generic_value += 1

	func exit(_delta: float = 0.0) -> void:
		super.exit(_delta) # called parent for signal
		data.generic_value += 2


## Mock effect 6
## Does something in update() and physics_update()
## Type is visual
## cooldown of 2 seconds
## Behavior:
## - increments generic_value by 1 on update()
## - increments generic_value by 2 on physics_update()
class MockEffect6 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect6"
		self._type = Type.VISUAL
		self._cooldown_duration = 2.0
		self._enable_cooldown = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect6"
		self._type = Type.VISUAL
		self._cooldown_duration = 2.0
		self._enable_cooldown = true

	func update(delta: float = 0.0) -> void:
		data.generic_value += 1

	func physics_update(delta: float = 0.0) -> void:
		data.generic_value += 2

## Mock effect 7
## Does something on enter() only
## Type is environmental
## Behavior:
## - increments generic_value by 5 on enter()
## - decrements value_on_enter by 1 on enter()
class MockEffect7 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect7"
		self._type = Type.ENVIRONMENTAL

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect7"
		self._type = Type.ENVIRONMENTAL
	
	func enter(_delta: float = 0.0) -> void:
		super.enter(_delta) # called parent for signal
		data.generic_value += 5
		data.value_on_enter -= 1

## Mock effect 8
## Does something on exit() only
## Type is hazard
## Behavior:
## - increments generic_value by 15 on exit()
class MockEffect8 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect8"
		self._type = Type.HAZARD

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect8"
		self._type = Type.HAZARD

	func exit(_delta: float = 0.0) -> void:
		super.exit(_delta) # called parent for signal
		data.generic_value += 15

## Mock effect 9
## Does something in enter(), exit(), update(), and physics_update()
## Type is buff
## repeats 5 times
## Behavior:
## - increments generic_value by 2 on enter()
## - increments generic_value by 3 on update()
## - increments generic_value by 4 on physics_update()
## - increments generic_value by 5 on exit()
class MockEffect9 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect9"
		self._type = Type.BUFF
		self._repeat_max = 5
		self._enable_repeat = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect9"
		self._type = Type.BUFF
		self._repeat_max = 5
		self._enable_repeat = true

	func enter(_delta: float = 0.0) -> void:
		super.enter(_delta) # called parent for signal
		data.generic_value += 2
	
	func update(delta: float = 0.0) -> void:
		data.generic_value += 3
	
	func physics_update(delta: float = 0.0) -> void:
		data.generic_value += 4
	
	func exit(_delta: float = 0.0) -> void:
		super.exit(_delta) # called parent for signal
		data.generic_value += 5

## Mock effect 10
## Does nothing on enter(), update()
## Type is object
## Behavior:
## - increments generic_value by 10 on on enter()
## - increments value_on_update by 10 on update()
class MockEffect10 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect10"
		self._type = Type.OBJECT
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect10"
		self._type = Type.OBJECT
	
	func enter(_delta: float = 0.0) -> void:
		super.enter(_delta) # called parent for signal
		data.generic_value += 10
	
	func update(delta: float = 0.0) -> void:
		data.value_on_update += 10

## Mock effect 11
## Does nothing on physics_update()
## Type is visual
## Behavior:
## - increments value_on_physics_update by 20 on physics_update()
class MockEffect11 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect11"
		self._type = Type.VISUAL
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect11"
		self._type = Type.VISUAL
	
	func physics_update(delta: float = 0.0) -> void:
		data.value_on_physics_update += 20

## Mock effect 12
## Does something on enter() and update()
## Type is visual
## is unique
## Behavior:
## - increments generic_value by 12 on enter()
## - increments value_on_update by 12 on update()
class MockEffect12 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect12"
		self._type = Type.VISUAL
		self._is_unique = true

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data

	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect12"
		self._type = Type.VISUAL
		self._is_unique = true

	func enter(_delta: float = 0.0) -> void:
		super.enter(_delta) # called parent for signal
		data.generic_value += 12

	func update(delta: float = 0.0) -> void:
		data.value_on_update += 12

## Mock effect 13
## Timing only
## Type is structural
## Behavior:
## - increments value_on_update by 13 on update()
class MockEffect13 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect13"
		self._type = Type.STRUCTURAL
		self._duration = 1.5
		self._enable_timing = true
		self._enable_cooldown = false

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data

	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect13"
		self._type = Type.STRUCTURAL
		self._duration = 1.5
		self._enable_timing = true
		self._enable_cooldown = false

	func update(delta: float = 0.0) -> void:
		data.value_on_update += 13

## Mock effect 14
## Timing and cooldown
## Type is object
## Behavior:
## - increments generic_value by 14 on update()
class MockEffect14 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect14"
		self._type = Type.OBJECT
		self._duration = 2.0
		self._enable_timing = true
		self._cooldown_duration = 1.0
		self._enable_cooldown = true

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data

	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect14"
		self._type = Type.OBJECT
		self._duration = 2.0
		self._enable_timing = true
		self._cooldown_duration = 1.0
		self._enable_cooldown = true

	func update(delta: float = 0.0) -> void:
		data.generic_value += 14
		

## Mock effect 15
## Increments a counter every 0.5 seconds
## Type is structural
## duration of 0.5 seconds
## repeats for a total of 6 cycles
## Behavior:
## - increments value_on_update by 1 on update()
class MockEffect15 extends Effect:
	var data: MockEffectData

	func _init():
		self._effect_name = "MockEffect15"
		self._type = Type.STRUCTURAL
		self._duration = 0.5
		self._enable_timing = true
		self._repeat_max = 6
		self._enable_repeat = true

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data

	func reset() -> void:
		super.reset()
		self._effect_name = "MockEffect15"
		self._type = Type.STRUCTURAL
		self._duration = 0.5
		self._enable_timing = true
		self._repeat_max = 6
		self._enable_repeat = true

	func update(delta: float = 0.0) -> void:
		data.value_on_update += 1


## Before all tests, initialize scheduler
func before_all():
	scheduler = EffectScheduler.new()
	mock_effect_data = MockEffectData.new()

## Before each test, reset scheduler
func before_each():
	scheduler.clear()
	# set scheduler to default values
	scheduler.is_enabled = true
	# queue and safety limits
	scheduler.max_queue_size = 500
	scheduler.max_active_effects = 100
	# Timing controls
	scheduler.time_scale = 1.0
	scheduler.min_delta = 0.01
	# debug and logging
	scheduler.debug_logging = false
	scheduler.debug_log_active_effects = false
	scheduler.enable_scheduler()
	mock_effect_data.reset()

## After all tests, free scheduler
func after_all():
	scheduler.free()


# Method testing #
# for this testing section, I will test each method for what they expect and a bit of what they don't

# _process_waiting_effects() #

## Test when waiting queue is empty
func test_process_waiting_effects_when_waiting_queue_is_empty():
	scheduler._process_waiting_effects()
	assert_eq(scheduler.get_waiting_effects().size(), 0, "waiting should remain empty")
	assert_eq(scheduler.get_entering_effects().size(), 0, "entering should remain empty")


## test when there is an effect_id but available active slots is 0
func test_process_waiting_effects_when_available_slots_is_zero():
	scheduler.max_active_effects = 0
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	assert_true(scheduler.is_effect_waiting(effect_instance), "effect should stay waiting")
	assert_eq(scheduler.get_entering_effects().size(), 0, "entering should stay empty")
	scheduler.remove_all_effects()
	effect_instance.free()


## test when there is an effect_id that is null in the record
func test_process_waiting_effects_when_waiting_record_is_null():
	var effect_id := 77
	assert_true(scheduler._register_effect_id(effect_id), "id setup failed")
	scheduler._waiting_effects[effect_id] = null
	scheduler._process_waiting_effects()
	assert_false(scheduler._waiting_effects.has(effect_id), "null record should be removed")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled")

## test when there is an effect_id that is null in the effect instance
func test_process_waiting_effects_when_waiting_effect_instance_is_null():
	var effect_id := 78
	assert_true(scheduler._register_effect_id(effect_id), "id setup failed")
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = null
	record.is_waiting = true
	scheduler._waiting_effects[effect_id] = record
	scheduler._process_waiting_effects()
	assert_false(scheduler._waiting_effects.has(effect_id), "null effect should be removed")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled")

## test when there is an effect_id, but the effect is paused
func test_process_waiting_effects_when_effect_is_paused():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_true(scheduler.pause_effect(effect_id), "pause failed")
	scheduler._process_waiting_effects()
	assert_true(scheduler.is_effect_waiting(effect_instance), "paused effect should stay waiting")
	assert_eq(scheduler.get_entering_effects().size(), 0, "paused effect should not enter")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there is an effect_id and verify it moves from waiting queue to entering queue
func test_process_waiting_effects_moves_effect_to_entering_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	assert_false(scheduler.is_effect_waiting(effect_instance), "effect should leave waiting")
	assert_true(scheduler.get_entering_effects().has(effect_instance), "effect should be entering")
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	assert_not_null(record, "record should exist")
	if record != null:
		assert_true(record.is_entering, "record should be entering")
		assert_false(record.is_waiting, "record should not be waiting")
	scheduler.remove_all_effects()
	effect_instance.free()

# _process_entering_effects() #

## test when entering queue is empty
func test_process_entering_effects_when_entering_queue_is_empty():
	scheduler._process_entering_effects()
	assert_eq(scheduler.get_entering_effects().size(), 0, "entering should remain empty")
	assert_eq(scheduler.get_active_effects().size(), 0, "active should remain empty")
	assert_eq(scheduler.get_exiting_effects().size(), 0, "exiting should remain empty")

## test when record is null in entering queue
func test_process_entering_effects_when_entering_record_is_null():
	var effect_id := 79
	assert_true(scheduler._register_effect_id(effect_id), "id setup failed")
	scheduler._entering_effects[effect_id] = null
	scheduler._process_entering_effects()
	assert_false(scheduler._entering_effects.has(effect_id), "null record should be removed")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled")

## test when effect instance is null in entering queue
func test_process_entering_effects_when_entering_effect_instance_is_null():
	var effect_id := 80
	assert_true(scheduler._register_effect_id(effect_id), "id setup failed")
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = null
	record.is_entering = true
	scheduler._entering_effects[effect_id] = record
	scheduler._process_entering_effects()
	assert_false(scheduler._entering_effects.has(effect_id), "null effect should be removed")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled")

## test when effect instance is paused in entering queue
func test_process_entering_effects_when_effect_is_paused():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_true(scheduler.pause_effect(effect_id), "pause failed")
	scheduler._process_entering_effects()
	assert_true(scheduler.get_entering_effects().has(effect_instance), "paused effect should stay entering")
	assert_false(scheduler.is_effect_active(effect_instance), "paused effect should not become active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect only has a enter() and exit()
func test_process_entering_effects_when_effect_has_only_enter_and_exit():
	var effect_instance = MockEffect5.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_eq(mock_effect_data.generic_value, 1, "enter should run exactly once")
	assert_true(scheduler.get_active_effects().has(effect_instance), "effect should move to active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect has enter(), exit(), and update() but not physics_update()
func test_process_entering_effects_when_effect_has_enter_exit_and_update_only():
	var effect_instance = MockEffect10.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_eq(mock_effect_data.generic_value, 10, "enter should run exactly once")
	assert_eq(mock_effect_data.value_on_update, 0, "update should not run during entering")
	assert_eq(mock_effect_data.value_on_physics_update, 0, "physics_update should not run during entering")
	assert_true(scheduler.get_active_effects().has(effect_instance), "effect should move to active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect has enter(), exit(), and physics_update() but not update()
func test_process_entering_effects_when_effect_has_enter_exit_and_physics_update_only():
	var effect_instance = MockEffect11.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_eq(mock_effect_data.value_on_physics_update, 0, "physics_update should not run during entering")
	assert_eq(mock_effect_data.value_on_update, 0, "update should not run during entering")
	assert_true(scheduler.get_active_effects().has(effect_instance), "effect should move to active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect has enter(), exit(), update(), and physics_update()
func test_process_entering_effects_when_effect_has_enter_exit_update_and_physics_update():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_true(mock_effect_data.has_entered, "enter should run during entering")
	assert_eq(mock_effect_data.value_on_enter, 1, "enter should run exactly once")
	assert_false(mock_effect_data.has_updated, "update should not run during entering")
	assert_false(mock_effect_data.has_physics_updated, "physics_update should not run during entering")
	assert_true(scheduler.get_active_effects().has(effect_instance), "effect should move to active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect has only update()
func test_process_entering_effects_when_effect_has_only_update():
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_eq(mock_effect_data.generic_value, 0, "update should not run during entering")
	assert_eq(mock_effect_data.value_on_update, 0, "update side effect should not run during entering")
	assert_true(scheduler.get_active_effects().has(effect_instance), "effect should move to active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect has only physics_update()
func test_process_entering_effects_when_effect_has_only_physics_update():
	var effect_instance = MockEffect11.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_eq(mock_effect_data.value_on_physics_update, 0, "physics_update should not run during entering")
	assert_true(scheduler.get_active_effects().has(effect_instance), "effect should move to active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect only has update() and physics_update()
func test_process_entering_effects_when_effect_has_only_update_and_physics_update():
	var effect_instance = MockEffect6.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_eq(mock_effect_data.generic_value, 0, "update and physics_update should not run during entering")
	assert_true(scheduler.get_active_effects().has(effect_instance), "effect should move to active")
	scheduler.remove_all_effects()
	effect_instance.free()

# _process_active_effects() #

## test when active queue is empty
func test_process_active_effects_when_active_queue_is_empty():
	scheduler._process_active_effects(0.1, false)
	assert_eq(scheduler.get_active_effects().size(), 0, "active should remain empty")
	assert_eq(scheduler.get_exiting_effects().size(), 0, "exiting should remain empty")

## test when there is a null record in active queue
func test_process_active_effects_when_active_record_is_null():
	var effect_id := 81
	assert_true(scheduler._register_effect_id(effect_id), "id setup failed")
	scheduler._active_effects[effect_id] = null
	scheduler._process_active_effects(0.1, false)
	assert_false(scheduler._active_effects.has(effect_id), "null record should be removed")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled")

## test when there is a null effect instance in active queue
func test_process_active_effects_when_active_effect_instance_is_null():
	var effect_id := 82
	assert_true(scheduler._register_effect_id(effect_id), "id setup failed")
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = null
	record.is_active = true
	scheduler._active_effects[effect_id] = record
	scheduler._process_active_effects(0.1, false)
	assert_false(scheduler._active_effects.has(effect_id), "null effect should be removed")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled")

## test when there is a paused effect in active queue
func test_process_active_effects_when_effect_is_paused():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_true(scheduler.pause_effect(effect_id), "pause failed")
	mock_effect_data.reset()
	scheduler._process_active_effects(0.1, false)
	assert_false(scheduler.is_effect_active(effect_instance), "paused effect should not be considered active")
	assert_eq(mock_effect_data.value_on_update, 0, "paused effect should not update")
	scheduler.remove_all_effects()
	effect_instance.free()

## test if after being processed by entering queue, if its in active queue if it doesnt update
func test_process_active_effects_effect_in_active_queue_without_update_callback():
	var effect_instance = MockEffect5.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_true(scheduler.is_effect_active(effect_instance), "effect should be in active queue")
	mock_effect_data.reset()
	scheduler._process_active_effects(0.1, false)
	assert_true(scheduler.is_effect_active(effect_instance), "effect should still be active")
	assert_eq(mock_effect_data.generic_value, 0, "effect with no update should not change data")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that an effect with duration works correctly in active queue
func test_process_active_effects_when_effect_has_duration():
	var effect_instance = MockEffect13.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_elapsed_time(1.2)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	mock_effect_data.reset()
	scheduler._process_active_effects(0.2, false)
	assert_eq(mock_effect_data.value_on_update, 13, "update should run when not exceeding duration")
	assert_true(scheduler.is_effect_active(effect_instance), "effect should remain active since 1.2 + 0.2 < 1.5 duration")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that an effect with repeat works correctly in active queue
func test_process_active_effects_when_effect_has_repeat():
	var effect_instance = MockEffect9.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_repeat_count(0)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	mock_effect_data.reset()
	scheduler._process_active_effects(0.1, false)
	assert_true(scheduler.is_effect_active(effect_instance), "repeat effect should stay active")
	assert_true(scheduler.get_active_effects().has(effect_instance), "repeat effect should stay in active queue")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that an effect with cooldown works correctly in active queue
func test_process_active_effects_when_effect_has_cooldown():
	var effect_instance = MockEffect6.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_cooldown_elapsed(0.0)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	mock_effect_data.reset()
	scheduler._process_active_effects(0.1, false)
	assert_eq(mock_effect_data.generic_value, 0, "update should not run when on cooldown")
	assert_true(scheduler.is_effect_active(effect_instance), "cooldown effect should stay active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that an effect with duration and repeat works correctly
func test_process_active_effects_when_effect_has_duration_and_repeat():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(2.0)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(2)
	effect_instance.set_enable_cooldown(false)
	effect_instance.set_elapsed_time(1.0)
	effect_instance.set_repeat_count(0)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	mock_effect_data.reset()
	scheduler._process_active_effects(0.1, false)
	assert_eq(mock_effect_data.value_on_update, 1, "update should run")
	assert_true(scheduler.is_effect_active(effect_instance), "effect should still be active within duration")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that an effect with duration and cooldown works correctly
func test_process_active_effects_when_effect_has_duration_and_cooldown():
	var effect_instance = MockEffect14.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_elapsed_time(1.9)
	effect_instance.set_cooldown_elapsed(0.0)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	mock_effect_data.reset()
	scheduler._process_active_effects(0.2, false)
	assert_true(scheduler.get_exiting_effects().has(effect_instance), "effect should move to exiting when duration exceeded")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that an effect with repeat and cooldown works correctly
func test_process_active_effects_when_effect_has_repeat_and_cooldown():
	var effect_instance = MockEffect6.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(0)
	effect_instance.set_cooldown_elapsed(0.0)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	mock_effect_data.reset()
	scheduler._process_active_effects(0.1, false)
	assert_eq(mock_effect_data.generic_value, 0, "update should not run when on cooldown")
	assert_true(scheduler.is_effect_active(effect_instance), "repeat+cooldown effect should stay active")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that an effect with duration, repeat, and cooldown works correctly
func test_process_active_effects_when_effect_has_duration_repeat_and_cooldown():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_elapsed_time(1.0)
	effect_instance.set_repeat_count(0)
	effect_instance.set_cooldown_elapsed(effect_instance.get_cooldown_duration())
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	mock_effect_data.reset()
	scheduler._process_active_effects(0.1, false)
	assert_eq(mock_effect_data.value_on_update, 1, "update should run within duration")
	assert_true(scheduler.is_effect_active(effect_instance), "effect should stay active within duration")
	scheduler.remove_all_effects()
	effect_instance.free()

## test an effect with no duration, repeat, or cooldown
func test_process_active_effects_when_effect_has_no_timing_or_repeat():
	var effect_instance = MockEffect5.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	mock_effect_data.reset()
	scheduler._process_active_effects(0.1, false)
	assert_true(scheduler.is_effect_active(effect_instance), "effect without timing/repeat should stay active")
	scheduler.remove_all_effects()
	effect_instance.free()

# _process_exiting_effects() #

## test when exiting queue is empty
func test_process_exiting_effects_when_exiting_queue_is_empty():
	scheduler._process_exiting_effects()
	assert_eq(scheduler.get_exiting_effects().size(), 0, "exiting should remain empty")

## test when there is a null record in exiting queue
func test_process_exiting_effects_when_exiting_record_is_null():
	var effect_id := 83
	assert_true(scheduler._register_effect_id(effect_id), "id setup failed")
	scheduler._exiting_effects[effect_id] = null
	scheduler._process_exiting_effects()
	assert_false(scheduler._exiting_effects.has(effect_id), "null record should be removed")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled")

## test when there is a null effect instance in exiting queue
func test_process_exiting_effects_when_exiting_effect_instance_is_null():
	var effect_id := 84
	assert_true(scheduler._register_effect_id(effect_id), "id setup failed")
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = null
	record.is_exiting = true
	scheduler._exiting_effects[effect_id] = record
	scheduler._process_exiting_effects()
	assert_false(scheduler._exiting_effects.has(effect_id), "null effect should be removed")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled")

## test when there is a paused effect in exiting queue
func test_process_exiting_effects_when_effect_is_paused():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_true(scheduler._move_active_to_exiting(effect_id), "move to exiting failed")
	assert_true(scheduler.pause_effect(effect_id), "pause failed")
	mock_effect_data.reset()
	scheduler._process_exiting_effects()
	assert_true(scheduler.get_exiting_effects().has(effect_instance), "paused effect should stay in exiting queue")
	assert_eq(mock_effect_data.value_on_exit, 0, "paused effect should not run exit")
	assert_true(scheduler.has_effect_with_id(effect_id), "paused exiting effect should keep its id")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that an effect with only exit() is processed correctly in exiting queue
func test_process_exiting_effects_when_effect_has_only_exit():
	var effect_instance = MockEffect8.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_true(scheduler._move_active_to_exiting(effect_id), "move to exiting failed")
	mock_effect_data.reset()
	scheduler._process_exiting_effects()
	assert_eq(mock_effect_data.generic_value, 15, "exit should run exactly once")
	assert_false(scheduler.get_exiting_effects().has(effect_instance), "effect should be removed from exiting queue")
	assert_false(scheduler.has_effect_with_id(effect_id), "id should be recycled after exit")
	effect_instance.free()

# _add_to_waiting() #

## test if effect is added to waiting queue correctly
func test_add_to_waiting_adds_effect_record_successfully():
	var effect_id := 85
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_waiting = true

	assert_true(scheduler._add_to_waiting(effect_id, record), "expected add to waiting to succeed")
	assert_true(scheduler._waiting_effects.has(effect_id), "waiting queue should contain the effect id")
	assert_eq(scheduler._waiting_effects[effect_id], record, "waiting queue should store the same record")
	effect_instance.free()

## test when effect record is null
func test_add_to_waiting_with_null_record():
	var effect_id := 86
	assert_false(scheduler._add_to_waiting(effect_id, null), "adding null record should fail")
	assert_false(scheduler._waiting_effects.has(effect_id), "null record should not be added")

## test when effect instance is null
func test_add_to_waiting_with_null_effect_instance():
	var effect_id := 87
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = null
	record.is_waiting = true

	assert_false(scheduler._add_to_waiting(effect_id, record), "adding record with null effect should fail")
	assert_false(scheduler._waiting_effects.has(effect_id), "record with null effect should not be added")

## test adding when queue size limit has been reached
func test_add_to_waiting_when_queue_size_limit_reached():
	scheduler.max_queue_size = 1

	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	var record1 = EffectScheduler.ScheduleRecord.new()
	record1.id = 88
	record1.effect = effect1
	record1.is_waiting = true

	var effect2 = MockEffect2.new()
	effect2.add_test_environment_data(mock_effect_data)
	var record2 = EffectScheduler.ScheduleRecord.new()
	record2.id = 89
	record2.effect = effect2
	record2.is_waiting = true

	assert_true(scheduler._add_to_waiting(88, record1), "first add should succeed within queue limit")
	assert_false(scheduler._add_to_waiting(89, record2), "second add should fail when queue limit is reached")
	assert_true(scheduler._waiting_effects.has(88), "first record should remain in waiting queue")
	assert_false(scheduler._waiting_effects.has(89), "second record should not be added")

	effect1.free()
	effect2.free()

# _add_to_entering() #

## test if effect is added to entering queue correctly
func test_add_to_entering_adds_effect_record_successfully():
	var effect_id := 90
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_entering = true

	assert_true(scheduler._add_to_entering(effect_id, record), "expected add to entering to succeed")
	assert_true(scheduler._entering_effects.has(effect_id), "entering queue should contain the effect id")
	assert_eq(scheduler._entering_effects[effect_id], record, "entering queue should store the same record")
	effect_instance.free()

## test when effect record is null
func test_add_to_entering_with_null_record():
	var effect_id := 91
	assert_false(scheduler._add_to_entering(effect_id, null), "adding null record should fail")
	assert_false(scheduler._entering_effects.has(effect_id), "null record should not be added")

## test when effect instance is null
func test_add_to_entering_with_null_effect_instance():
	var effect_id := 92
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = null
	record.is_entering = true

	assert_false(scheduler._add_to_entering(effect_id, record), "adding record with null effect should fail")
	assert_false(scheduler._entering_effects.has(effect_id), "record with null effect should not be added")


# _add_to_active() #

## test if effect is added to active queue correctly
func test_add_to_active_adds_effect_record_successfully():
	var effect_id := 93
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_active = true

	assert_true(scheduler._add_to_active(effect_id, record), "expected add to active to succeed")
	assert_true(scheduler._active_effects.has(effect_id), "active queue should contain the effect id")
	assert_eq(scheduler._active_effects[effect_id], record, "active queue should store the same record")
	effect_instance.free()

## test when effect record is null
func test_add_to_active_with_null_record():
	var effect_id := 94
	assert_false(scheduler._add_to_active(effect_id, null), "adding null record should fail")
	assert_false(scheduler._active_effects.has(effect_id), "null record should not be added")

## test when effect instance is null
func test_add_to_active_with_null_effect_instance():
	var effect_id := 95
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = null
	record.is_active = true

	assert_false(scheduler._add_to_active(effect_id, record), "adding record with null effect should fail")
	assert_false(scheduler._active_effects.has(effect_id), "record with null effect should not be added")


# _add_to_exiting() #

## test if effect is added to exiting queue correctly
func test_add_to_exiting_adds_effect_record_successfully():
	var effect_id := 96
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_exiting = true

	assert_true(scheduler._add_to_exiting(effect_id, record), "expected add to exiting to succeed")
	assert_true(scheduler._exiting_effects.has(effect_id), "exiting queue should contain the effect id")
	assert_eq(scheduler._exiting_effects[effect_id], record, "exiting queue should store the same record")
	effect_instance.free()

## test when effect record is null
func test_add_to_exiting_with_null_record():
	var effect_id := 97
	assert_false(scheduler._add_to_exiting(effect_id, null), "adding null record should fail")
	assert_false(scheduler._exiting_effects.has(effect_id), "null record should not be added")

## test when effect instance is null
func test_add_to_exiting_with_null_effect_instance():
	var effect_id := 98
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = null
	record.is_exiting = true

	assert_false(scheduler._add_to_exiting(effect_id, record), "adding record with null effect should fail")
	assert_false(scheduler._exiting_effects.has(effect_id), "record with null effect should not be added")


# _remove_from_waiting() #

# test if given id is not in waiting queue
func test_remove_from_waiting_with_missing_id():
	var effect_id := 99
	assert_false(scheduler._remove_from_waiting(effect_id), "removing missing id should return false")
	assert_false(scheduler._waiting_effects.has(effect_id), "waiting queue should not contain missing id")

# test if given id is in waiting queue and is removed correctly
func test_remove_from_waiting_removes_existing_id():
	var effect_id := 100
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_waiting = true
	assert_true(scheduler._add_to_waiting(effect_id, record), "setup add to waiting failed")

	assert_true(scheduler._remove_from_waiting(effect_id), "removing existing id should return true")
	assert_false(scheduler._waiting_effects.has(effect_id), "waiting queue should no longer contain removed id")
	effect_instance.free()

# _remove_from_entering() #

# test if given id is not in entering queue
func test_remove_from_entering_with_missing_id():
	var effect_id := 101
	assert_false(scheduler._remove_from_entering(effect_id), "removing missing id should return false")
	assert_false(scheduler._entering_effects.has(effect_id), "entering queue should not contain missing id")

# test if given id is in entering queue and is removed correctly
func test_remove_from_entering_removes_existing_id():
	var effect_id := 102
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_entering = true
	assert_true(scheduler._add_to_entering(effect_id, record), "setup add to entering failed")

	assert_true(scheduler._remove_from_entering(effect_id), "removing existing id should return true")
	assert_false(scheduler._entering_effects.has(effect_id), "entering queue should no longer contain removed id")
	effect_instance.free()

# _remove_from_active() #

# test if given id is not in active queue
func test_remove_from_active_with_missing_id():
	var effect_id := 103
	assert_false(scheduler._remove_from_active(effect_id), "removing missing id should return false")
	assert_false(scheduler._active_effects.has(effect_id), "active queue should not contain missing id")

# test if given id is in active queue and is removed correctly
func test_remove_from_active_removes_existing_id():
	var effect_id := 104
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_active = true
	assert_true(scheduler._add_to_active(effect_id, record), "setup add to active failed")

	assert_true(scheduler._remove_from_active(effect_id), "removing existing id should return true")
	assert_false(scheduler._active_effects.has(effect_id), "active queue should no longer contain removed id")
	effect_instance.free()

# _remove_from_exiting() #

# test if given id is not in exiting queue
func test_remove_from_exiting_with_missing_id():
	var effect_id := 105
	assert_false(scheduler._remove_from_exiting(effect_id), "removing missing id should return false")
	assert_false(scheduler._exiting_effects.has(effect_id), "exiting queue should not contain missing id")

# test if given id is in exiting queue and is removed correctly
func test_remove_from_exiting_removes_existing_id():
	var effect_id := 106
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_exiting = true
	assert_true(scheduler._add_to_exiting(effect_id, record), "setup add to exiting failed")

	assert_true(scheduler._remove_from_exiting(effect_id), "removing existing id should return true")
	assert_false(scheduler._exiting_effects.has(effect_id), "exiting queue should no longer contain removed id")
	effect_instance.free()

# _move_waiting_to_entering() #

## test if given id is not in waiting queue
func test_move_waiting_to_entering_with_missing_id():
	var effect_id := 107
	assert_false(scheduler._move_waiting_to_entering(effect_id), "moving missing waiting id should return false")
	assert_false(scheduler._entering_effects.has(effect_id), "entering queue should not contain missing id")

## test if given id is in waiting queue and moved to entering queue correctly
func test_move_waiting_to_entering_moves_record_correctly():
	var effect_id := 108
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_waiting = true
	assert_true(scheduler._add_to_waiting(effect_id, record), "setup add to waiting failed")

	assert_true(scheduler._move_waiting_to_entering(effect_id), "waiting record should move to entering")
	assert_false(scheduler._waiting_effects.has(effect_id), "waiting queue should no longer contain moved id")
	assert_true(scheduler._entering_effects.has(effect_id), "entering queue should contain moved id")
	var moved_record: EffectScheduler.ScheduleRecord = scheduler._entering_effects[effect_id]
	assert_true(moved_record.is_entering, "moved record should be entering")
	assert_false(moved_record.is_waiting, "moved record should no longer be waiting")
	assert_true(moved_record.start_time > 0.0, "moved record should set start_time")
	effect_instance.free()

## test when add_to_entering rejects
func test_move_waiting_to_entering_when_add_to_entering_rejects():
	var effect_id := 109
	var waiting_effect = MockEffect1.new()
	waiting_effect.add_test_environment_data(mock_effect_data)
	var waiting_record = EffectScheduler.ScheduleRecord.new()
	waiting_record.id = effect_id
	waiting_record.effect = waiting_effect
	waiting_record.is_waiting = true
	assert_true(scheduler._add_to_waiting(effect_id, waiting_record), "setup add to waiting failed")

	var entering_effect = MockEffect2.new()
	entering_effect.add_test_environment_data(mock_effect_data)
	var entering_record = EffectScheduler.ScheduleRecord.new()
	entering_record.id = effect_id
	entering_record.effect = entering_effect
	entering_record.is_entering = true
	scheduler._entering_effects[effect_id] = entering_record

	assert_false(scheduler._move_waiting_to_entering(effect_id), "move should fail when entering already has id")
	assert_true(scheduler._waiting_effects.has(effect_id), "waiting queue should keep id when move fails")

	waiting_effect.free()
	entering_effect.free()

# _move_entering_to_active() #

## test if given id is not in entering queue
func test_move_entering_to_active_with_missing_id():
	var effect_id := 110
	assert_false(scheduler._move_entering_to_active(effect_id), "moving missing entering id should return false")
	assert_false(scheduler._active_effects.has(effect_id), "active queue should not contain missing id")

## test if given id is in entering queue and moved to active queue correctly
func test_move_entering_to_active_moves_record_correctly():
	var effect_id := 111
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_entering = true
	assert_true(scheduler._add_to_entering(effect_id, record), "setup add to entering failed")

	assert_true(scheduler._move_entering_to_active(effect_id), "entering record should move to active")
	assert_false(scheduler._entering_effects.has(effect_id), "entering queue should no longer contain moved id")
	assert_true(scheduler._active_effects.has(effect_id), "active queue should contain moved id")
	var moved_record: EffectScheduler.ScheduleRecord = scheduler._active_effects[effect_id]
	assert_true(moved_record.is_active, "moved record should be active")
	assert_false(moved_record.is_entering, "moved record should no longer be entering")
	assert_true(moved_record.last_update_time > 0.0, "moved record should set last_update_time")
	effect_instance.free()

## test when add_to_active rejects
func test_move_entering_to_active_when_add_to_active_rejects():
	var effect_id := 112
	var entering_effect = MockEffect1.new()
	entering_effect.add_test_environment_data(mock_effect_data)
	var entering_record = EffectScheduler.ScheduleRecord.new()
	entering_record.id = effect_id
	entering_record.effect = entering_effect
	entering_record.is_entering = true
	assert_true(scheduler._add_to_entering(effect_id, entering_record), "setup add to entering failed")

	var active_effect = MockEffect2.new()
	active_effect.add_test_environment_data(mock_effect_data)
	var active_record = EffectScheduler.ScheduleRecord.new()
	active_record.id = effect_id
	active_record.effect = active_effect
	active_record.is_active = true
	scheduler._active_effects[effect_id] = active_record

	assert_false(scheduler._move_entering_to_active(effect_id), "move should fail when active already has id")
	assert_true(scheduler._entering_effects.has(effect_id), "entering queue should keep id when move fails")

	entering_effect.free()
	active_effect.free()

# _move_entering_to_exiting() #

## test if given id is not in entering queue
func test_move_entering_to_exiting_with_missing_id():
	var effect_id := 113
	assert_false(scheduler._move_entering_to_exiting(effect_id), "moving missing entering id should return false")
	assert_false(scheduler._exiting_effects.has(effect_id), "exiting queue should not contain missing id")

## test if given id is in entering queue and moved to exiting queue correctly
func test_move_entering_to_exiting_moves_record_correctly():
	var effect_id := 114
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_entering = true
	assert_true(scheduler._add_to_entering(effect_id, record), "setup add to entering failed")

	assert_true(scheduler._move_entering_to_exiting(effect_id), "entering record should move to exiting")
	assert_false(scheduler._entering_effects.has(effect_id), "entering queue should no longer contain moved id")
	assert_true(scheduler._exiting_effects.has(effect_id), "exiting queue should contain moved id")
	var moved_record: EffectScheduler.ScheduleRecord = scheduler._exiting_effects[effect_id]
	assert_true(moved_record.is_exiting, "moved record should be exiting")
	assert_false(moved_record.is_entering, "moved record should no longer be entering")
	assert_true(moved_record.exit_time > 0.0, "moved record should set exit_time")
	effect_instance.free()

## test when add_to_exiting rejects
func test_move_entering_to_exiting_when_add_to_exiting_rejects():
	var effect_id := 115
	var entering_effect = MockEffect1.new()
	entering_effect.add_test_environment_data(mock_effect_data)
	var entering_record = EffectScheduler.ScheduleRecord.new()
	entering_record.id = effect_id
	entering_record.effect = entering_effect
	entering_record.is_entering = true
	assert_true(scheduler._add_to_entering(effect_id, entering_record), "setup add to entering failed")

	var exiting_effect = MockEffect2.new()
	exiting_effect.add_test_environment_data(mock_effect_data)
	var exiting_record = EffectScheduler.ScheduleRecord.new()
	exiting_record.id = effect_id
	exiting_record.effect = exiting_effect
	exiting_record.is_exiting = true
	scheduler._exiting_effects[effect_id] = exiting_record

	assert_false(scheduler._move_entering_to_exiting(effect_id), "move should fail when exiting already has id")
	assert_true(scheduler._entering_effects.has(effect_id), "entering queue should keep id when move fails")

	entering_effect.free()
	exiting_effect.free()

# _move_active_to_exiting() #

## test if given id is not in active queue
func test_move_active_to_exiting_with_missing_id():
	var effect_id := 116
	assert_false(scheduler._move_active_to_exiting(effect_id), "moving missing active id should return false")
	assert_false(scheduler._exiting_effects.has(effect_id), "exiting queue should not contain missing id")

## test if given id is in active queue and moved to exiting queue correctly
func test_move_active_to_exiting_moves_record_correctly():
	var effect_id := 117
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	var record = EffectScheduler.ScheduleRecord.new()
	record.id = effect_id
	record.effect = effect_instance
	record.is_active = true
	assert_true(scheduler._add_to_active(effect_id, record), "setup add to active failed")

	assert_true(scheduler._move_active_to_exiting(effect_id), "active record should move to exiting")
	assert_false(scheduler._active_effects.has(effect_id), "active queue should no longer contain moved id")
	assert_true(scheduler._exiting_effects.has(effect_id), "exiting queue should contain moved id")
	var moved_record: EffectScheduler.ScheduleRecord = scheduler._exiting_effects[effect_id]
	assert_true(moved_record.is_exiting, "moved record should be exiting")
	assert_false(moved_record.is_active, "moved record should no longer be active")
	assert_true(moved_record.exit_time > 0.0, "moved record should set exit_time")
	effect_instance.free()

## test when add_to_exiting rejects
func test_move_active_to_exiting_when_add_to_exiting_rejects():
	var effect_id := 118
	var active_effect = MockEffect1.new()
	active_effect.add_test_environment_data(mock_effect_data)
	var active_record = EffectScheduler.ScheduleRecord.new()
	active_record.id = effect_id
	active_record.effect = active_effect
	active_record.is_active = true
	assert_true(scheduler._add_to_active(effect_id, active_record), "setup add to active failed")

	var exiting_effect = MockEffect2.new()
	exiting_effect.add_test_environment_data(mock_effect_data)
	var exiting_record = EffectScheduler.ScheduleRecord.new()
	exiting_record.id = effect_id
	exiting_record.effect = exiting_effect
	exiting_record.is_exiting = true
	scheduler._exiting_effects[effect_id] = exiting_record

	assert_false(scheduler._move_active_to_exiting(effect_id), "move should fail when exiting already has id")
	assert_true(scheduler._active_effects.has(effect_id), "active queue should keep id when move fails")

	active_effect.free()
	exiting_effect.free()

# _should_effect_start() #

## test when effect is null
func test_should_effect_start_when_effect_is_null():
	assert_false(scheduler._should_effect_start(null), "null effect should not start")

## test when effect should start
func test_should_effect_start_when_effect_should_start():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler._should_effect_start(effect_instance), "valid effect should be allowed to start")
	effect_instance.free()

# _should_effect_stop() #

## test when effect is null
func test_should_effect_stop_when_effect_is_null():
	assert_true(scheduler._should_effect_stop(null), "null effect should be treated as stop")

## test when effect should stop
func test_should_effect_stop_when_effect_should_stop():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_marked_done(true)
	assert_true(scheduler._should_effect_stop(effect_instance), "manually done effect should be stopped")
	effect_instance.free()

# _should_effect_update() #

## test when effect is null
func test_should_effect_update_when_effect_is_null():
	assert_false(scheduler._should_effect_update(null), "null effect should not update")

## test when effect should update
func test_should_effect_update_when_effect_should_update():
	var effect_instance = MockEffect10.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_cooldown(false)
	assert_true(scheduler._should_effect_update(effect_instance), "active non-cooldown effect should update")
	effect_instance.free()

## test when effect has cooldown and is on cooldown
func test_should_effect_update_when_effect_on_cooldown():
	var effect_instance = MockEffect6.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_cooldown_elapsed(0.0)
	assert_true(effect_instance.is_on_cooldown(), "setup expected effect to be on cooldown")
	assert_false(scheduler._should_effect_update(effect_instance), "effect on cooldown should not update")
	effect_instance.free()

# _should_effect_physics_update() #

## test when effect is null
func test_should_effect_physics_update_when_effect_is_null():
	assert_false(scheduler._should_effect_physics_update(null), "null effect should not physics update")

## test when effect should physics_update
func test_should_effect_physics_update_when_effect_should_physics_update():
	var effect_instance = MockEffect11.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_cooldown(false)
	assert_true(scheduler._should_effect_physics_update(effect_instance), "active non-cooldown effect should physics update")
	effect_instance.free()

## test when effect has cooldown and is on cooldown
func test_should_effect_physics_update_when_effect_on_cooldown():
	var effect_instance = MockEffect6.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_cooldown_elapsed(0.0)
	assert_true(effect_instance.is_on_cooldown(), "setup expected effect to be on cooldown")
	assert_false(scheduler._should_effect_physics_update(effect_instance), "effect on cooldown should not physics update")
	effect_instance.free()

# _should_end_from_duration() #

## test when effect is null
func test_should_end_from_duration_when_effect_is_null():
	assert_true(scheduler._should_end_from_duration(null, 0.1), "null effect should be treated as ended")

## test when effect has no duration
func test_should_end_from_duration_when_effect_has_no_duration():
	var effect_instance = MockEffect5.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler._should_end_from_duration(effect_instance, 0.1), "non-timed effect should not end from duration")
	effect_instance.free()

## test when effect has duration and has not reached it
func test_should_end_from_duration_when_duration_not_reached():
	var effect_instance = MockEffect13.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_elapsed_time(1.0)
	assert_false(scheduler._should_end_from_duration(effect_instance, 0.2), "effect should not end before duration threshold")
	effect_instance.free()

## test when effect has duration and has reached it
func test_should_end_from_duration_when_duration_reached():
	var effect_instance = MockEffect13.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_elapsed_time(1.4)
	assert_true(scheduler._should_end_from_duration(effect_instance, 0.2), "effect should end once elapsed + delta reaches duration")
	effect_instance.free()

## test when effect is persistent
func test_should_end_from_duration_when_effect_is_persistent():
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(0.1)
	effect_instance.set_elapsed_time(10.0)
	assert_false(scheduler._should_end_from_duration(effect_instance, 1.0), "persistent effect should not end from duration")
	effect_instance.free()

# _should_repeat() #

## test when effect is null
func test_should_repeat_when_effect_is_null():
	assert_false(scheduler._should_repeat(null), "null effect should not repeat")

## test when effect has no repeat
func test_should_repeat_when_effect_has_no_repeat():
	var effect_instance = MockEffect5.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler._should_repeat(effect_instance), "non-repeating effect should not repeat")
	effect_instance.free()

## test when effect has repeat and has not reached max
func test_should_repeat_when_effect_has_repeat_and_not_reached_max():
	var effect_instance = MockEffect9.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_repeat_count(2)
	assert_true(scheduler._should_repeat(effect_instance), "repeating effect below max should repeat")
	effect_instance.free()

## test when effect has repeat and has reached max
func test_should_repeat_when_effect_has_repeat_and_reached_max():
	var effect_instance = MockEffect9.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_repeat_count(effect_instance.get_repeat_max())
	assert_false(scheduler._should_repeat(effect_instance), "repeating effect at max should not repeat")
	effect_instance.free()

## test when effect is persistent
func test_should_repeat_when_effect_is_persistent():
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(5)
	effect_instance.set_repeat_count(0)
	assert_false(scheduler._should_repeat(effect_instance), "persistent effect should not repeat through scheduler repeat logic")
	effect_instance.free()

# _run_enter() #

## test when effect is null
func test_run_enter_when_effect_is_null():
	mock_effect_data.reset()
	scheduler._run_enter(null)
	assert_false(mock_effect_data.has_entered, "null effect should not run enter")
	assert_eq(mock_effect_data.value_on_enter, 0, "null effect should not change enter data")

## test that effect.enter() is called
func test_run_enter_calls_effect_enter():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	mock_effect_data.reset()
	scheduler._run_enter(effect_instance)
	assert_true(mock_effect_data.has_entered, "enter should be called")
	assert_eq(mock_effect_data.value_on_enter, 1, "enter should run exactly once")
	effect_instance.free()

# _run_update() #

## test when effect is null
func test_run_update_when_effect_is_null():
	mock_effect_data.reset()
	scheduler._run_update(null, 0.1)
	assert_false(mock_effect_data.has_updated, "null effect should not run update")
	assert_eq(mock_effect_data.value_on_update, 0, "null effect should not change update data")

## test that effect.update() is called
func test_run_update_calls_effect_update():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	mock_effect_data.reset()
	scheduler._run_update(effect_instance, 0.1)
	assert_true(mock_effect_data.has_updated, "update should be called")
	assert_eq(mock_effect_data.value_on_update, 1, "update should run exactly once")
	effect_instance.free()

# _run_physics_update() #

## test when effect is null
func test_run_physics_update_when_effect_is_null():
	mock_effect_data.reset()
	scheduler._run_physics_update(null, 0.1)
	assert_false(mock_effect_data.has_physics_updated, "null effect should not run physics_update")
	assert_eq(mock_effect_data.value_on_physics_update, 0, "null effect should not change physics update data")

## test that effect.physics_update() is called
func test_run_physics_update_calls_effect_physics_update():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	mock_effect_data.reset()
	scheduler._run_physics_update(effect_instance, 0.1)
	assert_true(mock_effect_data.has_physics_updated, "physics_update should be called")
	assert_eq(mock_effect_data.value_on_physics_update, 1, "physics_update should run exactly once")
	effect_instance.free()

# _run_exit() #

## test when effect is null
func test_run_exit_when_effect_is_null():
	mock_effect_data.reset()
	scheduler._run_exit(null)
	assert_false(mock_effect_data.has_exited, "null effect should not run exit")
	assert_eq(mock_effect_data.value_on_exit, 0, "null effect should not change exit data")

## test that effect.exit() is called
func test_run_exit_calls_effect_exit():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	mock_effect_data.reset()
	scheduler._run_exit(effect_instance)
	assert_true(mock_effect_data.has_exited, "exit should be called")
	assert_eq(mock_effect_data.value_on_exit, 1, "exit should run exactly once")
	effect_instance.free()

# public methods #

# enable_scheduler() #

## test that scheduler is enabled
func test_enable_scheduler_sets_enabled_true():
	scheduler.disable_scheduler()
	assert_false(scheduler.is_scheduler_enabled(), "setup should start disabled")
	scheduler.enable_scheduler()
	assert_true(scheduler.is_scheduler_enabled(), "enable_scheduler should set scheduler enabled")
	assert_false(scheduler.is_scheduler_disabled(), "scheduler should not report disabled after enabling")

## test that scheduler processing methods are called when enabled
func test_enable_scheduler_allows_processing_when_enabled():
	var effect_instance = MockEffect10.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	mock_effect_data.reset()
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")

	scheduler.enable_scheduler()
	scheduler._process(0.1)

	assert_false(scheduler.is_effect_waiting(effect_instance), "effect should leave waiting when scheduler is enabled")
	assert_true(mock_effect_data.value_on_update > 0, "update should run when scheduler is enabled")
	assert_eq(mock_effect_data.generic_value, 10, "enter should run exactly once during processing")
	scheduler.remove_all_effects()
	effect_instance.free()

# disable_scheduler() #

## test that scheduler is disabled
func test_disable_scheduler_sets_enabled_false():
	scheduler.enable_scheduler()
	assert_true(scheduler.is_scheduler_enabled(), "setup should start enabled")
	scheduler.disable_scheduler()
	assert_true(scheduler.is_scheduler_disabled(), "disable_scheduler should set scheduler disabled")
	assert_false(scheduler.is_scheduler_enabled(), "scheduler should not report enabled after disabling")

## test that scheduler processing methods are not called when disabled
func test_disable_scheduler_blocks_processing_when_disabled():
	var effect_instance = MockEffect10.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	mock_effect_data.reset()
	assert_true(scheduler.add_effect(effect_instance), "setup add failed")

	scheduler.disable_scheduler()
	scheduler._process(0.1)

	assert_true(scheduler.is_effect_waiting(effect_instance), "effect should stay waiting when scheduler is disabled")
	assert_eq(mock_effect_data.value_on_update, 0, "update should not run when scheduler is disabled")
	assert_eq(mock_effect_data.generic_value, 0, "enter should not run when scheduler is disabled")
	scheduler.remove_all_effects()
	effect_instance.free()

# add_effect() #

## test adding a normal effect
func test_add_effect_with_normal_effect():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "Expected effect to be in waiting queue after being added, but it was not found")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to be in waiting queue after being added, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## Test adding a unique effect
func test_add_effect_with_unique_effect():
	var effect_instance = MockEffect4.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "Expected unique effect to be in waiting queue after being added, but it was not found")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected unique effect to be in waiting queue after being added, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test adding a persistent effect
func test_add_effect_with_persistent_effect():
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance), "Expected persistent effect to be in waiting queue after being added, but it was not found")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected persistent effect to be in waiting queue after being added, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test adding a null effect
func test_add_effect_with_null_effect():
	assert_false(scheduler.add_effect(null), "Expected adding a null effect to return false, but it returned true")
	

## test adding a unique effect that is already active
func test_add_effect_with_unique_effect_already_active():
	var effect_instance1 = MockEffect4.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect4.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance1), "Expected first unique effect to be added successfully, but it was not")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_false(scheduler.add_effect(effect_instance2), "Expected adding a unique effect that is already active to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

## test adding an effect when waiting queue limit has been reached
func test_add_effect_when_waiting_queue_limit_reached():
	scheduler.max_queue_size = 1
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance1), "Expected first effect to be added successfully, but it was not")
	assert_false(scheduler.add_effect(effect_instance2), "Expected adding an effect when waiting queue limit has been reached to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()


## test that adding an effect emits the effect_added signal
func test_add_effect_emits_effect_added_signal():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	watch_signals(scheduler)
	scheduler.add_effect(effect_instance)
	assert_signal_emitted(scheduler, "effect_added", "Expected effect_added signal to be emitted when adding an effect, but it was not")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that when an effect is not added, the effect_added signal is not emitted
func test_add_effect_does_not_emit_effect_added_signal_when_not_added():
	watch_signals(scheduler)
	assert_false(scheduler.add_effect(null), "Expected adding a null effect to return false, but it returned true")
	assert_signal_not_emitted(scheduler, "effect_added", "Expected effect_added signal to not be emitted when adding a null effect, but it was emitted")

## test adding an effect with a reserved id
func test_add_effect_with_reserved_id():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var reserved_id = scheduler.reserve_effect_id(scheduler.get_id_next_available())
	assert_true(scheduler.add_effect(effect_instance1, reserved_id), "Expected first effect to be added successfully with reserved id, but it was not")
	assert_false(scheduler.add_effect(effect_instance2, reserved_id), "Expected adding an effect with a reserved id that is already in use to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

## test adding an effect with a reserved id that is already in use
func test_add_effect_with_reserved_id_already_in_use():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var reserved_id = 11
	assert_true(scheduler.add_effect(effect_instance1, reserved_id), "Expected first effect to be added successfully with reserved id, but it was not")
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_false(scheduler.add_effect(effect_instance2, reserved_id), "Expected adding an effect with a reserved id that is already in use to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

## test adding an effect with a reserved id when waiting queue limit has been reached
func test_add_effect_with_reserved_id_when_waiting_queue_limit_reached():
	scheduler.max_queue_size = 1
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var reserved_id1 = scheduler.reserve_effect_id(scheduler.get_id_next_available())
	var reserved_id2 = scheduler.reserve_effect_id(scheduler.get_id_next_available())
	assert_true(scheduler.add_effect(effect_instance1, reserved_id1), "Expected first effect to be added successfully with reserved id, but it was not")
	assert_false(scheduler.add_effect(effect_instance2, reserved_id2), "Expected adding an effect with a reserved id when waiting queue limit has been reached to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

## test adding multiple of the same effects
func test_add_effect_with_multiple_of_same_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance1), "Expected first effect to be added successfully, but it was not")
	assert_true(scheduler.add_effect(effect_instance2), "Expected second effect of same type to be added successfully, but it was not")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

## Test adding multiple different effects
func test_add_effect_with_multiple_different_effects():
	var effect_list:Array[Effect] = []
	var effect_instance:Effect
	for i in range(2):
		effect_instance = MockEffect1.new()
		effect_instance.add_test_environment_data(mock_effect_data)
		effect_list.append(effect_instance)
	for i in range(3):
		effect_instance = MockEffect2.new()
		effect_instance.add_test_environment_data(mock_effect_data)
		effect_list.append(effect_instance)
	for i in range(2):
		effect_instance = MockEffect5.new()
		effect_instance.add_test_environment_data(mock_effect_data)
		effect_list.append(effect_instance)
	effect_instance = MockEffect4.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_list.append(effect_instance)
	for effect in effect_list:
		assert_true(scheduler.add_effect(effect), "Expected effect " + str(effect.get_effect_name()) + " to be added successfully, but it was not")
	scheduler.remove_all_effects()
	for effect in effect_list:
		effect.free()

## Test adding an effect with a reserved id, then adding another effect with the same reserved id after the first one is removed
func test_add_effect_with_reserved_id_then_add_another_with_same_reserved_id_after_removal():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var reserved_id = scheduler.get_id_next_available()
	scheduler.reserve_effect_id(reserved_id)
	assert_true(scheduler.add_effect(effect_instance1, reserved_id), "Expected first effect to be added successfully with reserved id, but it was not")
	scheduler.remove_all_effects()
	assert_true(scheduler.add_effect(effect_instance2, reserved_id), "Expected second effect to be added successfully with same reserved id after first one is removed, but it was not")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# pause_effect() #

## testing giving an incorrect effect id
func test_pause_effect_with_incorrect_id():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var incorrect_id = 9999
	assert_false(scheduler.pause_effect(incorrect_id), "Expected pausing an effect with an incorrect id to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test pausing an effect in waiting queue
func test_pause_effect_in_waiting_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	assert_true(scheduler.pause_effect(record.id), "Expected pausing an effect in waiting queue to return true, but it returned false")
	assert_true(record.is_paused, "Expected effect record to be marked as paused after pausing, but it was not")
	scheduler.remove_all_effects()
	effect_instance.free()

## test pausing an effect in entering queue
func test_pause_effect_in_entering_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	assert_true(scheduler.pause_effect(record.id), "Expected pausing an effect in entering queue to return true, but it returned false")
	assert_true(record.is_paused, "Expected effect record to be marked as paused after pausing, but it was not")
	scheduler.remove_all_effects()
	effect_instance.free()

## test pausing an effect in active queue
func test_pause_effect_in_active_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	assert_true(scheduler.pause_effect(record.id), "Expected pausing an effect in active queue to return true, but it returned false")
	assert_true(record.is_paused, "Expected effect record to be marked as paused after pausing, but it was not")
	scheduler.remove_all_effects()
	effect_instance.free()

## test pausing an effect in exiting queue
func test_pause_effect_in_exiting_queue():
	var effect_instance = MockEffect5.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(0.05)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	scheduler._process_active_effects(0.1, false)
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	assert_true(scheduler.pause_effect(record.id), "Expected pausing an effect in exiting queue to return true, but it returned false")
	assert_true(record.is_paused, "Expected effect record to be marked as paused after pausing, but it was not")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that pausing an effect prevents it from being processed in scheduler
func test_pause_effect_prevents_processing_in_scheduler():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	scheduler.pause_effect(record.id)
	scheduler._process_active_effects(0.1, false)
	assert_eq(mock_effect_data.value_on_update, 0, "Expected paused effect to not be processed in scheduler, but it was")
	scheduler.remove_all_effects()
	effect_instance.free()


# resume_effect() #

## testing giving an incorrect effect id
func test_resume_effect_with_incorrect_id():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var incorrect_id = 9999
	assert_false(scheduler.resume_effect(incorrect_id), "Expected resuming an effect with an incorrect id to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test resuming an effect in waiting queue
func test_resume_effect_in_waiting_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	scheduler.pause_effect(record.id)
	assert_true(scheduler.resume_effect(record.id), "Expected resuming an effect in waiting queue to return true, but it returned false")
	assert_false(record.is_paused, "Expected effect record to be marked as not paused after resuming, but it was still marked as paused")
	scheduler.remove_all_effects()
	effect_instance.free()

## test resuming an effect in entering queue
func test_resume_effect_in_entering_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	scheduler.pause_effect(record.id)
	assert_true(scheduler.resume_effect(record.id), "Expected resuming an effect in entering queue to return true, but it returned false")
	assert_false(record.is_paused, "Expected effect record to be marked as not paused after resuming, but it was still marked as paused")
	scheduler.remove_all_effects()
	effect_instance.free()

## test resuming an effect in active queue
func test_resume_effect_in_active_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	scheduler.pause_effect(record.id)
	assert_true(scheduler.resume_effect(record.id), "Expected resuming an effect in active queue to return true, but it returned false")
	assert_false(record.is_paused, "Expected effect record to be marked as not paused after resuming, but it was still marked as paused")
	scheduler.remove_all_effects()
	effect_instance.free()

## test resuming an effect in exiting queue
func test_resume_effect_in_exiting_queue():
	var effect_instance = MockEffect5.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(0.05)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	scheduler._process_active_effects(0.1, false)
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	scheduler.pause_effect(record.id)
	assert_true(scheduler.resume_effect(record.id), "Expected resuming an effect in exiting queue to return true, but it returned false")
	assert_false(record.is_paused, "Expected effect record to be marked as not paused after resuming, but it was still marked as paused")
	scheduler.remove_all_effects()
	effect_instance.free()

## test that resuming an effect allows it to be processed in scheduler
func test_resume_effect_allows_processing_in_scheduler():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	# Isolate pause/resume behavior so cooldown does not suppress update on first resumed tick.
	effect_instance.set_enable_cooldown(false)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	scheduler.pause_effect(record.id)
	scheduler._process_active_effects(2.1, false)
	assert_eq(mock_effect_data.value_on_update, 0, "Expected paused effect to not be processed in scheduler, but it was")
	scheduler.resume_effect(record.id)
	scheduler._process_active_effects(1.0, false)
	assert_eq(mock_effect_data.value_on_update, 1, "Expected resumed effect to be processed in scheduler, but it was not")
	scheduler.remove_all_effects()
	effect_instance.free()


# pause_all_effects() #

## test pausing when there are no effects
func test_pause_all_effects_when_no_effects():
	assert_false(scheduler.pause_all_effects(), "Expected pausing all effects when there are no effects to return false, but it returned true")
	

## test that pausing all affects works in all queues
func test_pause_all_effects_in_all_queues():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect5.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	scheduler._process_active_effects(0.1, false)
	assert_true(scheduler.pause_all_effects(), "Expected pausing all effects to return true, but it returned false")
	var all_records:Array[EffectScheduler.ScheduleRecord] = scheduler.get_all_records()
	if all_records.size() > 0:
		for record in all_records:
			assert_true(record.is_paused, "Expected effect to be paused, but it is not paused")
	assert_ne(all_records.size(), 0, "Expected there to be 3 rocrds, but returned none.")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# resume_all_effects() #

## test resuming when there are no effects
func test_resume_all_effects_when_no_effects():
	assert_false(scheduler.resume_all_effects(), "Expected resuming all effects when there are no effects to return false, but it returned true")

## test that resuming all affects works in all queues
func test_resume_all_effects_in_all_queues():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect5.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	scheduler._process_active_effects(0.1, false)
	scheduler.pause_all_effects()
	assert_true(scheduler.resume_all_effects(), "Expected resuming all effects to return true, but it returned false")
	var all_records:Array[EffectScheduler.ScheduleRecord] = scheduler.get_all_records()
	if all_records.size() > 0:
		for record in all_records:
			assert_false(record.is_paused, "Expected effect to be resumed, but it is still paused")
	assert_ne(all_records.size(), 0, "Expected there to be 3 rocrds, but returned none.")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# remove_effect_by_instance() #

## test removing an effect by instance
func test_remove_effect_by_instance():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_true(scheduler.remove_effect_by_instance(effect_instance), "Expected removing an effect by instance to return true, but it returned false")
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected effect to not be in waiting queue after being removed by instance, but it was found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing an effect that is not in any queue
func test_remove_effect_by_instance_not_in_any_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler.remove_effect_by_instance(effect_instance), "Expected removing an effect that is not in any queue by instance to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing with an incorrect effect id
func test_remove_effect_by_instance_with_incorrect_instance():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var incorrect_instance = MockEffect1.new()
	incorrect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler.remove_effect_by_instance(incorrect_instance), "Expected removing an effect with an incorrect instance to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()
	incorrect_instance.free()

## test removing a null instance
func test_remove_effect_by_instance_with_null_instance():
	assert_false(scheduler.remove_effect_by_instance(null), "Expected removing an effect with a null instance to return false, but it returned true")

# remove_effect_by_id() #

## test removing an effect by id
func test_remove_effect_by_id():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var record = scheduler.get_effect_record_by_instance(effect_instance)
	assert_true(scheduler.remove_effect_by_id(record.id), "Expected removing an effect by id to return true, but it returned false")
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected effect to not be in waiting queue after being removed by id, but it was found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing an effect that is not in any queue
func test_remove_effect_by_id_not_in_any_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler.has_effect(effect_instance), "Expected removing an effect that is not in any queue by id to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing with an incorrect effect id
func test_remove_effect_by_id_with_incorrect_id():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var incorrect_id = 9999
	assert_false(scheduler.remove_effect_by_id(incorrect_id), "Expected removing an effect with an incorrect id to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

# remove_effect_by_type() #

## test removing effect with type
func test_remove_effect_by_type():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_true(scheduler.remove_effect_by_type(effect_instance.get_type()), "Expected removing an effect by type to return true, but it returned false")
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected effect to not be in waiting queue after being removed by type, but it was found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing effect with type that is not in any queue
func test_remove_effect_by_type_not_in_any_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_effect_by_type(Effect.Type.STRUCTURAL), "Expected removing an effect by type that is not in any queue to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing effect with type when there is more than one of that type in the queues
func test_remove_effect_by_type_with_multiple_of_same_type_in_queues():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	assert_true(scheduler.remove_effect_by_type(effect_instance1.get_type()), "Expected removing an effect by type to return true when there are multiple of that type in the queues, but it returned false")
	assert_false(scheduler.is_effect_waiting(effect_instance1), "Expected first effect to not be in waiting queue after being removed by type, but it was found")
	assert_true(scheduler.is_effect_waiting(effect_instance2), "Expected second effect to still be in waiting queue after removing first effect by type, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# remove_all_effects_of_type() #

## test removing all effects with type
func test_remove_all_effects_of_type():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect2.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	assert_true(scheduler.remove_all_effects_of_type(effect_instance1.get_type()), "Expected removing all effects by type to return true, but it returned false")
	assert_false(scheduler.has_effect(effect_instance1), "Expected first effect to not be in any queue after being removed by type, but it was found")
	assert_false(scheduler.has_effect(effect_instance2), "Expected second effect to not be in any queue after being removed by type, but it was found")
	assert_true(scheduler.has_effect(effect_instance3), "Expected third effect to still be in any queue after removing effects by type, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

## test removing all effects with type that is not in any queue
func test_remove_all_effects_of_type_not_in_any_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_effects_of_type(Effect.Type.ENVIRONMENTAL), "Expected removing all effects by type that is not in any queue to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

# remove_effect_by_name() #

## test removing effect with name
func test_remove_effect_by_name_when_removing_an_effect_that_exists():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_true(scheduler.remove_effect_by_name(effect_instance.get_effect_name()), "Expected removing an effect by name to return true, but it returned false")
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected effect to not be in waiting queue after being removed by name, but it was found")
	scheduler.remove_all_effects()
	effect_instance.free()
	

## test removing effect with name that is not in any queue
func test_remove_effect_by_name_not_in_any_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_effect_by_name("Nonexistent Effect"), "Expected removing an effect by name that is not in any queue to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing effect with name when there is more than one of that name in the queues
func test_remove_effect_by_name_with_multiple_of_same_name_in_queues():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	assert_true(scheduler.remove_effect_by_name(effect_instance1.get_effect_name()), "Expected removing an effect by name to return true when there are multiple of that name in the queues, but it returned false")
	assert_false(scheduler.is_effect_waiting(effect_instance1), "Expected first effect to not be in waiting queue after being removed by name, but it was found")
	assert_true(scheduler.is_effect_waiting(effect_instance2), "Expected second effect to still be in waiting queue after removing first effect by name, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# remove_all_effects_of_name() #

## test removing all effects with name
func test_remove_all_effects_of_name():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect2.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	assert_true(scheduler.remove_all_effects_by_name(effect_instance1.get_effect_name()), "Expected removing all effects by name to return true, but it returned false")
	assert_false(scheduler.has_effect(effect_instance1), "Expected first effect to not be in any queue after being removed by name, but it was found")
	assert_false(scheduler.has_effect(effect_instance2), "Expected second effect to not be in any queue after being removed by name, but it was found")
	assert_true(scheduler.has_effect(effect_instance3), "Expected third effect to still be in any queue after removing effects by name, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

## test removing all effects with name that is not in any queue
func test_remove_all_effects_of_name_not_in_any_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_effects_by_name("Hubba Bubba"), "Expected removing all effects by name that is not in any queue to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

# remove_all_persistent_effects() #

## test removing all persistent effects when there are no persistent effects
func test_remove_all_persistent_effects_when_no_persistent_effects():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_persistent_effects(), "Expected removing all persistent effects when there are no persistent effects to return false, but it returned true")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to still be in waiting queue after attempting to remove persistent effects when there are no persistent effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing all persistent effects when there are some persistent effects
func test_remove_all_persistent_effects_when_some_persistent_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect3.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect3.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	assert_true(scheduler.remove_all_persistent_effects(), "Expected removing all persistent effects when there are some persistent effects to return true, but it returned false")
	assert_true(scheduler.has_effect(effect_instance1), "Expected non-persistent effect to still be present after removing persistent effects, but it was not found")
	assert_false(scheduler.has_effect(effect_instance2), "Expected persistent effect to be deleted after removing persistent effects, but it was found")
	assert_false(scheduler.has_effect(effect_instance3), "Expected persistent effect to be deleted after removing persistent effects, but it was found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()


# remove_all_non_persistent_effects() #

## test removing all non-persistent effects when there are no non-persistent effects
func test_remove_all_non_persistent_effects_when_no_non_persistent_effects():
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_non_persistent_effects(), "Expected removing all non-persistent effects when there are no non-persistent effects to return false, but it returned true")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to still be in waiting queue after attempting to remove non-persistent effects when there are no non-persistent effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()


## test removing all non-persistent effects when there are some non-persistent effects
func test_remove_all_non_persistent_effects_when_some_non_persistent_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect3.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect3.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	assert_true(scheduler.remove_all_non_persistent_effects(), "Expected removing all non-persistent effects when there are some non-persistent effects to return true, but it returned false")
	assert_false(scheduler.has_effect(effect_instance1), "Expected non-persistent effect to be deleted after removing non-persistent effects, but it was found")
	assert_true(scheduler.has_effect(effect_instance2), "Expected persistent effect to still be present after removing non-persistent effects, but it was not found")
	assert_true(scheduler.has_effect(effect_instance3), "Expected persistent effect to still be present after removing non-persistent effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# remove_all_unique_effects() #

## test removing all unique effects when there are no unique effects
func test_remove_all_unique_effects_when_no_unique_effects():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_unique_effects(), "Expected removing all unique effects when there are no unique effects to return false, but it returned true")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to still be in waiting queue after attempting to remove unique effects when there are no unique effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing all unique effects when there are some unique effects
func test_remove_all_unique_effects_when_some_unique_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect4.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect12.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance1), "Expected non-unique setup effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance2), "Expected first unique setup effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance3), "Expected second unique setup effect to be added, but add_effect returned false")
	assert_true(scheduler.remove_all_unique_effects(), "Expected removing all unique effects when there are some unique effects to return true, but it returned false")
	assert_true(scheduler.has_effect(effect_instance1), "Expected non-unique effect to still be present after removing unique effects, but it was not found")
	assert_false(scheduler.has_effect(effect_instance2), "Expected unique effect to be deleted after removing unique effects, but it was found")
	assert_false(scheduler.has_effect(effect_instance3), "Expected unique effect to be deleted after removing unique effects, but it was found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# remove_all_non_unique_effects() #

## test removing all non-unique effects when there are no non-unique effects
func test_remove_all_non_unique_effects_when_no_non_unique_effects():
	var effect_instance = MockEffect4.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_non_unique_effects(), "Expected removing all non-unique effects when there are no non-unique effects to return false, but it returned true")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to still be in waiting queue after attempting to remove non-unique effects when there are no non-unique effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing all non-unique effects when there are some non-unique effects
func test_remove_all_non_unique_effects_when_some_non_unique_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect4.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect12.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	assert_true(scheduler.add_effect(effect_instance1), "Expected non-unique setup effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance2), "Expected first unique setup effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance3), "Expected second unique setup effect to be added, but add_effect returned false")
	assert_true(scheduler.remove_all_non_unique_effects(), "Expected removing all non-unique effects when there are some non-unique effects to return true, but it returned false")
	assert_false(scheduler.has_effect(effect_instance1), "Expected non-unique effect to be deleted after removing non-unique effects, but it was found")
	assert_true(scheduler.has_effect(effect_instance2), "Expected unique effect to still be present after removing non-unique effects, but it was not found")
	assert_true(scheduler.has_effect(effect_instance3), "Expected unique effect to still be present after removing non-unique effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# remove_all_timed_effects() #

## test removing all timed effects when there are no timed effects
func test_remove_all_timed_effects_when_no_timed_effects():
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_timed_effects(), "Expected removing all timed effects when there are no timed effects to return false, but it returned true")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to still be in waiting queue after attempting to remove timed effects when there are no timed effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing all timed effects when there are some timed effects
func test_remove_all_timed_effects_when_some_timed_effects():
	# timed-only
	var effect_instance1 = MockEffect13.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	# cooldown-only (non-timed for this API)
	var effect_instance2 = MockEffect6.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	# timing+cooldown
	var effect_instance3 = MockEffect14.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	# another timing+cooldown
	var effect_instance4 = MockEffect1.new()
	effect_instance4.add_test_environment_data(mock_effect_data)
	# plain non-timed
	var effect_instance5 = MockEffect10.new()
	effect_instance5.add_test_environment_data(mock_effect_data)

	assert_true(scheduler.add_effect(effect_instance1), "Expected timed-only effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance2), "Expected cooldown-only effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance3), "Expected timing+cooldown effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance4), "Expected second timing+cooldown effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance5), "Expected plain non-timed effect to be added, but add_effect returned false")

	assert_true(scheduler.remove_all_timed_effects(), "Expected removing all timed effects when there are some timed effects to return true, but it returned false")
	assert_false(scheduler.has_effect(effect_instance1), "Expected timed-only effect to be removed by remove_all_timed_effects, but it was found")
	assert_false(scheduler.has_effect(effect_instance3), "Expected timing+cooldown effect to be removed by remove_all_timed_effects, but it was found")
	assert_false(scheduler.has_effect(effect_instance4), "Expected second timing+cooldown effect to be removed by remove_all_timed_effects, but it was found")
	assert_true(scheduler.has_effect(effect_instance2), "Expected cooldown-only effect to remain after remove_all_timed_effects, but it was not found")
	assert_true(scheduler.has_effect(effect_instance5), "Expected plain non-timed effect to remain after remove_all_timed_effects, but it was not found")

	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()
	effect_instance4.free()
	effect_instance5.free()


# remove_all_non_timed_effects() #

## test removing all non-timed effects when there are no non-timed effects
func test_remove_all_non_timed_effects_when_no_non_timed_effects():
	var effect_instance = MockEffect13.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_non_timed_effects(), "Expected removing all non-timed effects when there are no non-timed effects to return false, but it returned true")
	assert_true(scheduler.has_effect(effect_instance), "Expected effect to still be in waiting queue after attempting to remove non-timed effects when there are no non-timed effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing all non-timed effects when there are some non-timed effects
func test_remove_all_non_timed_effects_when_some_non_timed_effects():
	# timed-only
	var effect_instance1 = MockEffect13.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	# cooldown-only (non-timed for this API)
	var effect_instance2 = MockEffect6.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	# timing+cooldown
	var effect_instance3 = MockEffect14.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	# another timing+cooldown
	var effect_instance4 = MockEffect1.new()
	effect_instance4.add_test_environment_data(mock_effect_data)
	# plain non-timed
	var effect_instance5 = MockEffect10.new()
	effect_instance5.add_test_environment_data(mock_effect_data)

	assert_true(scheduler.add_effect(effect_instance1), "Expected timed-only effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance2), "Expected cooldown-only effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance3), "Expected timing+cooldown effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance4), "Expected second timing+cooldown effect to be added, but add_effect returned false")
	assert_true(scheduler.add_effect(effect_instance5), "Expected plain non-timed effect to be added, but add_effect returned false")

	assert_true(scheduler.remove_all_non_timed_effects(), "Expected removing all non-timed effects when there are some non-timed effects to return true, but it returned false")
	assert_false(scheduler.has_effect(effect_instance2), "Expected cooldown-only effect to be removed by remove_all_non_timed_effects, but it was found")
	assert_false(scheduler.has_effect(effect_instance5), "Expected plain non-timed effect to be removed by remove_all_non_timed_effects, but it was ffound")
	assert_true(scheduler.has_effect(effect_instance1), "Expected timed-only effect to remain after remove_all_non_timed_effects, but it was not found")
	assert_true(scheduler.has_effect(effect_instance3), "Expected timing+cooldown effect to remain after remove_all_non_timed_effects, but it was not found")
	assert_true(scheduler.has_effect(effect_instance4), "Expected second timing+cooldown effect to remain after remove_all_non_timed_effects, but it was not found")
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()
	effect_instance4.free()
	effect_instance5.free()

# remove_all_repeating_effects() #

## test removing all repeating effects when there are no repeating effects
func test_remove_all_repeating_effects_when_no_repeating_effects():
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_repeating_effects(), "Expected removing all repeating effects when there are no repeating effects to return false, but it returned true")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to still be in waiting queue after attempting to remove repeating effects when there are no repeating effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing all repeating effects when there are some repeating effects
func test_remove_all_repeating_effects_when_some_repeating_effects():
	var effect_instance1 = MockEffect3.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect2.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	assert_true(scheduler.remove_all_repeating_effects(), "Expected removing all repeating effects when there are some repeating effects to return true, but it returned false")
	assert_true(scheduler.has_effect(effect_instance1), "Expected non-repeating effect to still be present after removing repeating effects, but it was not found")
	assert_false(scheduler.has_effect(effect_instance2), "Expected first repeating effect to be deleted after removing repeating effects, but it was found")
	assert_false(scheduler.has_effect(effect_instance3), "Expected second repeating effect to be deleted after removing repeating effects, but it was found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# remove_all_non_repeating_effects() #

## test removing all non-repeating effects when there are no non-repeating effects
func test_remove_all_non_repeating_effects_when_no_non_repeating_effects():
	var effect_instance = MockEffect2.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.remove_all_non_repeating_effects(), "Expected removing all non-repeating effects when there are no non-repeating effects to return false, but it returned true")
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to still be in waiting queue after attempting to remove non-repeating effects when there are no non-repeating effects, but it was not found")
	scheduler.remove_all_effects()
	effect_instance.free()

## test removing all non-repeating effects when there are some non-repeating effects
func test_remove_all_non_repeating_effects_when_some_non_repeating_effects():
	var effect_instance1 = MockEffect2.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect3.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect2.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	assert_true(scheduler.remove_all_non_repeating_effects(), "Expected removing all non-repeating effects when there are some non-repeating effects to return true, but it returned false")
	assert_true(scheduler.has_effect(effect_instance1), "Expected first repeating effect to still be present after removing non-repeating effects, but it was not found")
	assert_true(scheduler.has_effect(effect_instance3), "Expected second repeating effect to still be present after removing non-repeating effects, but it was not found")
	assert_false(scheduler.has_effect(effect_instance2), "Expected non-repeating effect to be deleted after removing non-repeating effects, but it was found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# remove_all_effects() #

## test removing all effects when there are no effects
func test_remove_all_effects_when_no_effects():
	assert_false(scheduler.remove_all_effects(), "Expected removing all effects when there are no effects to return false, but it returned true")

## test removing all effects when there are some effects
func test_remove_all_effects_when_some_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect2.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	var effect_instance3 = MockEffect3.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.add_effect(effect_instance3)
	assert_true(scheduler.remove_all_effects(), "Expected removing all effects when there are some effects to return true, but it returned false")
	assert_false(scheduler.has_effect(effect_instance1), "Expected first effect to be deleted after removing all effects, but it was found")
	assert_false(scheduler.has_effect(effect_instance2), "Expected second effect to be deleted after removing all effects, but it was found")
	assert_false(scheduler.has_effect(effect_instance3), "Expected third effect to be deleted after removing all effects, but it was found")
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# get_waiting_effects() #

## test getting waiting effects when there are no waiting effects
func test_get_waiting_effects_when_no_waiting_effects():
	var waiting_effects = scheduler.get_waiting_effects()
	assert_eq(waiting_effects.size(), 0, "Expected get_waiting_effects to return an empty array when there are no waiting effects, but it returned an array of size of " + str(waiting_effects.size()))

## test getting waiting effects when there are some waiting effects
func test_get_waiting_effects_when_some_waiting_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect2.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	var waiting_effects = scheduler.get_waiting_effects()
	assert_eq(waiting_effects.size(), 2, "Expected get_waiting_effects to return an array of size 2 when there are two waiting effects, but it returned an array of size " + str(waiting_effects.size()))
	assert_true(waiting_effects.has(effect_instance1), "Expected get_waiting_effects to return an array containing the first waiting effect, but it was not found")
	assert_true(waiting_effects.has(effect_instance2), "Expected get_waiting_effects to return an array containing the second waiting effect, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# get_entering_effects() #

## test getting entering effects when there are no entering effects
func test_get_entering_effects_when_no_entering_effects():
	var entering_effects = scheduler.get_entering_effects()
	assert_eq(entering_effects.size(), 0, "Expected get_entering_effects to return an empty array when there are no entering effects, but it returned an array of size of " + str(entering_effects.size()))

## test getting entering effects when there are some entering effects
func test_get_entering_effects_when_some_entering_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect2.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler._process_waiting_effects()
	var entering_effects = scheduler.get_entering_effects()
	assert_eq(entering_effects.size(), 2, "Expected get_entering_effects to return an array of size 2 when there are two entering effects, but it returned an array of size " + str(entering_effects.size()))
	assert_true(entering_effects.has(effect_instance1), "Expected get_entering_effects to return an array containing the first entering effect, but it was not found")
	assert_true(entering_effects.has(effect_instance2), "Expected get_entering_effects to return an array containing the second entering effect, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# get_active_effects() #

## test getting active effects when there are no active effects
func test_get_active_effects_when_no_active_effects():
	var active_effects = scheduler.get_active_effects()
	assert_eq(active_effects.size(), 0, "Expected get_active_effects to return an empty array when there are no active effects, but it returned an array of size of " + str(active_effects.size()))

## test getting active effects when there are some active effects
func test_get_active_effects_when_some_active_effects():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect2.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var active_effects = scheduler.get_active_effects()
	assert_eq(active_effects.size(), 2, "Expected get_active_effects to return an array of size 2 when there are two active effects, but it returned an array of size " + str(active_effects.size()))
	assert_true(active_effects.has(effect_instance1), "Expected get_active_effects to return an array containing the first active effect, but it was not found")
	assert_true(active_effects.has(effect_instance2), "Expected get_active_effects to return an array containing the second active effect, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# get_exiting_effects() #

## test getting exiting effects when there are no exiting effects
func test_get_exiting_effects_when_no_exiting_effects():
	var exiting_effects = scheduler.get_exiting_effects()
	assert_eq(exiting_effects.size(), 0, "Expected get_exiting_effects to return an empty array when there are no exiting effects, but it returned an array of size of " + str(exiting_effects.size()))

## test getting exiting effects when there are some exiting effects
func test_get_exiting_effects_when_some_exiting_effects():
	var effect_instance1 = MockEffect5.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	effect_instance1.set_enable_timing(true)
	effect_instance1.set_duration(0.05)
	var effect_instance2 = MockEffect5.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	effect_instance2.set_enable_timing(true)
	effect_instance2.set_duration(0.05)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	scheduler._process_active_effects(0.1, false)
	var exiting_effects = scheduler.get_exiting_effects()
	assert_eq(exiting_effects.size(), 2, "Expected get_exiting_effects to return an array of size 2 when there are two exiting effects, but it returned an array of size " + str(exiting_effects.size()))
	assert_true(exiting_effects.has(effect_instance1), "Expected get_exiting_effects to return an array containing the first exiting effect, but it was not found")
	assert_true(exiting_effects.has(effect_instance2), "Expected get_exiting_effects to return an array containing the second exiting effect, but it was not found")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# _update_effect() #

## test updating an effect that is not in any queue
func test_update_effect_when_effect_is_not_in_any_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler._update_effect(effect_instance, 0.1), "Expected updating an effect that is not in any queue to return false, but it returned true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when an effect is finished, will it still try to update it
func test_update_effect_when_effect_is_finished():
	var effect_instance = MockEffect13.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	effect_instance.set_elapsed_time(effect_instance.get_duration())
	assert_true(effect_instance.is_finished(), "effect should be finished")
	assert_false(scheduler._update_effect(effect_instance, 0.1), "finished effect should not update")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when an effect has timing that needs updating
func test_update_effect_when_effect_has_timing():
	var effect_instance = MockEffect13.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	effect_instance.set_elapsed_time(0.0)
	assert_true(scheduler._update_effect(effect_instance, 0.5), "timed effect should update")
	assert_eq(effect_instance.get_elapsed_time(), 0.5, "elapsed time should advance")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when an effect has cooldown that needs updating
func test_update_effect_when_effect_has_cooldown():
	var effect_instance = MockEffect6.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	effect_instance.set_cooldown_elapsed(0.0)
	assert_true(effect_instance.is_on_cooldown(), "effect should start on cooldown")
	assert_true(scheduler._update_effect(effect_instance, 0.5), "cooldown effect should update")
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.5, "cooldown should advance")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when an effect has repeat that needs updating
func test_update_effect_when_effect_has_repeat():
	var effect_instance = MockEffect9.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	effect_instance.set_repeat_count(0)
	assert_true(scheduler._update_effect(effect_instance, 0.5), "repeat-only effect should update")
	assert_eq(effect_instance.get_repeat_count(), 0, "repeat should not change without timing")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when an effect has timing, repeat that needs updating
func test_update_effect_when_effect_has_timing_and_repeat():
	var effect_instance = MockEffect9.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(0.5)
	effect_instance.set_elapsed_time(0.4)
	effect_instance.set_repeat_count(0)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_true(scheduler._update_effect(effect_instance, 0.2), "timing+repeat effect should update")
	assert_eq(effect_instance.get_repeat_count(), 1, "repeat should increment")
	assert_eq(effect_instance.get_elapsed_time(), 0.0, "elapsed should reset after repeat")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when an effect has timing, cooldown that needs updating
func test_update_effect_when_effect_has_timing_and_cooldown():
	var effect_instance = MockEffect14.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_elapsed_time(0.0)
	effect_instance.set_cooldown_elapsed(0.0)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_true(scheduler._update_effect(effect_instance, 0.5), "timing+cooldown effect should update")
	assert_eq(effect_instance.get_elapsed_time(), 0.5, "elapsed should advance")
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.5, "cooldown should advance")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when an effect has repeat, cooldown that needs updating
func test_update_effect_when_effect_has_repeat_and_cooldown():
	var effect_instance = MockEffect6.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(0)
	effect_instance.set_cooldown_elapsed(0.0)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_true(scheduler._update_effect(effect_instance, 0.5), "repeat+cooldown effect should update")
	assert_eq(effect_instance.get_repeat_count(), 0, "repeat should not change without timing")
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.5, "cooldown should advance")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when an effect has timing, repeat, cooldown that needs updating
func test_update_effect_when_effect_has_timing_repeat_and_cooldown():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_elapsed_time(1.9)
	effect_instance.set_repeat_count(0)
	effect_instance.set_cooldown_elapsed(0.0)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_true(scheduler._update_effect(effect_instance, 0.2), "timing+repeat+cooldown effect should update")
	assert_eq(effect_instance.get_repeat_count(), 1, "repeat should increment")
	assert_eq(effect_instance.get_elapsed_time(), 0.0, "elapsed should reset")
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.2, "cooldown should advance")
	scheduler.remove_all_effects()
	effect_instance.free()

# Query methods #

# is_effect_waiting() #

## test when effect is not in waiting queue
func test_is_effect_waiting_when_effect_is_not_in_waiting_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected is_effect_waiting to return false when effect is not in waiting queue, but got true")
	# add an additional effect to verify
	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected is_effect_waiting to return false when effect is not in waiting queue, but got true")
	effect_instance.free()
	effect2.free()

## test when effect is waiting in queue
func test_is_effect_waiting_when_effect_is_waiting_in_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected is_effect_waiting to return true when effect is waiting in queue, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect is paused in waiting queue
func test_is_effect_waiting_when_effect_is_paused_in_waiting_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler.pause_effect(scheduler.get_effect_id(effect_instance))
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected is_effect_waiting to return true when effect is paused in waiting queue, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect is entering, active, or exiting but not waiting
func test_is_effect_waiting_when_effect_is_in_other_queues():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected is_effect_waiting to return false when effect is in entering queue, but got true")
	scheduler._process_active_effects(0.1, false)
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected is_effect_waiting to return false when effect is in active queue, but got true")
	scheduler._move_active_to_exiting(scheduler.get_effect_id(effect_instance))
	assert_false(scheduler.is_effect_waiting(effect_instance), "Expected is_effect_waiting to return false when effect is in exiting queue, but got true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test null effect
func test_is_effect_waiting_when_effect_is_null():
	assert_false(scheduler.is_effect_waiting(null), "Expected is_effect_waiting to return false when effect is null, but got true")

# is_effect_active() #

## test when effect is not in active queue
func test_is_effect_active_when_effect_is_not_in_active_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler.is_effect_active(effect_instance), "Expected is_effect_active to return false when effect is not in active queue, but got true")
	# add an additional effect to verify
	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	assert_false(scheduler.is_effect_active(effect_instance), "Expected is_effect_active to return false when effect is not in active queue, but got true")
	effect_instance.free()
	effect2.free()

## test when effect is active in queue
func test_is_effect_active_when_effect_is_active_in_queue():
	var effect_instance = MockEffect9.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	assert_true(scheduler.is_effect_active(effect_instance), "Expected is_effect_active to return true when effect is active in queue, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect is paused in active queue
func test_is_effect_active_when_effect_is_paused_in_active_queue():
	var effect_instance = MockEffect9.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	scheduler.pause_effect(scheduler.get_effect_id(effect_instance))
	assert_false(scheduler.is_effect_active(effect_instance), "Expected is_effect_active to return false when effect is paused in active queue, but got true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test effect activity across queue transitions
func test_is_effect_active_across_waiting_entering_active_exiting_states():
	var effect_instance = MockEffect9.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	# waiting
	assert_false(scheduler.is_effect_active(effect_instance), "Expected is_effect_active to return false when effect is in waiting queue, but got true")
	# entering
	scheduler._process_waiting_effects()
	assert_true(scheduler.is_effect_active(effect_instance), "Expected is_effect_active to return true when effect is in entering queue, but got false")
	# active
	scheduler._process_entering_effects()
	assert_true(scheduler.is_effect_active(effect_instance), "Expected is_effect_active to return true when effect is in active queue, but got false")
	# exiting
	assert_true(scheduler._move_active_to_exiting(scheduler.get_effect_id(effect_instance)), "Expected moving effect from active to exiting to succeed, but it failed")
	assert_true(scheduler.is_effect_active(effect_instance), "Expected is_effect_active to return true when effect is in exiting queue, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()

## test null effect

# has_effect_of_type() #

## test when there are no effects of type
func test_has_effect_of_type_when_there_are_no_effects_of_type():
	assert_false(scheduler.has_effect_of_type(Effect.Type.BUFF), "Expected has_effect_of_type to return false when there are no effects of the type, but got true")
	# adding another effect with a different type to verify
	var effect_instance = MockEffect2.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.has_effect_of_type(Effect.Type.BUFF), "Expected has_effect_of_type to return false when there are no effects of the type, but got true")
	effect_instance.free()


## test when there is one effects of type
func test_has_effect_of_type_when_there_is_one_effect_of_type():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_true(scheduler.has_effect_of_type(Effect.Type.BUFF), "Expected has_effect_of_type to return true when there is an effect of the type, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there are lots effects of type
func test_has_effect_of_type_when_there_are_lots_effects_of_type():
	var cleanup:Array = []
	for i in range(10):
		var effect_instance = MockEffect1.new()
		effect_instance.add_test_environment_data(mock_effect_data)
		scheduler.add_effect(effect_instance)
		cleanup.append(effect_instance)
	assert_true(scheduler.has_effect_of_type(Effect.Type.BUFF), "Expected has_effect_of_type to return true when there are effects of the type, but got false")
	scheduler.remove_all_effects()
	for effect_instance in cleanup:
		effect_instance.free()

# has_effect_of_name() #

## test when there are no effects of name
func test_has_effect_of_name_when_there_are_no_effects_of_name():
	assert_false(scheduler.has_effect_of_name("foo_bar"), "Expected has_effect_of_name to return false when there are no effects of the name, but got true")
	# adding another effect with a different name to verify
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.has_effect_of_name("foo_bar"), "Expected has_effect_of_name to return false when there are no effects of the name, but got true")
	effect_instance.free()

## test when there is one effects of name
func test_has_effect_of_name_when_there_is_one_effect_of_name():
	var effect_instance = MockEffect3.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_true(scheduler.has_effect_of_name("MockEffect3"), "Expected has_effect_of_name to return true when there is an effect of the name, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there are lots effects of name
func test_has_effect_of_name_when_there_are_lots_effects_of_name():
	var cleanup:Array = []
	for i in range(10):
		var effect_instance = MockEffect3.new()
		effect_instance.add_test_environment_data(mock_effect_data)
		scheduler.add_effect(effect_instance)
		cleanup.append(effect_instance)
	assert_true(scheduler.has_effect_of_name("MockEffect3"), "Expected has_effect_of_name to return true when there are effects of the name, but got false")
	scheduler.remove_all_effects()
	for effect_instance in cleanup:
		effect_instance.free()

# has_effect() #

## test when there are no effects of instance
func test_has_effect_when_there_are_no_effects_of_instance():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler.has_effect(effect_instance), "Expected has_effect to return false when there are no effects of the instance, but got true")
	# add an additional effect to verify
	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	assert_false(scheduler.has_effect(effect_instance), "Expected has_effect to return false when there are no effects of the instance, but got true")
	effect_instance.free()
	effect2.free()

## test when there is an effect of instance
func test_has_effect_when_there_is_an_effect_of_instance():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var has_effect = scheduler.has_effect(effect_instance)
	assert_true(has_effect, "Expected has_effect to return true when there is an effect of the instance, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()


## when effect is null
func test_has_effect_when_effect_is_null():
	var has_effect = scheduler.has_effect(null)
	assert_false(has_effect, "Expected has_effect to return false when effect is null, but got true")

# has_effect_with_id() #

## test when there are no effects with id
func test_has_effect_with_id_when_there_are_no_effects_with_id():
	var has_effect = scheduler.has_effect_with_id(1)
	assert_false(has_effect, "Expected has_effect_with_id to return false when there are no effects with the id, but got true")

## test when there is an effect with id
func test_has_effect_with_id_when_there_is_an_effect_with_id():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var effect_id = scheduler.get_effect_id(effect_instance)
	var has_effect = scheduler.has_effect_with_id(effect_id)
	assert_true(has_effect, "Expected has_effect_with_id to return true when there is an effect with the id, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()

# is_effect_paused() #

## test when effect is not paused
func test_is_effect_paused_when_not_paused():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	assert_false(scheduler.is_effect_paused(effect_instance), "Expected is_effect_paused to return false when effect is not paused, but got true")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect is paused
func test_is_effect_paused_when_paused():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler.pause_effect(scheduler.get_effect_id(effect_instance))
	assert_true(scheduler.is_effect_paused(effect_instance), "Expected is_effect_paused to return true when effect is paused, but got false")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect is null
func test_is_effect_paused_when_effect_is_null():
	assert_false(scheduler.is_effect_paused(null), "Expected is_effect_paused to return false when effect is null, but got true")

## effect is not in any queue
func test_is_effect_paused_when_effect_is_not_in_any_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	assert_false(scheduler.is_effect_paused(effect_instance), "Expected is_effect_paused to return false when effect is not in any queue, but got true")
	effect_instance.free()

## test when one effect is paused but not the instance being checked
func test_is_effect_paused_when_one_effect_is_paused_but_not_instance_being_checked():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	scheduler.add_effect(effect_instance2)
	scheduler.pause_effect(scheduler.get_effect_id(effect_instance1))
	assert_false(scheduler.is_effect_paused(effect_instance2), "Expected is_effect_paused to return false when a different effect is paused, but got true")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# is_scheduler_enabled() #

## test when scheduler is enabled
func test_is_scheduler_enabled_when_enabled():
	assert_true(scheduler.is_scheduler_enabled(), "Expected is_scheduler_enabled to return true when scheduler is enabled, but got false")

## test when scheduler is disabled
func test_is_scheduler_enabled_when_disabled():
	scheduler.disable_scheduler()
	assert_false(scheduler.is_scheduler_enabled(), "Expected is_scheduler_enabled to return false when scheduler is disabled, but got true")
	# verify test by adding an effect, then attempt to process it in waiting, entering, active, and exiting queues and verify it does not process
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	for i in range(5):
		scheduler._process(0.1)
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to remain in waiting queue when scheduler is disabled")
	scheduler.remove_all_effects()
	effect_instance.free()


# is_scheduler_disabled() #

## test when scheduler is enabled
func test_is_scheduler_disabled_when_enabled():
	assert_false(scheduler.is_scheduler_disabled(), "Expected is_scheduler_disabled to return false when scheduler is enabled, but got true")

## test when scheduler is disabled
func test_is_scheduler_disabled_when_disabled():
	scheduler.disable_scheduler()
	assert_true(scheduler.is_scheduler_disabled(), "Expected is_scheduler_disabled to return true when scheduler is disabled, but got false")
	# verify test by adding an effect, then attempt to process it in waiting, entering, active, and exiting queues and verify it does not process
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	for i in range(5):
		scheduler._process(0.1)
	assert_true(scheduler.is_effect_waiting(effect_instance), "Expected effect to remain in waiting queue when scheduler is disabled")
	scheduler.remove_all_effects()
	effect_instance.free()


# get_effect_id() #

## test when effect is null
func test_get_effect_id_when_effect_is_null():
	var effect_id = scheduler.get_effect_id(null)
	assert_eq(effect_id, -1, "Expected get_effect_id to return null when effect is null, but got " + str(effect_id))

## test when effect is in waiting queue
func test_get_effect_id_when_effect_is_in_waiting_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_ne(effect_id, -1, "Expected get_effect_id to return an id when effect is in waiting queue, but got " + str(effect_id))
	if effect_id != -1:
		var effect = scheduler.get_effect_by_id(effect_id)
		assert_eq(effect, effect_instance, "Expected get_effect_id to return the correct id for the effect in waiting queue, but got an id for a different effect")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect is in entering queue
func test_get_effect_id_when_effect_is_in_entering_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_ne(effect_id, -1, "Expected get_effect_id to return an id when effect is in entering queue, but got " + str(effect_id))
	if effect_id != -1:
		var effect = scheduler.get_effect_by_id(effect_id)
		assert_eq(effect, effect_instance, "Expected get_effect_id to return the correct id for the effect in entering queue, but got an id for a different effect")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect is in active queue
func test_get_effect_id_when_effect_is_in_active_queue():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_ne(effect_id, -1, "Expected get_effect_id to return an id when effect is in active queue, but got " + str(effect_id))
	if effect_id != -1:
		var effect = scheduler.get_effect_by_id(effect_id)
		assert_eq(effect, effect_instance, "Expected get_effect_id to return the correct id for the effect in active queue, but got an id for a different effect")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when effect is in exiting queue
func test_get_effect_id_when_effect_is_in_exiting_queue():
	var effect_instance = MockEffect5.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(0.05)
	scheduler.add_effect(effect_instance)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	scheduler._process_active_effects(0.1, false)
	var effect_id = scheduler.get_effect_id(effect_instance)
	assert_ne(effect_id, -1, "Expected get_effect_id to return an id when effect is in exiting queue, but got " + str(effect_id))
	if effect_id != -1:
		var effect = scheduler.get_effect_by_id(effect_id)
		assert_eq(effect, effect_instance, "Expected get_effect_id to return the correct id for the effect in exiting queue, but got an id for a different effect")
	scheduler.remove_all_effects()
	effect_instance.free()

# get_effect_id_by_type() #

## test when there are no effects of type
func test_get_effect_id_by_type_when_there_are_no_effects_of_type():
	var effect_id = scheduler.get_effect_id_by_type(Effect.Type.ENVIRONMENTAL)
	assert_eq(effect_id, -1, "Expected get_effect_id_by_type to return null when there are no effects of that type, but got " + str(effect_id))
	# add some effects and see if it still returns null
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	effect_id = scheduler.get_effect_id_by_type(Effect.Type.ENVIRONMENTAL)
	assert_eq(effect_id, -1, "Expected get_effect_id_by_type to return null when there are no effects of that type, but got " + str(effect_id))
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there is one effect of type
func test_get_effect_id_by_type_when_there_is_an_effect_of_type():
	var effect_instance = MockEffect4.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var effect_id = scheduler.get_effect_id_by_type(Effect.Type.ENVIRONMENTAL)
	assert_ne(effect_id, -1, "Expected get_effect_id_by_type to return an id when there is an effect of that type, but got " + str(effect_id))
	if effect_id != -1:
		var effect = scheduler.get_effect_by_id(effect_id)
		assert_eq(effect, effect_instance, "Expected get_effect_id_by_type to return the correct effect id when there is an effect of that type, but got an id for a different effect")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there are multiple effects of type
func test_get_effect_id_by_type_when_there_are_multiple_effects_of_type():
	var effect_instance1 = MockEffect4.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	var effect_instance2 = MockEffect7.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance2)
	var effect_id = scheduler.get_effect_id_by_type(Effect.Type.ENVIRONMENTAL)
	assert_ne(effect_id, -1, "Expected get_effect_id_by_type to return an id when there are multiple effects of that type, but got " + str(effect_id))
	if effect_id != -1:
		var effect = scheduler.get_effect_by_id(effect_id)
		assert_true(effect == effect_instance1 or effect == effect_instance2, "Expected get_effect_id_by_type to return the id of one of the effects when there are multiple effects of that type, but got an id for a different effect")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# get_effect_id_by_name() #

## test when there are no effects of name
func test_get_effect_id_by_name_when_there_are_no_effects_of_name():
	var effect_id = scheduler.get_effect_id_by_name("NonExistentEffectName")
	assert_eq(effect_id, -1, "Expected get_effect_id_by_name to return null when there are no effects of that name, but got " + str(effect_id))
	# add some effects and see if it still returns null
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	effect_id = scheduler.get_effect_id_by_name("NonExistentEffectName")
	assert_eq(effect_id, -1, "Expected get_effect_id_by_name to return null when there are no effects of that name, but got " + str(effect_id))
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there is one effect of name
func test_get_effect_id_by_name_when_there_is_an_effect_of_name():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var effect_id = scheduler.get_effect_id_by_name("MockEffect1")
	assert_ne(effect_id, -1, "Expected get_effect_id_by_name to return an id when there is an effect of that name, but got " + str(effect_id))
	if effect_id != -1:
		var effect = scheduler.get_effect_by_id(effect_id)
		assert_eq(effect, effect_instance, "Expected get_effect_id_by_name to return the correct effect id when there is an effect of that name, but got an id for a different effect")
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there are multiple effects of name
func test_get_effect_id_by_name_when_there_are_multiple_effects_of_name():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance2)
	var effect_id = scheduler.get_effect_id_by_name("MockEffect1")
	assert_ne(effect_id, -1, "Expected get_effect_id_by_name to return an id when there are multiple effects of that name, but got " + str(effect_id))
	if effect_id != -1:
		var effect = scheduler.get_effect_by_id(effect_id)
		assert_true(effect == effect_instance1 or effect == effect_instance2, "Expected get_effect_id_by_name to return the id of one of the effects when there are multiple effects of that name, but got an id for a different effect")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# get_effect_by_id() #

## test when there are no effects with id
func test_get_effect_by_id_when_there_are_no_effects_with_id():
	var effect = scheduler.get_effect_by_id(99) # using a random id that is unlikely to be used
	assert_null(effect, "Expected get_effect_by_id to return null when there are no effects with that id, but got " + str(effect))

## test when there is an effect with id
func test_get_effect_by_id_when_there_is_an_effect_with_id():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var effect_id = scheduler.get_effect_id(effect_instance)
	var effect = scheduler.get_effect_by_id(effect_id)
	assert_not_null(effect, "Expected get_effect_by_id to return an effect when there is an effect with that id, but got null")
	if effect != null:
		assert_eq(effect, effect_instance, "Expected get_effect_by_id to return the correct effect when there is an effect with that id, but got " + str(effect))
	scheduler.remove_all_effects()
	effect_instance.free()

# get_effect_by_type() #

## test when there are no effects of type
func test_when_getting_effect_by_type_and_there_are_no_effects_of_that_type():
	var effect = scheduler.get_effect_by_type(Effect.Type.ENVIRONMENTAL)
	assert_null(effect, "Expected get_effect_by_type to return null when there are no effects of that type, but got " + str(effect))
	# add some effects and see if it still returns null
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	effect = scheduler.get_effect_by_type(Effect.Type.ENVIRONMENTAL)
	assert_null(effect, "Expected get_effect_by_type to return null when there are no effects of that type, but got " + str(effect))
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there is one effect of type
func test_when_getting_effect_by_type_and_there_is_one_effect_of_that_type():
	var effect_instance = MockEffect4.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var effect = scheduler.get_effect_by_type(Effect.Type.ENVIRONMENTAL)
	assert_not_null(effect, "Expected get_effect_by_type to return an effect when there is an effect of that type, but got null")
	if effect != null:
		assert_eq(effect, effect_instance, "Expected get_effect_by_type to return the correct effect when there is an effect of that type, but got " + str(effect))
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there are multiple effects of type
func test_when_getting_effect_by_type_and_there_are_multiple_effects_of_that_type():
	var effect_instance1 = MockEffect4.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	var effect_instance2 = MockEffect7.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance2)
	var effect_instance3 = MockEffect1.new()
	effect_instance3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance3)
	var effect = scheduler.get_effect_by_type(Effect.Type.ENVIRONMENTAL)
	assert_not_null(effect, "Expected get_effect_by_type to return an effect when there are multiple effects of that type, but got null")
	if effect != null:
		assert_true(effect == effect_instance1 or effect == effect_instance2, "Expected get_effect_by_type to return one of the correct effects when there are multiple effects of that type, but got " + str(effect))
		assert_false(effect == effect_instance3, "Expected get_effect_by_type to exclude non-matching effect when there are multiple effects of that type, but it was included")
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()
	effect_instance3.free()

# get_effects_by_type() #

## test when there are no effects of type
func test_when_getting_effects_by_type_and_there_are_no_effects_of_that_type():
	var effects = scheduler.get_effects_by_type(Effect.Type.ENVIRONMENTAL)
	assert_eq(effects.size(), 0, "Expected get_effects_by_type to return an empty array when there are no effects of that type, but got an array of size " + str(effects.size()))
	# add some effects and see if it still returns an empty array
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	effects = scheduler.get_effects_by_type(Effect.Type.ENVIRONMENTAL)
	assert_eq(effects.size(), 0, "Expected get_effects_by_type to return an empty array when there are no effects of that type, but got an array of size " + str(effects.size()))
	scheduler.remove_all_effects()
	effect.free()

## test when there are some effects of type
func test_when_getting_effects_by_type_and_there_are_some_effects_of_that_type():
	var effect1 = MockEffect4.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect7.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var effect3 = MockEffect1.new()
	effect3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect3)
	var effects = scheduler.get_effects_by_type(Effect.Type.ENVIRONMENTAL)
	assert_eq(effects.size(), 2, "Expected get_effects_by_type to return an array of size 2 when there are 2 effects of that type, but got an array of size " + str(effects.size()))
	assert_true(effects.has(effect1), "Expected get_effects_by_type results to include effect1, but it did not")
	assert_true(effects.has(effect2), "Expected get_effects_by_type results to include effect2, but it did not")
	assert_false(effects.has(effect3), "Expected get_effects_by_type results to exclude non-matching effect3, but it was included")
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()
	effect3.free()

# get_effect_by_name() #

## test when there are no effects of name
func test_when_getting_effect_by_name_and_there_are_no_effects_of_that_name():
	var effect = scheduler.get_effect_by_name("NonExistentEffectName")
	assert_null(effect, "Expected get_effect_by_name to return null when there are no effects of that name, but got " + str(effect))
	# add some effects and see if it still returns null
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	effect = scheduler.get_effect_by_name("NonExistentEffectName")
	assert_null(effect, "Expected get_effect_by_name to return null when there are no effects of that name, but got " + str(effect))
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there is one effect of name
func test_when_getting_effect_by_name_and_there_is_one_effect_of_that_name():
	var effect_instance = MockEffect1.new()
	effect_instance.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance)
	var effect = scheduler.get_effect_by_name("MockEffect1")
	assert_not_null(effect, "Expected get_effect_by_name to return an effect when there is an effect of that name, but got null")
	if effect != null:
		assert_eq(effect, effect_instance, "Expected get_effect_by_name to return the correct effect when there is an effect of that name, but got " + str(effect))
	scheduler.remove_all_effects()
	effect_instance.free()

## test when there are multiple effects of name
func test_when_getting_effect_by_name_and_there_are_multiple_effects_of_that_name():
	var effect_instance1 = MockEffect1.new()
	effect_instance1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance1)
	var effect_instance2 = MockEffect1.new()
	effect_instance2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect_instance2)
	var effect = scheduler.get_effect_by_name("MockEffect1")
	assert_not_null(effect, "Expected get_effect_by_name to return an effect when there are multiple effects of that name, but got null")
	if effect != null:
		assert_true(effect == effect_instance1 or effect == effect_instance2, "Expected get_effect_by_name to return one of the correct effects when there are multiple effects of that name, but got " + str(effect))
	scheduler.remove_all_effects()
	effect_instance1.free()
	effect_instance2.free()

# get_effects_by_name() #

## test when there are no effects of name
func test_when_getting_effects_by_name_and_there_are_no_effects_of_that_name():
	var effects = scheduler.get_effects_by_name("NonExistentEffectName")
	assert_eq(effects.size(), 0, "Expected get_effects_by_name to return an empty array when there are no effects of that name, but got an array of size " + str(effects.size()))
	# add some effects and see if it still returns an empty array
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	effects = scheduler.get_effects_by_name("NonExistentEffectName")
	assert_eq(effects.size(), 0, "Expected get_effects_by_name to return an empty array when there are no effects of that name, but got an array of size " + str(effects.size()))
	scheduler.remove_all_effects()
	effect.free()

## test when there are some effects of name
func test_when_getting_effects_by_name_and_there_are_some_effects_of_that_name():
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var effect3 = MockEffect11.new()
	effect3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect3)
	var effects = scheduler.get_effects_by_name("MockEffect1")
	assert_eq(effects.size(), 2, "Expected get_effects_by_name to return an array of size 2 when there are 2 effects of that name, but got an array of size " + str(effects.size()))
	assert_true(effects.has(effect1), "Expected get_effects_by_name results to include effect1, but it did not")
	assert_true(effects.has(effect2), "Expected get_effects_by_name results to include effect2, but it did not")
	assert_false(effects.has(effect3), "Expected get_effects_by_name results to exclude non-matching effect3, but it was included")
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()
	effect3.free()

# _get_effect_record() #

## test when there are no specific records of that instance
func test_when_there_are_no_specific_records_of_that_instance():
	var effect_1 = MockEffect1.new()
	var record = scheduler._get_effect_record(effect_1)
	assert_null(record, "Expected _get_effect_record to return null when there are no records of that instance, but got " + str(record))
	effect_1.free()
	# insert a record of a different instance to make sure it still returns null
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	var effect_2 = MockEffect1.new()
	record = scheduler._get_effect_record(effect_2)
	assert_null(record, "Expected _get_effect_record to return null when there are no records of that instance, but got " + str(record))
	effect_2.free()
	scheduler.remove_all_effects()
	effect.free()

## test when there is a specific record of that instance
func test_when_there_is_a_specific_record_of_that_instance():
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	var record = scheduler._get_effect_record(effect)
	assert_not_null(record, "Expected _get_effect_record to return a record when there is a record of that instance, but got null")
	if record != null and record.effect != null:
		assert_eq(record.effect, effect, "Expected _get_effect_record to return a record with the correct effect when there is a record of that instance, but got " + str(record.effect))
	scheduler.remove_all_effects()
	effect.free()

## test when effect is null
func test_when_effect_is_null():
	var record = scheduler._get_effect_record(null)
	assert_null(record, "Expected _get_effect_record to return null when effect is null, but got " + str(record))

# get_effect_record_by_id() #

## test when there are no records with id
func test_when_there_are_no_records_with_id():
	var record = scheduler.get_effect_record_by_id(23)
	assert_null(record, "Expected get_effect_record_by_id to return null when there are no records with that id, but got " + str(record))

## test when there is a record with id
func test_when_there_is_a_record_with_id():
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	var id = scheduler.get_effect_id(effect)
	var record = scheduler.get_effect_record_by_id(id)
	assert_not_null(record, "Expected get_effect_record_by_id to return a record when there is a record with that id, but got null")
	if record != null and record.effect != null:
		assert_eq(record.effect, effect, "Expected get_effect_record_by_id to return a record with the correct effect when there is a record with that id, but got " + str(record.effect))
	scheduler.remove_all_effects()
	effect.free()

# get_effect_record_by_instance() #

## test when there are no records of that instance
func test_when_there_is_no_record_of_that_instance():
	var effect_1 = MockEffect1.new()
	var record = scheduler.get_effect_record_by_instance(effect_1)
	assert_null(record, "Expected get_effect_record_by_instance to return null when there are no records of that instance, but got " + str(record))
	effect_1.free()
	# insert a record of a different instance to make sure it still returns null
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	var effect_2 = MockEffect1.new()
	record = scheduler.get_effect_record_by_instance(effect_2)
	assert_null(record, "Expected get_effect_record_by_instance to return null when there are no records of that instance, but got " + str(record))
	effect_2.free()
	scheduler.remove_all_effects()
	effect.free()

## test when there is a record of that instance
func test_when_there_is_a_record_of_that_instance():
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	var record = scheduler.get_effect_record_by_instance(effect)
	assert_not_null(record, "Expected get_effect_record_by_instance to return a record when there is a record of that instance, but got null")
	if record != null and record.effect != null:
		assert_eq(record.effect, effect, "Expected get_effect_record_by_instance to return a record with the correct effect when there is a record of that instance, but got " + str(record.effect))
	# adding another effect of the same type to make sure it gets the correct one
	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	record = scheduler.get_effect_record_by_instance(effect)
	assert_not_null(record, "Expected get_effect_record_by_instance to return a record when there is a record of that instance, but got null")
	if record != null and record.effect != null:
		assert_eq(record.effect, effect, "Expected get_effect_record_by_instance to return a record with the correct effect when there is a record of that instance, but got " + str(record.effect))
	
	scheduler.remove_all_effects()
	effect.free()
	effect2.free()

# get_effect_record_by_name() #

## test when there are no records of that name
func test_when_there_are_no_records_of_that_name():
	var record = scheduler.get_effect_record_by_name("NonExistentEffectName")
	assert_null(record, "Expected get_effect_record_by_name to return null when there are no records of that name, but got " + str(record))
	# insert a couple records of different names to make sure it still returns null
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect2.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	record = scheduler.get_effect_record_by_name("NonExistentEffectName")
	assert_null(record, "Expected get_effect_record_by_name to return null when there are no records of that name, but got " + str(record))
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()

## test when there is a record of that name
func test_when_there_is_a_record_of_that_name():
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var record = scheduler.get_effect_record_by_name("MockEffect1")
	assert_not_null(record, "Expected get_effect_record_by_name to return a record when there is a record of that name, but got null")
	if record != null and record.effect != null:
		assert_eq(record.effect.get_effect_name(), "MockEffect1", "Expected get_effect_record_by_name to return a record with the correct effect when there is a record of that name, but got " + str(record.effect.get_effect_name()))
	# add extra effect to confirm it gets the correct one
	var effect2 = MockEffect2.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	record = scheduler.get_effect_record_by_name("MockEffect1")
	assert_not_null(record, "Expected get_effect_record_by_name to return a record when there is a record of that name, but got null")
	if record != null and record.effect != null:
		assert_eq(record.effect.get_effect_name(), "MockEffect1", "Expected get_effect_record_by_name to return a record with the correct effect when there is a record of that name, but got " + str(record.effect.get_effect_name()))
	# should still return 1
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()

## test when there is more than one record of that name
func test_when_there_are_multiple_records_of_that_name():
	# 3 records of the same name, 2 other completely different records
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var effect3 = MockEffect1.new()
	effect3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect3)
	var effect4 = MockEffect2.new()
	effect4.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect4)
	var effect5 = MockEffect3.new()
	effect5.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect5)
	var record = scheduler.get_effect_record_by_name("MockEffect1")
	assert_not_null(record, "Expected get_effect_record_by_name to return a record when there are records of that name, but got null")
	if record != null and record.effect != null:
		assert_eq(record.effect.get_effect_name(), "MockEffect1", "Expected get_effect_record_by_name to return a record with the correct effect when there are records of that name, but got " + str(record.effect.get_effect_name()))
	# should still return 1
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()
	effect3.free()
	effect4.free()
	effect5.free()


# get_all_records_by_type() #

## test when there are no records of that type
func test_when_there_are_no_records_of_that_type():
	var records = scheduler.get_all_records_by_type(Effect.Type.OBJECT)
	assert_eq(records.size(), 0, "Expected get_all_records_by_type to return an empty array when there are no records of that type, but got " + str(records.size()))

## test when there is one record of that type
func test_when_there_is_one_record_of_that_type():
	var effect1 = MockEffect5.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var records = scheduler.get_all_records_by_type(Effect.Type.OBJECT)
	assert_eq(records.size(), 1, "Expected get_all_records_by_type to return an array of size 1 when there is 1 record of that type, but got " + str(records.size()))
	scheduler.remove_all_effects()
	effect1.free()

## test when there are some records of that type
func test_when_there_are_some_records_of_that_type():
	var effect1 = MockEffect5.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect5.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var records = scheduler.get_all_records_by_type(Effect.Type.OBJECT)
	assert_eq(records.size(), 2, "Expected get_all_records_by_type to return an array of size 2 when there are 2 records of that type, but got " + str(records.size()))
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()

# get_all_records_by_name() #

## test when there are no records of that name
func test_looking_for_all_names_when_there_are_no_records_of_that_name():
	var records = scheduler.get_all_records_by_name("NonExistentEffectName")
	assert_eq(records.size(), 0, "Expected get_all_records_by_name to return an empty array when there are no records of that name, but got " + str(records.size()))

## test when there is one record of that name
func test_looking_for_all_names_when_there_is_one_record_of_that_name():
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var records = scheduler.get_all_records_by_name("MockEffect1")
	assert_eq(records.size(), 1, "Expected get_all_records_by_name to return an array of size 1 when there is 1 record of that name, but got " + str(records.size()))
	scheduler.remove_all_effects()
	effect1.free()

## test when there are some records of that name
func test_looking_for_all_names_when_there_are_some_records_of_that_name():
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var records = scheduler.get_all_records_by_name("MockEffect1")
	assert_eq(records.size(), 2, "Expected get_all_records_by_name to return an array of size 2 when there are 2 records of that name, but got " + str(records.size()))
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()


# get_all_persistent_records() #

## test when there are no persistent records
func test_when_there_are_no_persistent_records():
	var records = scheduler.get_all_persistent_records()
	assert_eq(records.size(), 0, "Expected get_all_persistent_records to return an empty array when there are no persistent records, but got " + str(records.size()))
	# add mock1 which is not persistent
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	records = scheduler.get_all_persistent_records()
	assert_eq(records.size(), 0, "Expected get_all_persistent_records to return an empty array when there are no persistent records, but got " + str(records.size()))
	scheduler.remove_all_effects()
	effect1.free()


## test when there are some persistent records
func test_when_there_are_some_persistent_records():
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect3.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var records = scheduler.get_all_persistent_records()
	assert_eq(records.size(), 1, "Expected get_all_persistent_records to return an array of size 1 when there is 1 persistent record, but got " + str(records.size()))
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()

# get_all_unique_records() #

## test when there are no unique records
func test_when_there_are_no_unique_records():
	var records = scheduler.get_all_unique_records()
	assert_eq(records.size(), 0, "Expected get_all_unique_records to return an empty array when there are no unique records, but got " + str(records.size()))

## test when there are some unique records
func test_when_there_are_some_unique_records():
	var effect1 = MockEffect4.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect2.new()
	effect2.set_unique(true)
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var effect3 = MockEffect1.new()
	effect3.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect3)
	var records = scheduler.get_all_unique_records()
	assert_eq(records.size(), 2, "Expected get_all_unique_records to return an array of size 2 when there are 2 unique records, but got " + str(records.size()))
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()
	effect3.free()

# get_all_records() #

## test when there are no records
func test_when_there_are_no_records():
	var records = scheduler.get_all_records()
	assert_eq(records.size(), 0, "Expected get_all_records to return an empty array when there are no records, but got " + str(records.size()))

## test when there are some records
func test_when_there_are_some_records():
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var effect2 = MockEffect2.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var records = scheduler.get_all_records()
	assert_eq(records.size(), 2, "Expected get_all_records to return an array of size 2 when there are 2 records, but got " + str(records.size()))
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()

# _allocate_effect_id() #

## test that generated id is unique
func test_that_generated_id_is_unique():
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect1)
	var id1 = scheduler.get_effect_id(effect1)

	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect2)
	var id2 = scheduler.get_effect_id(effect2)

	assert_ne(id1, id2, "Expected generated ids to be unique, but got duplicate ids: " + str(id1))
	scheduler.remove_all_effects()
	effect1.free()
	effect2.free()

## test the maximum id limit and that it wraps around correctly
func test_the_maximum_id_limit_and_that_it_wraps_around_correctly():
	var generated_ids = []
	# generate ids until we reach the maximum limit
	for i in range(scheduler._effect_id_max):
		var id = scheduler.get_id_next_available()
		scheduler._register_effect_id(id)
		generated_ids.append(id)
	
	# now that all ids are registered, multiple will be freed
	scheduler._recycle_effect_id(3)
	scheduler._recycle_effect_id(15)
	scheduler._recycle_effect_id(77)
	scheduler._recycle_effect_id(19)
	scheduler._recycle_effect_id(26)
	assert_has(scheduler._free_effect_ids, 3, "Expected recycled id 3 to be in free_effect_ids, but it is not")
	assert_has(scheduler._free_effect_ids, 15, "Expected recycled id 15 to be in free_effect_ids, but it is not")
	assert_has(scheduler._free_effect_ids, 77, "Expected recycled id 77 to be in free_effect_ids, but it is not")
	assert_has(scheduler._free_effect_ids, 19, "Expected recycled id 19 to be in free_effect_ids, but it is not")
	assert_has(scheduler._free_effect_ids, 26, "Expected recycled id 26 to be in free_effect_ids, but it is not")
	

## test that there is no collision in generated ids
func test_that_there_is_no_collision_in_generated_ids():
	# register two ids
	var id_a = scheduler.get_id_next_available()
	scheduler._register_effect_id(id_a)
	var id_b = scheduler.get_id_next_available()
	scheduler._register_effect_id(id_b)
	assert_ne(id_a, id_b, "Expected two generated ids to be distinct, but got duplicates: " + str(id_a))
	# recycle the first id and verify it can be re-registered without colliding with the second
	scheduler._recycle_effect_id(id_a)
	assert_true(scheduler._register_effect_id(id_a), "Expected to re-register recycled id " + str(id_a) + " without collision, but registration failed")
	assert_true(scheduler.is_effect_id_in_use(id_b), "Expected id " + str(id_b) + " to still be in use after recycling id " + str(id_a) + ", but it is not")
	# cleanup
	scheduler._recycle_effect_id(id_a)
	scheduler._recycle_effect_id(id_b)
	
## test when max id limit is reached and all ids are in use
func test_when_max_id_limit_is_reached_and_all_ids_are_in_use():
	# generate ids until we reach the maximum limit
	for i in range(scheduler._effect_id_max):
		var id = scheduler.get_id_next_available()
		scheduler._register_effect_id(id)
	
	# now that all ids are registered, attempt to get another id which should fail
	var new_id = scheduler.get_id_next_available()
	assert_eq(new_id, -1, "Expected get_next_available_effect_id to return -1 when max id limit is reached and all ids are in use, but got " + str(new_id))
	

## test adding an effect with a reserved id
func test_adding_an_effect_with_a_reserved_id():
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	var reserved_id = 42
	scheduler._register_effect_id(reserved_id)
	# attempt to add an effect with the reserved id
	var result = scheduler.add_effect(effect, reserved_id)
	assert_false(result, "Expected adding an effect with a reserved id " + str(reserved_id) + " to fail, but it succeeded")
	effect.free()

## test adding an effect with a reserved id that is already in use
func test_adding_an_effect_with_a_reserved_id_that_is_already_in_use():
	var effect1 = MockEffect1.new()
	effect1.add_test_environment_data(mock_effect_data)
	var effect2 = MockEffect1.new()
	effect2.add_test_environment_data(mock_effect_data)
	var reserved_id = 42
	scheduler._register_effect_id(reserved_id)
	# add first effect with reserved id
	var result1 = scheduler.add_effect(effect1, reserved_id)
	assert_false(result1, "Expected adding the first effect with a reserved id " + str(reserved_id) + " to fail, but it succeeded")
	# add second effect with same reserved id
	var result2 = scheduler.add_effect(effect2, reserved_id)
	assert_false(result2, "Expected adding the second effect with a reserved id " + str(reserved_id) + " to fail, but it succeeded")
	effect1.free()
	effect2.free()

## test adding an effect with a reserved id when waiting queue limit has been reached
func test_adding_an_effect_with_a_reserved_id_when_waiting_queue_limit_has_been_reached():
	var effect = MockEffect1.new()
	var effects:Array[Effect] = []
	effect.add_test_environment_data(mock_effect_data)
	var reserved_id = 42
	scheduler._register_effect_id(reserved_id)
	# fill waiting queue to its limit
	for i in range(scheduler.max_queue_size):
		var temp_effect = MockEffect1.new()
		temp_effect.add_test_environment_data(mock_effect_data)
		effects.append(temp_effect)
		scheduler.add_effect(temp_effect)
	# now attempt to add an effect with a reserved id which should fail due to waiting queue limit
	var result = scheduler.add_effect(effect, reserved_id)
	assert_false(result, "Expected adding an effect with a reserved id " + str(reserved_id) + " to fail when waiting queue limit is reached, but it succeeded")
	# cleanup
	effect.free()
	for temp in effects:
		temp.free()
	


# _recycle_effect_id() #

## test releasing an id that is not in use
func test_releasing_an_id_that_is_not_in_use():
	var id = 0
	assert_false(scheduler._recycle_effect_id(id), "Expected recycling id " + str(id) + " to fail since it is not in use, but it succeeded")

## test releasing an id that is in use and then reusing it
func test_releasing_an_id_that_is_in_use_and_then_reusing_it():
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	var id = scheduler.get_effect_id(effect)
	assert_true(scheduler._recycle_effect_id(id), "Expected recycling id " + str(id) + " to succeed since it is in use, but it failed")
	# then test that the id is reusable
	var new_id = scheduler._allocate_effect_id()
	assert_eq(id, new_id, "Expected allocated id to be the same as recycled id " + str(id) + ", but got " + str(new_id))
	scheduler.remove_all_effects()
	effect.free()

## test releasing an id that is in use and then generating a new id to see if the released id is reused
func test_releasing_an_id_that_is_in_use_and_then_generating_a_new_id_to_see_if_released_id_is_reused():
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	var id = scheduler.get_effect_id(effect)
	assert_true(scheduler._recycle_effect_id(id), "Expected recycling id " + str(id) + " to succeed since it is in use, but it failed")
	# then test that the id is reusable
	var new_id = scheduler._allocate_effect_id()
	assert_eq(id, new_id, "Expected allocated id to be the same as recycled id " + str(id) + ", but got " + str(new_id))
	scheduler.remove_all_effects()
	effect.free()

## test releasing an id that is in use and then generating a new id to see if the released id is reused when there are many ids in use
func test_releasing_and_reusing_an_id_when_there_are_many_ids_in_use():
	var effects = []
	var ids = []
	# add effects until we have a good number of ids in use
	for i in range(50):
		var effect = MockEffect1.new()
		effect.add_test_environment_data(mock_effect_data)
		scheduler.add_effect(effect)
		effects.append(effect)
		ids.append(scheduler.get_effect_id(effect))
	
	# recycle the id of the 25th effect
	var id_to_recycle = ids[24]
	assert_true(scheduler._recycle_effect_id(id_to_recycle), "Expected recycling id " + str(id_to_recycle) + " to succeed since it is in use, but it failed")
	
	# then test that the recycled id is reused
	var new_id = scheduler._allocate_effect_id()
	assert_eq(id_to_recycle, new_id, "Expected allocated id to be the same as recycled id " + str(id_to_recycle) + ", but got " + str(new_id))
	
	# cleanup
	scheduler.remove_all_effects()
	for effect in effects:
		effect.free()

# _remove_effect_from_scheduler() #

## test removing an effect that is not in any queue
func test_removing_an_effect_that_is_not_in_any_queue():
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	assert_false(scheduler._remove_effect_from_scheduler(scheduler.get_effect_id(effect)), "Expected removing an effect that is not in any queue to fail, but it succeeded")
	# verify that effect was actually removed with queries
	assert_false(scheduler.has_effect(effect), "Expected effect to not be in scheduler after removal, but it is")	
	scheduler.remove_all_effects()
	effect.free()

## test removing an effect that is in waiting queue
func test_removing_an_effect_that_is_in_waiting_queue():
	var effect = MockEffect1.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	assert_true(scheduler._remove_effect_from_scheduler(scheduler.get_effect_id(effect)), "Expected removing an effect that is in waiting queue to succeed, but it failed")
	# verify that effect was actually removed with queries
	assert_false(scheduler.has_effect(effect), "Expected effect to not be in scheduler after removal, but it is")
	scheduler.remove_all_effects()
	effect.free()

## test removing an effect that is in entering queue
func test_removing_an_effect_that_is_in_entering_queue():
	var effect = MockEffect2.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	scheduler._process_waiting_effects()
	# verifying that effect is waiting inside entering queue
	assert_true(scheduler.get_effect_record_by_instance(effect).is_entering, "Expected effect to be in entering queue, but it is not")
	# attempt removal
	assert_true(scheduler._remove_effect_from_scheduler(scheduler.get_effect_id(effect)), "Expected removing an effect that is in entering queue to succeed, but it failed")
	# verify that effect was removed with queries
	assert_false(scheduler.has_effect(effect), "Expected effect to not be in scheduler after removal, but it is")
	scheduler.remove_all_effects()
	effect.free()

## test removing an effect that is in active queue
func test_removing_an_effect_that_is_in_active_queue():
	var effect = MockEffect3.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	# verifying that effect is waiting inside active queue
	assert_true(scheduler.get_effect_record_by_instance(effect).is_active, "Expected effect to be in active queue, but it is not")
	# attempt removal
	assert_true(scheduler._remove_effect_from_scheduler(scheduler.get_effect_id(effect)), "Expected removing an effect that is in active queue to succeed, but it failed")
	# verify that effect was removed with queries
	assert_false(scheduler.has_effect(effect), "Expected effect to not be in scheduler after removal, but it is")
	scheduler.remove_all_effects()
	effect.free()

## test removing an effect that is in exiting queue
func test_removing_an_effect_that_is_in_exiting_queue():
	var effect = MockEffect4.new()
	effect.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(effect)
	scheduler._process_waiting_effects()
	scheduler._process_entering_effects()
	# MockEffect4 has no natural stop condition, so force transition for this queue-removal test.
	assert_true(scheduler._move_active_to_exiting(scheduler.get_effect_id(effect)), "Expected moving effect from active to exiting to succeed, but it failed")
	# verifying that effect is waiting inside exiting queue
	assert_true(scheduler.get_effect_record_by_instance(effect).is_exiting, "Expected effect to be in exiting queue, but it is not")
	# attempt removal
	assert_true(scheduler._remove_effect_from_scheduler(scheduler.get_effect_id(effect)), "Expected removing an effect that is in exiting queue to succeed, but it failed")
	# verify that effect was removed with queries
	assert_false(scheduler.has_effect(effect), "Expected effect to not be in scheduler after removal, but it is")
	# cleanup
	scheduler.remove_all_effects()
	effect.free()


## test that the effect is removed correctly and that its id is released

# reserve_effect_id() #

## test reserving a specific id
func test_reserving_a_specific_id():
	assert_true(scheduler.reserve_effect_id(0), "Expected reserving id 0 to succeed, but it failed")
	scheduler.unreserve_effect_id(0)

## test reserving the maximum valid id
func test_reserving_the_maximum_valid_id():
	var max_id = scheduler._effect_id_max
	assert_true(scheduler.reserve_effect_id(max_id - 1), "Expected reserving id " + str(max_id) + " to succeed, but it failed")
	scheduler.unreserve_effect_id(max_id - 1)
	# then test the maximum itself
	assert_false(scheduler.reserve_effect_id(max_id), "Expected reserving id " + str(max_id) + " to fail since it is the maximum and should be invalid, but it succeeded")

## test reserving an id when there are no available ids
func test_reserving_an_id_when_there_are_no_available_ids():
	# reserve all valid ids
	for i in range(scheduler._effect_id_max):
		scheduler.reserve_effect_id(i)
	# attempt to reserve another id
	assert_false(scheduler.reserve_effect_id(0), "Expected reserving id 0 to fail since there are no available ids, but it succeeded")
	# unreserve all ids for next tests
	for i in range(scheduler._effect_id_max):
		scheduler.unreserve_effect_id(i)

# unreserve_effect_id() #

## test unreserving an id that is not reserved
func test_unreserving_an_id_that_is_not_reserved():
	assert_false(scheduler.unreserve_effect_id(0), "Expected unreserving id 0 to fail since it is not reserved, but it succeeded???")

## test unreserving an id that is reserved
func test_unreserving_an_id_that_is_reserved():
	scheduler.reserve_effect_id(0)
	assert_true(scheduler.unreserve_effect_id(0), "Expected unreserving id 0 to succeed since it is reserved, but it failed")

## test unreserving an id that is reserved and then reserving it again to see if it works
func test_unreserving_an_id_that_is_reserved_and_then_reserving_it_again():
	scheduler.reserve_effect_id(0)
	assert_true(scheduler.unreserve_effect_id(0), "Expected unreserving id 0 to succeed since it is reserved, but it failed")
	assert_true(scheduler.reserve_effect_id(0), "Expected reserving id 0 to succeed since it was just unreserved, but it failed")
	scheduler.unreserve_effect_id(0) # clean up for next test

# is_effect_id_reserved() #

## test checking if an id is reserved when it is not reserved
func test_checking_if_an_id_is_reserved_when_it_is_not_reserved():
	assert_false(scheduler.is_effect_id_reserved(0), "Expected id 0 to not be reserved, but it is")

## test checking if an id is reserved when it is reserved
func test_checking_if_an_id_is_reserved_when_it_is_reserved():
	scheduler.reserve_effect_id(0)
	assert_true(scheduler.is_effect_id_reserved(0), "Expected id 0 to be reserved, but it is not")
	scheduler.unreserve_effect_id(0) # unreserve id for next test

# get_id_next_available() #

## test when recycled ids are available and it returns one without consuming it
func test_when_recycled_ids_are_available_and_it_returns_one_without_consuming_it():
	scheduler._register_effect_id(0)
	scheduler._recycle_effect_id(0)
	var result = scheduler.get_id_next_available()
	assert_eq(result, 0, "Expected to get recycled id 0, but got " + str(result))
	result = scheduler.get_id_next_available()
	assert_eq(result, 0, "Expected to get recycled id 0 again since it should not have been consumed, but got " + str(result))
	

## test when given an invalid id
func test_when_given_an_invalid_id():
	assert_false(scheduler.is_effect_id_reserved(-1), "Expected id -1 to be invalid and not reserved, but it is reserved")
	assert_false(scheduler.is_effect_id_reserved(scheduler._effect_id_max + 1), "Expected id " + str(scheduler._effect_id_max + 1) + " to be invalid and not reserved, but it is reserved")

## test when all allocatable ids are unavailable
func test_when_all_allocatable_ids_are_unavailable():
	# reserve all ids
	for i in range(scheduler._effect_id_max + 1):
		scheduler.reserve_effect_id(i)
	# check that there are no available ids
	var result = scheduler.get_id_next_available()
	assert_eq(result, -1, "Expected to get -1 when all ids are unavailable, but got " + str(result))
	# unreserve all ids for next tests
	for i in range(scheduler._effect_id_max + 1):
		scheduler.unreserve_effect_id(i)


# _register_effect_id() #

## test registering a valid available id
func test_register_effect_id_valid_available_id():
	# attempt to register multiple ids
	var result = scheduler._register_effect_id(0)
	assert_true(result, "Expected to register id " + str(result) + ", but got False")
	scheduler._recycle_effect_id(0) # recycle id for next test

## Test registering multiple valid available ids
func test_register_effect_id_valid_available_id_multiple():
	for i in range(10):
		var result = scheduler._register_effect_id(i)
		assert_true(result, "Expected to register id " + str(i) + ", but got False")
		scheduler._recycle_effect_id(i) # recycle id for next test

## test registering an invalid id
func test_registering_an_invalid_id():
	var result = scheduler._register_effect_id(-1)
	assert_false(result, "Expected to fail registering id -1, but got True")
	result = scheduler._register_effect_id(scheduler._effect_id_max + 1)
	assert_false(result, "Expected to fail registering id " + str(scheduler._effect_id_max + 1) + ", but got True")

## test registering an id that is already reserved
func test_registering_an_id_that_is_already_reserved():
	scheduler.reserve_effect_id(0) # reserve id 0
	var result = scheduler._register_effect_id(0)
	assert_false(result, "Expected to fail registering reserved id 0, but got True")
	scheduler.unreserve_effect_id(0) # unreserve id for next test

## test registering an id that is already in use but not reserved
func test_registering_an_id_that_is_already_in_use():
	# register an id normally
	var result = scheduler._register_effect_id(0)
	assert_true(result, "Expected to register id 0, but got False")
	# attempt to reserve the same id
	scheduler.reserve_effect_id(0)
	# attempt to register the same id again
	result = scheduler._register_effect_id(0)
	assert_false(result, "Expected to fail registering id 0 that is already in use, but got True")
	# clean up by unreserving and recycling the id
	scheduler.unreserve_effect_id(0)
	scheduler._recycle_effect_id(0)

# unregister_effect_id() #

## test unregistering an id that is currently in use
func test_unregistering_an_id_that_is_currently_in_use():
	# register an id normally
	scheduler._register_effect_id(0)
	assert_true(scheduler.is_effect_id_in_use(0), "Expected id 0 to be in use, but it is not")
	# unregister the id
	assert_true(scheduler._recycle_effect_id(0), "Expected to unregister id 0 successfully, but got False")
	assert_false(scheduler.is_effect_id_in_use(0), "Expected id 0 to not be in use after unregistering, but it is still in use")

## test unregistering an id that is not in use
func test_unregistering_an_id_that_is_not_in_use():
	# ensure id is not in use
	assert_false(scheduler.is_effect_id_in_use(0), "Expected id 0 to not be in use, but it is")
	# attempt to unregister the id
	assert_false(scheduler._recycle_effect_id(0), "Expected to fail unregistering id 0 that is not in use, but got True")

## test unregistering a reserved id keeps it out of free-id reuse
func test_unregistering_a_reserved_id_keeps_it_out_of_free_id_reuse():
	# reserve an id
	scheduler.reserve_effect_id(0)
	# attempt to unregister the reserved id
	assert_false(scheduler._recycle_effect_id(0), "Expected to fail unregistering reserved id 0, but got True")
	# check that the id is still reserved and not available for reuse
	assert_true(scheduler.is_effect_id_reserved(0), "Expected id 0 to still be reserved after attempting to unregister, but it is not")
	scheduler.unreserve_effect_id(0) # unreserve id for next test

## test unregistering a non-reserved id returns it to free-id reuse
func test_unregistering_a_non_reserved_id_returns_it_to_free_id_reuse():
	# register an id normally
	scheduler._register_effect_id(0)
	assert_true(scheduler.is_effect_id_in_use(0), "Expected id 0 to be in use, but it is not")
	# unregister the id
	assert_true(scheduler._recycle_effect_id(0), "Expected to unregister id 0 successfully, but got False")
	# check that the id is now available for reuse
	assert_false(scheduler.is_effect_id_in_use(0), "Expected id 0 to not be in use after unregistering, but it is still in use")
	# check that the id is available for reuse by registering it again
	assert_true(scheduler._register_effect_id(0), "Expected to register id 0 again after unregistering, but got False")
	scheduler._recycle_effect_id(0) # recycle id for next test

# _unique_effect_exists_in_queues() #

## test when there are no effects of that type in any queue
func test_unique_effect_exists_in_queues_when_no_effects():
	# checking when nothing was done to scheduler, so it should return false immediately
	var test_effect_1 = MockEffect1.new()
	assert_false(scheduler._unique_effect_exists_in_queues(test_effect_1), "Expected _unique_effect_exists_in_queues to return false when there are no effects in any queue, but it returned true")
	test_effect_1.free()

## test when there is an effect of that type in waiting queue
func test_when_there_is_an_effect_of_that_type_in_waiting_queue():
	var test_effect_1 = MockEffect4.new()
	test_effect_1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(test_effect_1)
	assert_true(scheduler._unique_effect_exists_in_queues(test_effect_1), "Expected _unique_effect_exists_in_queues to return true when there is an effect of that type in waiting queue, but it returned false")
	scheduler.remove_all_effects()
	test_effect_1.free()

## test when there is an effect of that type in entering queue
func test_when_there_is_an_effect_of_that_type_in_entering_queue():
	var test_effect_1 = MockEffect4.new()
	test_effect_1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(test_effect_1)
	# process waiting queue to move it to entering queue
	scheduler._process_waiting_effects()
	assert_true(scheduler._unique_effect_exists_in_queues(test_effect_1), "Expected _unique_effect_exists_in_queues to return true when there is an effect of that type in entering queue, but it returned false")
	scheduler.remove_all_effects()
	test_effect_1.free()

## test when there is an effect of that type in active queue
func test_when_there_is_an_effect_of_that_type_in_active_queue():
	var test_effect_1 = MockEffect4.new()
	test_effect_1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(test_effect_1)
	# process waiting queue to move it to entering queue
	scheduler._process_waiting_effects()
	# process entering queue to move it to active queue
	scheduler._process_entering_effects()
	assert_true(scheduler._unique_effect_exists_in_queues(test_effect_1), "Expected _unique_effect_exists_in_queues to return true when there is an effect of that type in active queue, but it returned false")
	scheduler.remove_all_effects()
	test_effect_1.free()

## test when there is an effect of that type in exiting queue
func test_when_there_is_an_effect_of_that_type_in_exiting_queue():
	var test_effect_1 = MockEffect4.new()
	test_effect_1.add_test_environment_data(mock_effect_data)
	scheduler.add_effect(test_effect_1)
	# process waiting queue to move it to entering queue
	scheduler._process_waiting_effects()
	# process entering queue to move it to active queue
	scheduler._process_entering_effects()
	# process active queue to move it to exiting queue, random fake delta
	scheduler._process_active_effects(0.1, false)
	assert_true(scheduler._unique_effect_exists_in_queues(test_effect_1), "Expected _unique_effect_exists_in_queues to return true when there is an effect of that type in exiting queue, but it returned false")
	scheduler.remove_all_effects()
	test_effect_1.free()

## test when effect is null
func test_when_searching_for_specific_instance_given_effect_is_null():
	assert_false(scheduler._unique_effect_exists_in_queues(null), "Expected _unique_effect_exists_in_queues to return false when effect is null, but it returned true")
