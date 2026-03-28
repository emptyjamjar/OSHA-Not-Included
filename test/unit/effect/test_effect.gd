extends GutTest

## This test script is for effect.gd, which is a base class for effects in the game.

# global variables for the tests
var effect_instance:Effect = null

# Before all secrets, create an instance of the Effect class to be used in the tests.
func before_all():
	effect_instance = Effect.new()

# Before each test, reset the effect instance to default values.
func before_each():
	effect_instance.set_type(Effect.Type.BUFF)
	effect_instance.set_effect_name("Test Effect")
	# flags
	effect_instance.set_unique(false)
	effect_instance.set_persistent(false)
	# Timing properties
	effect_instance.set_enable_timing(false)
	effect_instance.set_duration(0.0)
	effect_instance.set_elapsed_time(0.0)
	# Repeating properties
	effect_instance.set_enable_repeat(false)
	effect_instance.set_repeat_max(0)
	effect_instance.set_repeat_count(0)
	# Cooldown properties
	effect_instance.set_enable_cooldown(false)
	effect_instance.set_cooldown_duration(0.0)
	effect_instance.set_cooldown_elapsed(0.0)

# After all tests, free the effect instance.
func after_all():
	effect_instance.free()


# Test basic constructor, verify that all properties have a default value and are not null.

## Test that type and effect name have default values (no arguments)
func test_constructor_default_values():
	assert_eq(effect_instance.get_type(), Effect.Type.BUFF, "Default type should be BUFF")
	assert_eq(effect_instance.get_effect_name(), "Test Effect", "Default effect name should be 'Test Effect'")

## Test that constructor with arguments sets type and effect name correctly
func test_constructor_with_arguments():
	var custom_effect = Effect.new(Effect.Type.DEBUFF, "Custom Effect")
	assert_eq(custom_effect.get_type(), Effect.Type.DEBUFF, "Type should be set to DEBUFF")
	assert_eq(custom_effect.get_effect_name(), "Custom Effect", "Effect name should be set to 'Custom Effect'")
	custom_effect.free()

## Test all default flags and values are set correctly
func test_constructor_default_flags_and_values():
	assert_false(effect_instance.is_unique(), "Default unique flag should be false")
	assert_false(effect_instance.is_persistent(), "Default persistent flag should be false")
	assert_false(effect_instance.is_timing_enabled(), "Default enable timing flag should be false")
	assert_eq(effect_instance.get_duration(), 0.0, "Default duration should be 0.0")
	assert_eq(effect_instance.get_elapsed_time(), 0.0, "Default elapsed time should be 0.0")
	assert_false(effect_instance.is_repeat_enabled(), "Default enable repeat flag should be false")
	assert_eq(effect_instance.get_repeat_max(), 0, "Default repeat max should be 0")
	assert_eq(effect_instance.get_repeat_count(), 0, "Default repeat count should be 0")
	assert_false(effect_instance.is_cooldown_enabled(), "Default cooldown flag should be false")
	assert_eq(effect_instance.get_cooldown_duration(), 0.0, "Default cooldown duration should be 0.0")
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.0, "Default cooldown elapsed time should be 0.0")

# Test enter() method

## Test enter method emits started signal
func test_enter_emits_started_signal():
	watch_signals(effect_instance)
	effect_instance.enter()
	assert_signal_emitted(effect_instance, "started", "Expected 'started' signal to be emitted.")

# Test exit() method

## Test exit method emits finished signal
func test_exit_emits_finished_signal():
	watch_signals(effect_instance)
	effect_instance.exit()
	assert_signal_emitted(effect_instance, "ended", "Expected 'ended' signal to be emitted.")


# Test update() method
# NOTE: No test needed for update() as it is meant to be overridden by subclasses and has no base functionality.

# Test physics_update() method
# NOTE: No test needed for physics_update() as it is meant to be overridden by subclasses and has no base functionality.

