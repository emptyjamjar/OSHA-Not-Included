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
		self._type = Type.BUFF
		self._is_persistent = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
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
		self._type = Type.ENVIRONMENTAL
		self._is_persistent = true
		self._is_unique = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
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
		self._type = Type.OBJECT

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
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
		self._type = Type.VISUAL
		self._cooldown_duration = 2.0
		self._enable_cooldown = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
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
		self._type = Type.ENVIRONMENTAL

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
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
		self._type = Type.HAZARD

	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
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
		self._type = Type.BUFF
		self._repeat_max = 5
		self._enable_repeat = true
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
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
		self._type = Type.OBJECT
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
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
		self._type = Type.VISUAL
	
	func add_test_environment_data(mock_data: MockEffectData) -> void:
		self.data = mock_data
	
	func reset() -> void:
		super.reset()
		self._type = Type.VISUAL
	
	func physics_update(delta: float = 0.0) -> void:
		data.value_on_physics_update += 20
		

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

	mock_effect_data.reset()

## After all tests, free scheduler
func after_all():
	scheduler.free()


# Method testing #
# for this testing section, I will test each method for what they expect and a bit of what they don't

# _process_waiting_effects() #

## Test when waiting queue is empty


## test when there is an effect_id but available active slots is 0


## test when there is an effect_id that is null in the record

## test when there is an effect_id that is null in the effect instance

## test when there is an effect_id, but the effect is paused

## test when there is an effect_id and verify it moves from waiting queue to entering queue

# _process_entering_effects() #

## test when entering queue is empty

## test when record is null in entering queue

## test when effect instance is null in entering queue

## test when effect instance is paused in entering queue

## test when effect only has a enter() and exit()

## test when effect has enter(), exit(), and update() but not physics_update()

## test when effect has enter(), exit(), and physics_update() but not update()

## test when effect has enter(), exit(), update(), and physics_update()

## test when effect has only update()

## test when effect has only physics_update()

## test when effect only has update() and physics_update()

# _process_active_effects() #

## test when active queue is empty

## test when there is a null record in active queue

## test when there is a null effect instance in active queue

## test when there is a paused effect in active queue

## test if after being processed by entering queue, if its in active queue if it doesnt update

## test that an effect with duration works correctly in active queue

## test that an effect with repeat works correctly in active queue

## test that an effect with cooldown works correctly in active queue

## test that an effect with duration and repeat works correctly

## test that an effect with duration and cooldown works correctly

## test that an effect with repeat and cooldown works correctly

## test that an effect with duration, repeat, and cooldown works correctly

## test an effect with no duration, repeat, or cooldown

# _process_exiting_effects() #

## test when exiting queue is empty

## test when there is a null record in exiting queue

## test when there is a null effect instance in exiting queue

## test when there is a paused effect in exiting queue

## test that an effect with only exit() is processed correctly in exiting queue

# _add_to_waiting() #

## test if effect is added to waiting queue correctly

## test when effect record is null

## test when effect instance is null

## test adding when queue size limit has been reached

# _add_to_entering() #

## test if effect is added to entering queue correctly

## test when effect record is null

## test when effect instance is null


# _add_to_active() #

## test if effect is added to active queue correctly

## test when effect record is null

## test when effect instance is null


# _add_to_exiting() #

## test if effect is added to exiting queue correctly

## test when effect record is null

## test when effect instance is null


# _remove_from_waiting() #

# test if given id is not in waiting queue

# test if given id is in waiting queue and is removed correctly

# _remove_from_entering() #

# test if given id is not in entering queue

# test if given id is in entering queue and is removed correctly

# _remove_from_active() #

# test if given id is not in active queue

# test if given id is in active queue and is removed correctly

# _remove_from_exiting() #

# test if given id is not in exiting queue

# test if given id is in exiting queue and is removed correctly

# _move_waiting_to_entering() #

## test if given id is not in waiting queue

## test if given id is in waiting queue and moved to entering queue correctly

## test when add_to_entering rejects

# _move_entering_to_active() #

## test if given id is not in entering queue

## test if given id is in entering queue and moved to active queue correctly

## test when add_to_active rejects

# _move_entering_to_exiting() #

## test if given id is not in entering queue

## test if given id is in entering queue and moved to exiting queue correctly

## test when add_to_exiting rejects

# _move_active_to_exiting() #

## test if given id is not in active queue

## test if given id is in active queue and moved to exiting queue correctly

## test when add_to_exiting rejects

# _should_effect_start() #

## test when effect is null

## test when effect should start

# _should_effect_stop() #

## test when effect is null

## test when effect should stop