# tests on the getter and setter methods #

# Tests on set/get type

## test setting type to object
func test_set_get_type_object():
	effect_instance.set_type(Effect.Type.OBJECT)
	assert_eq(effect_instance.get_type(), Effect.Type.OBJECT, "Type should be set to OBJECT")

## test setting type to buff when it is already buff
func test_set_get_type_buff():
	effect_instance.set_type(Effect.Type.BUFF)
	assert_eq(effect_instance.get_type(), Effect.Type.BUFF, "Type should remain BUFF")

# Tests on the set/get effect name

## test setting effect name to a custom string
func test_set_get_effect_name_custom():
	effect_instance.set_effect_name("Custom Effect Name")
	assert_eq(effect_instance.get_effect_name(), "Custom Effect Name", "Effect name should be set to 'Custom Effect Name'")

## test setting effect name to empty string
func test_set_get_effect_name_empty():
	effect_instance.set_effect_name("")
	assert_eq(effect_instance.get_effect_name(), "", "Effect name should be set to an empty string")

## test setting effect name to a long string
func test_set_get_effect_name_long():
	var long_name = "This is a very long effect name that exceeds typical lengths"
	effect_instance.set_effect_name(long_name)
	assert_eq(effect_instance.get_effect_name(), long_name, "Effect name should be set to the long string")

## test setting effect name to a string with special characters
func test_set_get_effect_name_special_characters():
	var special_name = "Effect!@#$%^&*()_+|"
	effect_instance.set_effect_name(special_name)
	assert_eq(effect_instance.get_effect_name(), special_name, "Effect name should be set to the string with special characters")


# Tests on set/get unique flag

## test setting unique flag to true
func test_set_get_unique_flag_true():
	effect_instance.set_unique(true)
	assert_true(effect_instance.is_unique(), "Unique flag should be set to true")

## test setting unique flag to false after being true
func test_set_get_unique_flag_false():
	effect_instance.set_unique(false)
	effect_instance.set_unique(true)
	effect_instance.set_unique(false)
	assert_false(effect_instance.is_unique(), "Unique flag should be set to false")

# Tests on set/get persistent flag

## test setting persistent flag to true
func test_set_get_persistent_flag_true():
	effect_instance.set_persistent(true)
	assert_true(effect_instance.is_persistent(), "Persistent flag should be set to true")

## test setting persistent flag to false after being true
func test_set_get_persistent_flag_false():
	effect_instance.set_persistent(false)
	effect_instance.set_persistent(true)
	effect_instance.set_persistent(false)
	assert_false(effect_instance.is_persistent(), "Persistent flag should be set to false")

# Tests on set/get timing flag

## test setting timing flag to true
func test_set_get_timing_flag_true():
	effect_instance.set_enable_timing(true)
	assert_true(effect_instance.is_timing_enabled(), "Timing flag should be set to true")

## test setting timing flag to false after being true
func test_set_get_timing_flag_false():
	effect_instance.set_enable_timing(false)
	effect_instance.set_enable_timing(true)
	effect_instance.set_enable_timing(false)
	assert_false(effect_instance.is_timing_enabled(), "Timing flag should be set to false")

# Tests on the set/get duration

## test setting duration to a positive value
func test_set_get_duration_positive():
	effect_instance.set_duration(5.0)
	assert_eq(effect_instance.get_duration(), 5.0, "Duration should be set to 5.0") 

## test setting duration to zero
func test_set_get_duration_zero():
	effect_instance.set_duration(0.0)
	assert_eq(effect_instance.get_duration(), 0.0, "Duration should be set to 0.0")

## test setting duration to a negative value
func test_set_get_duration_negative():
	assert_eq(effect_instance.set_duration(-3.0), false, "Duration should reject negative values.")
	assert_eq(effect_instance.get_duration(), 0.0, "Duration should remain unchanged when setting negative value.")