# _should_effect_update() #

## test when effect is null

## test when effect should update

## test when effect has cooldown and is on cooldown

# _should_effect_physics_update() #

## test when effect is null

## test when effect should physics_update

## test when effect has cooldown and is on cooldown

# _should_end_from_duration() #

## test when effect is null

## test when effect has no duration

## test when effect has duration and has not reached it

## test when effect has duration and has reached it

## test when effect is persistent

# _should_repeat() #

## test when effect is null

## test when effect has no repeat

## test when effect has repeat and has not reached max

## test when effect has repeat and has reached max

## test when effect is persistent

# _run_enter() #

## test when effect is null

## test that effect.enter() is called

# _run_update() #

## test when effect is null

## test that effect.update() is called

# _run_physics_update() #

## test when effect is null

## test that effect.physics_update() is called

# _run_exit() #

## test when effect is null

## test that effect.exit() is called

# public methods #

# enable_scheduler() #

## test that scheduler is enabled

## test that scheduler processing methods are called when enabled

# disable_scheduler() #

## test that scheduler is disabled

## test that scheduler processing methods are not called when disabled

# add_effect() #

## test adding a valid effect

## test adding a null effect

## test adding a unique effect that is already active

## test adding an effect when waiting queue limit has been reached

## test that adding an effect emits the effect_added signal

## test that when an effect is not added, the effect_added signal is not emitted

## test adding an effect with a reserved id

## test adding an effect with a reserved id that is already in use

## test adding an effect with a reserved id when waiting queue limit has been reached

# pause_effect() #

## testing giving an incorrect effect id

## test pausing an effect in waiting queue

## test pausing an effect in entering queue

## test pausing an effect in active queue

## test pausing an effect in exiting queue

## test that pausing an effect prevents it from being processed in scheduler

# resume_effect() #

## testing giving an incorrect effect id

## test resuming an effect in waiting queue

## test resuming an effect in entering queue

## test resuming an effect in active queue

## test resuming an effect in exiting queue

## test that resuming an effect allows it to be processed in scheduler

# pause_all_effects() #

## test pausing when there are no effects

## test that pausing all affects works in all queues

# resume_all_effects() #

## test resuming when there are no effects

## test that resuming all affects works in all queues

# remove_effect_by_instance() #

## test removing an effect by instance

## test removing an effect that is not in any queue

## test removing with an incorrect effect id

# remove_effect_by_id() #

## test removing an effect by id

## test removing an effect that is not in any queue

## test removing with an incorrect effect id

# remove_effect_by_type() #

## test removing effect with type

## test removing effect with type that is not in any queue

## test removing effect with type when there is more than one of that type in the queues

# remove_all_effects_of_type() #

## test removing all effects with type

## test removing all effects with type that is not in any queue

# remove_effect_by_name() #

## test removing effect with name

## test removing effect with name that is not in any queue

## test removing effect with name when there is more than one of that name in the queues

# remove_all_effects_of_name() #

## test removing all effects with name

## test removing all effects with name that is not in any queue

# remove_all_persistent_effects() #

## test removing all persistent effects when there are no persistent effects

## test removing all persistent effects when there are some persistent effects

# remove_all_non_persistent_effects() #

## test removing all non-persistent effects when there are no non-persistent effects

## test removing all non-persistent effects when there are some non-persistent effects

# remove_all_unique_effects() #

## test removing all unique effects when there are no unique effects

## test removing all unique effects when there are some unique effects

# remove_all_non_unique_effects() #

## test removing all non-unique effects when there are no non-unique effects

## test removing all non-unique effects when there are some non-unique effects

# remove_all_timed_effects() #

## test removing all timed effects when there are no timed effects

## test removing all timed effects when there are some timed effects

# remove_all_non_timed_effects() #

## test removing all non-timed effects when there are no non-timed effects

## test removing all non-timed effects when there are some non-timed effects

# remove_all_repeating_effects() #

## test removing all repeating effects when there are no repeating effects

## test removing all repeating effects when there are some repeating effects

# remove_all_non_repeating_effects() #

## test removing all non-repeating effects when there are no non-repeating effects

## test removing all non-repeating effects when there are some non-repeating effects

# remove_all_effects() #

## test removing all effects when there are no effects

## test removing all effects when there are some effects

# get_waiting_effects() #

## test getting waiting effects when there are no waiting effects

## test getting waiting effects when there are some waiting effects

# get_entering_effects() #

## test getting entering effects when there are no entering effects

## test getting entering effects when there are some entering effects

# get_active_effects() #

## test getting active effects when there are no active effects

## test getting active effects when there are some active effects