## test setting duration to a very large value
func test_set_get_duration_large():
	var large_duration = 1e6
	effect_instance.set_duration(large_duration)
	assert_eq(effect_instance.get_duration(), large_duration, "Duration should be set to a very large value")

## test setting duration with an integer value
func test_set_get_duration_integer():
	effect_instance.set_duration(10)
	assert_eq(effect_instance.get_duration(), 10.0, "Duration should be set to 10.0 when given an integer value")

# Tests on set/get enable repeat flag

## test setting enable repeat flag to true
func test_set_get_enable_repeat_flag_true():
	effect_instance.set_enable_repeat(true)
	assert_true(effect_instance.is_repeat_enabled(), "Enable repeat flag should be set to true")

## test setting enable repeat flag to false after being true
func test_set_get_enable_repeat_flag_false():
	effect_instance.set_enable_repeat(false)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_enable_repeat(false)
	assert_false(effect_instance.is_repeat_enabled(), "Enable repeat flag should be set to false")

# Tests on set/get repeat max

## test setting repeat max to a positive integer
func test_set_get_repeat_max_positive():
	effect_instance.set_repeat_max(3)
	assert_eq(effect_instance.get_repeat_max(), 3, "Repeat max should be set to 3")

## test setting repeat max to zero
func test_set_get_repeat_max_zero():
	effect_instance.set_repeat_max(0)
	assert_eq(effect_instance.get_repeat_max(), 0, "Repeat max should be set to 0")

## test setting repeat max to a negative integer
func test_set_get_repeat_max_negative():
	assert_eq(effect_instance.set_repeat_max(-2), false, "Repeat max should reject setting negative value.")
	assert_eq(effect_instance.get_repeat_max(), 0, "Repeat max should remain unchanged when setting negative value.")


# Tests on set/get elapsed time

## test setting elapsed time to a positive value
func test_set_get_elapsed_time_positive():
	effect_instance.set_elapsed_time(2.5)
	assert_eq(effect_instance.get_elapsed_time(), 2.5, "Elapsed time should be set to 2.5")

## test setting elapsed time to zero
func test_set_get_elapsed_time_zero():
	effect_instance.set_elapsed_time(0.0)
	assert_eq(effect_instance.get_elapsed_time(), 0.0, "Elapsed time should be set to 0.0")

## test setting elapsed time to a negative value
func test_set_get_elapsed_time_negative():
	assert_eq(effect_instance.set_elapsed_time(-1.0), false, "Elapsed time should reject negative values.")
	assert_eq(effect_instance.get_elapsed_time(), 0.0, "Elapsed time should remain unchanged when setting negative value.")

# Tests on set/get repeat count

## test setting repeat count to a positive integer
func test_set_get_repeat_count_positive():
	effect_instance.set_repeat_count(2)
	assert_eq(effect_instance.get_repeat_count(), 2, "Repeat count should be set to 2")

## test setting repeat count to zero
func test_set_get_repeat_count_zero():
	effect_instance.set_repeat_count(0)
	assert_eq(effect_instance.get_repeat_count(), 0, "Repeat count should be set to 0")

## test setting repeat count to a negative integer
func test_set_get_repeat_count_negative():
	assert_eq(effect_instance.set_repeat_count(-1), false, "Repeat count should reject negative values.")
	assert_eq(effect_instance.get_repeat_count(), 0, "Repeat count should remain unchanged when setting negative value.")

# Tests on set/get cooldown flag

## test setting cooldown flag to true
func test_set_get_cooldown_flag_true():
	effect_instance.set_enable_cooldown(true)
	assert_true(effect_instance.is_cooldown_enabled(), "Cooldown flag should be set to true")

## test setting cooldown flag to false after being true
func test_set_get_cooldown_flag_false():
	effect_instance.set_enable_cooldown(false)
	effect_instance.set_enable_cooldown(true)
	effect_instance.set_enable_cooldown(false)
	assert_false(effect_instance.is_cooldown_enabled(), "Cooldown flag should be set to false")

# Tests on set/get cooldown duration

## test setting cooldown duration to a positive value
func test_set_get_cooldown_duration_positive():
	effect_instance.set_cooldown_duration(4.0)
	assert_eq(effect_instance.get_cooldown_duration(), 4.0, "Cooldown duration should be set to 4.0")

## test setting cooldown duration to zero
func test_set_get_cooldown_duration_zero():
	effect_instance.set_cooldown_duration(0.0)
	assert_eq(effect_instance.get_cooldown_duration(), 0.0, "Cooldown duration should be set to 0.0")

## test setting cooldown duration to a negative value
func test_set_get_cooldown_duration_negative():
	assert_eq(effect_instance.set_cooldown_duration(-2.0), false, "Cooldown duration should reject negative values.")
	assert_eq(effect_instance.get_cooldown_duration(), 0.0, "Cooldown duration should remain unchanged when setting negative value.")

# Tests on set/get cooldown elapsed time

## test setting cooldown elapsed time to a positive value
func test_set_get_cooldown_elapsed_positive():
	effect_instance.set_cooldown_elapsed(1.5)
	assert_eq(effect_instance.get_cooldown_elapsed(), 1.5, "Cooldown elapsed time should be set to 1.5")

## test setting cooldown elapsed time to zero
func test_set_get_cooldown_elapsed_zero():
	effect_instance.set_cooldown_elapsed(0.0)
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.0, "Cooldown elapsed time should be set to 0.0")

## test setting cooldown elapsed time to a negative value
func test_set_get_cooldown_elapsed_negative():
	assert_eq(effect_instance.set_cooldown_elapsed(-1.0), false, "Cooldown elapsed time should reject negative values.")
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.0, "Cooldown elapsed time should remain unchanged when setting negative value.")

# Tests on reset() method

## Test reset method sets all properties back to default values
func test_reset_method():
	# first change all properties to non-default values for verification
	effect_instance.set_type(Effect.Type.DEBUFF)
	effect_instance.set_effect_name("Changed Name")
	effect_instance.set_unique(true)
	effect_instance.set_persistent(true)
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(10.0)
	effect_instance.set_elapsed_time(5.0)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(1)
	effect_instance.set_enable_cooldown(true)
	effect_instance.set_cooldown_duration(5.0)
	effect_instance.set_cooldown_elapsed(2.0)
	# now reset and verify all properties are back to defaults (defaults in effect.gd)
	effect_instance.reset()
	# comparisions here are verifying what effect.gd would reset them to
	assert_eq(effect_instance.get_type(), Effect.Type.NONE, "Type should be reset to NONE")
	assert_eq(effect_instance.get_effect_name(), "", "Effect name should be reset to an empty string")
	assert_false(effect_instance.is_unique(), "Unique flag should be reset to false")
	assert_false(effect_instance.is_persistent(), "Persistent flag should be reset to false")
	assert_false(effect_instance.is_timing_enabled(), "Timing flag should be reset to false")
	assert_eq(effect_instance.get_duration(), 0.0, "Duration should be reset to 0.0")
	assert_eq(effect_instance.get_elapsed_time(), 0.0, "Elapsed time should be reset to 0.0")
	assert_false(effect_instance.is_repeat_enabled(), "Enable repeat flag should be reset to false")
	assert_eq(effect_instance.get_repeat_max(), 0, "Repeat max should be reset to 0")
	assert_eq(effect_instance.get_repeat_count(), 0, "Repeat count should be reset to 0")
	assert_false(effect_instance.is_cooldown_enabled(), "Cooldown flag should be reset to false")
	assert_eq(effect_instance.get_cooldown_duration(), 0.0, "Cooldown duration should be reset to 0.0")
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.0, "Cooldown elapsed time should be reset to 0.0")

# Tests on reset_timing() method