# get_exiting_effects() #

## test getting exiting effects when there are no exiting effects

## test getting exiting effects when there are some exiting effects

# _update_effect() #

## test updating an effect that is not in any queue

## test when an effect is finished

## test when an effect has timing that needs updating

## test when an effect has cooldown that needs updating

## test when an effect has repeat that needs updating

## test when an effect has timing, repeat that needs updating

## test when an effect has timing, cooldown that needs updating

## test when an effect has repeat, cooldown that needs updating

## test when an effect has timing, repeat, cooldown that needs updating

# Query methods #

# is_effect_waiting() #

## test when effect is not in waiting queue

## test when effect is waiting in queue

## test when effect is paused in waiting queue

## test when effect is entering, active, or exiting but not waiting

## test null effect

# is_effect_active() #

## test when effect is not in active queue

## test when effect is active in queue

## test when effect is paused in active queue

## test when effect is waiting, entering, or exiting but not active

## test null effect

# has_effect_of_type() #

## test when there are no effects of type

## test when there is one effects of type

## test when there are lots effects of type

# has_effect_of_name() #

## test when there are no effects of name

## test when there is one effects of name

## test when there are lots effects of name

# has_effect() #

## test when there are no effects of instance

## test when there is an effect of instance

## when effect is null

# has_effect_with_id() #

## test when there are no effects with id

## test when there is an effect with id

# is_effect_paused() #

## test when effect is not paused

## test when effect is paused

## test when effect is null

## effect is not in any queue

# is_scheduler_enabled() #

## test when scheduler is enabled

## test when scheduler is disabled

# is_scheduler_disabled() #

## test when scheduler is enabled

## test when scheduler is disabled

# get_effect_id() #

## test when effect is null

## test when effect is in waiting queue

## test when effect is in entering queue

## test when effect is in active queue

## test when effect is in exiting queue

# get_effect_id_by_type() #

## test when there are no effects of type

## test when there is one effect of type

## test when there are multiple effects of type

# get_effect_id_by_name() #

## test when there are no effects of name

## test when there is one effect of name

## test when there are multiple effects of name

# get_effect_by_id() #

## test when there are no effects with id

## test when there is an effect with id

# get_effect_by_type() #

## test when there are no effects of type

## test when there is one effect of type

## test when there are multiple effects of type

# get_effects_by_type() #

## test when there are no effects of type

## test when there are some effects of type

# get_effect_by_name() #

## test when there are no effects of name

## test when there is one effect of name

## test when there are multiple effects of name

# get_effects_by_name() #

## test when there are no effects of name

## test when there are some effects of name

# _get_effect_record() #

## test when there are no records of that instance

## test when there is a record of that instance

## test when effect is null

# get_effect_record_by_id() #

## test when there are no records with id

## test when there is a record with id

# get_effect_record_by_instance() #

## test when there are no records of that instance

## test when there is a record of that instance

# get_effect_record_by_name() #

## test when there are no records of that name

## test when there is a record of that name

## test when there is more than one record of that name

# get_all_records_by_type() #

## test when there are no records of that type

## test when there are some records of that type

# get_all_records_by_name() #

## test when there are no records of that name

## test when there are some records of that name

# get_all_persistent_records() #

## test when there are no persistent records

## test when there are some persistent records

# get_all_unique_records() #

## test when there are no unique records

## test when there are some unique records

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
		var id = scheduler.get_next_available_effect_id()
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
	var id_a = scheduler.get_next_available_effect_id()
	scheduler._register_effect_id(id_a)
	var id_b = scheduler.get_next_available_effect_id()
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
		var id = scheduler.get_next_available_effect_id()
		scheduler._register_effect_id(id)
	
	# now that all ids are registered, attempt to get another id which should fail
	var new_id = scheduler.get_next_available_effect_id()
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

# get_next_available_effect_id() #

## test when recycled ids are available and it returns one without consuming it
func test_when_recycled_ids_are_available_and_it_returns_one_without_consuming_it():
	scheduler._register_effect_id(0)
	scheduler._recycle_effect_id(0)
	var result = scheduler.get_next_available_effect_id()
	assert_eq(result, 0, "Expected to get recycled id 0, but got " + str(result))
	result = scheduler.get_next_available_effect_id()
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
	var result = scheduler.get_next_available_effect_id()
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
func test_when_effect_is_null():
	assert_false(scheduler._unique_effect_exists_in_queues(null), "Expected _unique_effect_exists_in_queues to return false when effect is null, but it returned true")

# Effect Testing #
# this section will try to test scheduler under real conditions with mock effects to see if the expected behavior occurs