## Test reset_timing method resets elapsed time to zero but does not change duration
func test_reset_timing_method():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(10.0)
	effect_instance.set_elapsed_time(5.0)
	effect_instance.reset_timing()
	assert_eq(effect_instance.get_elapsed_time(), 0.0, "Elapsed time should be reset to 0.0")
	assert_eq(effect_instance.get_duration(), 10.0, "Duration should remain unchanged at 10.0")

# Tests on reset_repeating() method

## Test reset_repeating method resets repeat count to zero but does not change repeat max
func test_reset_repeating_method():
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(2)
	effect_instance.reset_repeating()
	assert_eq(effect_instance.get_repeat_count(), 0, "Repeat count should be reset to 0")
	assert_eq(effect_instance.get_repeat_max(), 3, "Repeat max should remain unchanged at 3")


# Tests on reset_cooldown() method

## Test reset_cooldown method resets cooldown elapsed time to zero but does not change cooldown duration
func test_reset_cooldown_method():
	effect_instance.set_enable_cooldown(true)
	effect_instance.set_cooldown_duration(5.0)
	effect_instance.set_cooldown_elapsed(2.0)
	effect_instance.reset_cooldown()
	assert_eq(effect_instance.get_cooldown_elapsed(), 0.0, "Cooldown elapsed time should be reset to 0.0")
	assert_eq(effect_instance.get_cooldown_duration(), 5.0, "Cooldown duration should remain unchanged at 5.0")

# Tests on increment_repeat() method

## Test increment_repeat method increases repeat count by 1
func test_increment_repeat_method():
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_count(1)
	effect_instance.increment_repeat()
	assert_eq(effect_instance.get_repeat_count(), 2, "Repeat count should be incremented to 2")

# Tests on increment_elapsed_time() method

## Test increment_elapsed_time method increases elapsed time by given amount
func test_increment_elapsed_time_method():
	effect_instance.set_enable_timing(true)
	effect_instance.set_elapsed_time(3.0)
	effect_instance.increment_elapsed_time(2.0)
	assert_eq(effect_instance.get_elapsed_time(), 5.0, "Elapsed time should be incremented to 5.0")

# Tests on increment_cooldown_elapsed() method

## Test increment_cooldown_elapsed method increases cooldown elapsed time by given amount
func test_increment_cooldown_elapsed_method():
	effect_instance.set_enable_cooldown(true)
	effect_instance.set_cooldown_elapsed(1.0)
	effect_instance.increment_cooldown_elapsed(1.5)
	assert_eq(effect_instance.get_cooldown_elapsed(), 2.5, "Cooldown elapsed time should be incremented to 2.5")

# Tests on is_active() method
# is_active() checks for persistance, timing, repeating, and both timing and repeating conditions

## Test is_active returns true for a persistent effect
func test_is_active_persistent():
	effect_instance.set_persistent(true)
	assert_true(effect_instance.is_active(), "Persistent effect should be active")

## Scenario 1 - No expiry conditions (no timing, no repeat, not persistent): always active
func test_is_active_no_expiry_conditions():
	# before_each resets all flags to false — no conditions can expire the effect
	assert_true(effect_instance.is_active(), "Effect with no expiry conditions should always be active")

## Scenario 2 - Timing only: active while elapsed time is within duration
func test_is_active_timing_only_active():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(2.0)
	assert_true(effect_instance.is_active(), "Effect should be active while elapsed time is within duration")

## Scenario 2 - Timing only: inactive when duration has expired
func test_is_active_timing_only_expired():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(5.0)
	assert_false(effect_instance.is_active(), "Effect should be inactive when elapsed time meets or exceeds duration")

## Scenario 3 - Repeat only: active while repeat cycles remain
func test_is_active_repeat_only_active():
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(1)
	assert_true(effect_instance.is_active(), "Effect should be active while repeat cycles remain")

## Scenario 3 - Repeat only: inactive when all repeat cycles are exhausted
func test_is_active_repeat_only_exhausted():
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(3)
	assert_false(effect_instance.is_active(), "Effect should be inactive when all repeat cycles are exhausted")

## Scenario 4 - Timing and repeat: active when a duration cycle expires but repeat cycles remain
func test_is_active_timing_and_repeat_cycle_expired_repeats_remain():
	effect_instance.set_enable_timing(true)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(5.0)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(1)
	assert_true(effect_instance.is_active(), "Effect should be active when a cycle expires but repeat cycles remain")

## Scenario 4 - Timing and repeat: inactive when all repeat cycles are exhausted
func test_is_active_timing_and_repeat_all_cycles_exhausted():
	effect_instance.set_enable_timing(true)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(5.0)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(3)
	assert_false(effect_instance.is_active(), "Effect should be inactive when all repeat cycles are exhausted")


# Tests on is_finished() method
# is_finished() is basically not is_active(), so we can test the same scenarios as is_active but with opposite expected results.

## Test is_finished returns false for a persistent effect
func test_is_finished_persistent():
	effect_instance.set_persistent(true)
	assert_false(effect_instance.is_finished(), "Persistent effect should not be finished")

## Scenario 1 - No expiry conditions (no timing, no repeat, not persistent): never finished
func test_is_finished_no_expiry_conditions():
	# before_each resets all flags to false — no conditions can expire the effect
	assert_false(effect_instance.is_finished(), "Effect with no expiry conditions should never be finished")

## Scenario 2 - Timing only: not finished while elapsed time is within duration
func test_is_finished_timing_only_active():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(2.0)
	assert_false(effect_instance.is_finished(), "Effect should not be finished while elapsed time is within duration")

## Scenario 2 - Timing only: finished when duration has expired
func test_is_finished_timing_only_expired():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(5.0)
	assert_true(effect_instance.is_finished(), "Effect should be finished when elapsed time meets or exceeds duration")

## Scenario 3 - Repeat only: not finished while repeat cycles remain
func test_is_finished_repeat_only_active():
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(1)
	assert_false(effect_instance.is_finished(), "Effect should not be finished while repeat cycles remain")

## Scenario 3 - Repeat only: finished when all repeat cycles are exhausted
func test_is_finished_repeat_only_exhausted():
	effect_instance.set_enable_repeat(true)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(3)
	assert_true(effect_instance.is_finished(), "Effect should be finished when all repeat cycles are exhausted")

## Scenario 4 - Timing and repeat: not finished when a duration cycle expires but repeat cycles remain
func test_is_finished_timing_and_repeat_cycle_expired_repeats_remain():
	effect_instance.set_enable_timing(true)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(5.0)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(1)
	assert_false(effect_instance.is_finished(), "Effect should not be finished when a cycle expires but repeat cycles remain")

## Scenario 4 - Timing and repeat: finished when all repeat cycles are exhausted
func test_is_finished_timing_and_repeat_all_cycles_exhausted():
	effect_instance.set_enable_timing(true)
	effect_instance.set_enable_repeat(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(5.0)
	effect_instance.set_repeat_max(3)
	effect_instance.set_repeat_count(3)
	assert_true(effect_instance.is_finished(), "Effect should be finished when all repeat cycles are exhausted")



# Tests on is_on_cooldown() method

## test is_on_cooldown returns false when cooldown is not enabled
func test_is_on_cooldown_not_enabled():
	assert_false(effect_instance.is_on_cooldown(), "Effect should not be on cooldown when cooldown is not enabled")

## test is_on_cooldown returns false when cooldown is enabled but elapsed time is less than cooldown duration
func test_is_on_cooldown_enabled_not_elapsed():
	effect_instance.set_enable_cooldown(true)
	effect_instance.set_cooldown_duration(5.0)
	effect_instance.set_cooldown_elapsed(3.0)
	assert_true(effect_instance.is_on_cooldown(), "Effect should be on cooldown when cooldown is enabled and cooldown elapsed time is less than cooldown duration")

## test is_on_cooldown returns true when cooldown is enabled and elapsed time meets or exceeds cooldown duration
func test_is_on_cooldown_enabled_elapsed():
	effect_instance.set_enable_cooldown(true)
	effect_instance.set_cooldown_duration(5.0)
	effect_instance.set_cooldown_elapsed(5.0)
	assert_false(effect_instance.is_on_cooldown(), "Effect should not be on cooldown when cooldown is enabled and elapsed time meets or exceeds cooldown duration") 


# Tests on get_progress() method

## test get_progress returns 0 when timing is not enabled
func test_get_progress_timing_not_enabled():
	assert_eq(effect_instance.get_progress(), 0.0, "Progress should be 0 when timing is not enabled")

## test get_progress returns 1 when elapsed time meets or exceeds duration
func test_get_progress_timing_elapsed():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(5.0)
	assert_eq(effect_instance.get_progress(), 1.0, "Progress should be 1 when elapsed time meets or exceeds duration")

## test get_progress returns correct ratio when timing is enabled and elapsed time is within duration
func test_get_progress_timing_within_duration():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(10.0)
	effect_instance.set_elapsed_time(4.0)
	assert_eq(effect_instance.get_progress(), 0.4, "Progress should be 0.4 when elapsed time is 4 and duration is 10")

## test get_progress returns 0 when duration is zero to avoid division by zero
func test_get_progress_duration_zero():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(0.0)
	effect_instance.set_elapsed_time(0.0)
	assert_eq(effect_instance.get_progress(), 0.0, "Progress should be 0 when duration is zero to avoid division by zero")

# Tests on get_remaining_time() method

## test get_remaining_time returns 0 when timing is not enabled
func test_get_remaining_time_timing_not_enabled():
	assert_eq(effect_instance.get_remaining_time(), 0.0, "Remaining time should be 0 when timing is not enabled")

## test get_remaining_time returns 0 when effect is persistent
func test_get_remaining_time_persistent():
	effect_instance.set_persistent(true)
	assert_eq(effect_instance.get_remaining_time(), 0.0, "Remaining time should be 0 for a persistent effect")

## test get_remaining_time returns 0 when elapsed time meets or exceeds duration
func test_get_remaining_time_elapsed():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(5.0)
	effect_instance.set_elapsed_time(5.0)
	assert_eq(effect_instance.get_remaining_time(), 0.0, "Remaining time should be 0 when elapsed time meets or exceeds duration")

## test get_remaining_time returns correct remaining time when timing is enabled and elapsed time is within duration
func test_get_remaining_time_within_duration():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(10.0)
	effect_instance.set_elapsed_time(4.0)
	assert_eq(effect_instance.get_remaining_time(), 6.0, "Remaining time should be 6 when elapsed time is 4 and duration is 10")

## test get_remaining_time returns 0 when duration is zero to avoid negative remaining time
func test_get_remaining_time_duration_zero():
	effect_instance.set_enable_timing(true)
	effect_instance.set_duration(0.0)
	effect_instance.set_elapsed_time(0.0)
	assert_eq(effect_instance.get_remaining_time(), 0.0, "Remaining time should be 0 when duration is zero to avoid negative remaining time")

# Tests on get_type_as_string() method

## test get_type_as_string returns correct string for NONE type
func test_get_type_as_string_none():
	assert_eq(effect_instance.get_type_as_string(), "BUFF", "Type string for NONE should be 'BUFF'")

## Test get_type_as_string when type is changed to ENVIRONMENT
func test_get_type_as_string_environment():
	effect_instance.set_type(Effect.Type.ENVIRONMENTAL)
	assert_eq(effect_instance.get_type_as_string(), "ENVIRONMENTAL", "Type string for ENVIRONMENTAL should be 'ENVIRONMENTAL'")
