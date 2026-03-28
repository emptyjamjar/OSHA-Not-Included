extends Node
class_name EffectScheduler
## Description:
## EffectScheduler is the system that keeps track of game effects from start to finish.
## When an effect is added, it moves through clear stages: waiting, entering, active, and exiting.
## The scheduler decides when effects can run, updates active effects over time, and removes them when they are done.
## It also enforces limits (like how many effects can run at once) and provides optional debug logs to help track behavior.

## Key Features:
## - Effect Queuing: Effects can be added to a waiting queue and will be processed in order. The scheduler manages the transition of effects from waiting to active states based on defined conditions and capacity limits.
## - Timing and Repeats: The scheduler tracks the duration and repeat counts of effects, allowing for time-bound effects and those that repeat a certain number of times.
## - Cooldown Management: Effects can have cooldowns that prevent them from being active again until a certain time has passed after they finish.
## - Debugging and Logging: The scheduler includes detailed logging options to help developers understand the lifecycle of effects and diagnose issues.

## Usage:
## 1. Create an instance of EffectScheduler in your scene.
## 2. Use the add_effect() method to add effects to the scheduler. The scheduler will handle their lifecycle automatically.
## 3. Optionally, use the provided methods to query active effects or manually remove effects as needed


# Signals #
## Emitted when an effect is added to the scheduler. Provides the effect instance as an argument.
signal effect_added(effect: Effect)
## Emitted when an effect is removed from the scheduler. Provides the effect instance as an argument.
signal effect_removed(effect: Effect)

# Export variables #

@export_category("Queue and Safety Limits")

## Maximum number of effects that can be queued for processing. New effects will be rejected if this limit is reached.
@export var max_queue_size: int = 500
## Maximum number of effects that can be active simultaneously.
@export var max_active_effects: int = 100

@export_category("Timing Controls")
## Global time scale for all effects. A value of 1.0 means normal speed, 0.5 means half speed, and 2.0 means double speed.
@export var time_scale: float = 1.0
## Minimum delta time for effect updates. This prevents extremely small delta values from causing instability (aka effect checks running too frequently)
@export var min_delta: float = 0.01

@export_category("Debugging and Logging")
## Enables detailed logging of effect processing for debugging purposes. Logs will include effect lifecycle events and timing information. Logs are printed to the console when enabled.
@export var debug_logging:bool = false
## Enables logging of active effects each frame for debugging purposes.
## When enabled, the scheduler will print details of all active effects during each update cycle.
## (Warning: This can produce a large amount of log output if many effects are active, so use with caution!)
@export var debug_log_active_effects:bool = false


# Internal state variables #

## A record class to hold information about scheduled effects, including the effect instance and timing details for tracking purposes.
class ScheduleRecord:
	# The effect instance being scheduled.
	var effect:Effect
	# The time when the effect was added to the scheduler, used for tracking total time in scheduler.
	var time_added:float
	# The time when the effect was started, used for tracking elapsed time since start.
	var start_time:float
	# The time when the effect was last updated, used for calculating delta time between updates.
	var last_update_time:float
	# The time when the effect was stopped, used for tracking total active duration.
	var exit_time:float
	# Flags to indicate the current state of the effect in the scheduler lifecycle. Only one of these should be true at a time to indicate the effect's current phase.
	var is_waiting:bool = false
	var is_entering:bool = false
	var is_active:bool = false
	var is_exiting:bool = false

## A counter to assign unique IDs to effects for tracking purposes. Resets when _effect_id_max is reached
var _effect_id_counter: int = 0

## max number of unique IDs before resetting the counter to prevent overflow. 
const _effect_id_max:int = 1048576

## A list of effects that are queued to be processed. Each entry is an Effect instance waiting to be started.
var _waiting_effects:Dictionary = {} # {Effect_ID: ScheduleRecord}
## This array holds effects that are currently entering (regardless if enter method has anything or not), afterward they will be moved to _active_effects
var _entering_effects:Dictionary = {} # {Effect_ID: ScheduleRecord}
## Active effects that have been started and are being processed
var _active_effects:Dictionary = {} # {Effect_ID: ScheduleRecord}
## A list of effects that are currently exiting (regardless if exit method has anything or not), afterward they will be removed from _active_effects
var _exiting_effects:Dictionary = {} # {Effect_ID: ScheduleRecord}

## Prefix for log messages to easily identify them in the console when debug_logging is enabled.
const _scheduler_identifer = "[EffectScheduler]"


# Lifecycle #

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	_process_waiting_effects()
	_process_entering_effects()
	_process_active_effects(delta * time_scale, false)
	_process_exiting_effects()


func _physics_process(delta: float) -> void:
	_process_active_effects(delta * time_scale, true)


# Processing #

## Effects that are waiting to be started are processed in the order they were added to the queue.
## If under the max_active_effects limit, they will be moved to the entering queue, first come first serve.
func _process_waiting_effects() -> void:
	if _waiting_effects.is_empty():
		return

	# Entering queue counts against capacity because those effects are about to become active.
	var available_slots := max_active_effects - (_active_effects.size() + _entering_effects.size())
	if available_slots <= 0:
		return

	# Iterate over a this frame snapshot so we can move effects safely while iterating.
	var waiting_ids: Array = _waiting_effects.keys()
	for effect_id in waiting_ids:
		if available_slots <= 0:
			break

		if not _waiting_effects.has(effect_id):
			continue

		# check for null record or effect instance, if either is null, remove from waiting queue and skip
		var record: ScheduleRecord = _waiting_effects[effect_id]
		if record == null or record.effect == null:
			_remove_from_waiting(effect_id)
			continue

		if not _should_effect_start(record.effect):
			continue

		# move to entering queue and if successful, decrease available slots
		if _move_waiting_to_entering(effect_id):
			available_slots -= 1
		
		

## Runs the start() method for effects in the entering queue and if conditions are met, moves them to the active effects list.
## The method will additionally check if the effect immediately exit after starting, otherwise it will be moved to the active effects list.
func _process_entering_effects() -> void:
	if _entering_effects.is_empty():
		return

	# Iterate over a snapshot so we can move effects safely while iterating.
	var entering_ids: Array = _entering_effects.keys()
	for effect_id in entering_ids:
		if not _entering_effects.has(effect_id):
			continue

		var record: ScheduleRecord = _entering_effects[effect_id]
		if record == null or record.effect == null:
			_remove_from_entering(effect_id)
			continue

		var effect: Effect = record.effect
		_run_enter(effect)

		# Effects that finish immediately after enter() skip active and go straight to exiting.
		if _should_effect_stop(effect):
			_move_entering_to_exiting(effect_id)
			continue

		# this will only move to active if the effect is not finished
		_move_entering_to_active(effect_id)

## Runs the update() and physics_update() methods for active effects based on their conditions and scheduler rules.
## For active effects, the scheduler will check if they should be stopped or ended based on duration, and if not, it will run their update methods as appropriate.
## The method will also update the effect's internal timing and repeat counters, and if an effect finishes during the update, it will be moved to the exiting queue.
## @param delta: the time elapsed since the last update, scaled by the scheduler time_scale
## @param is_physics_pass: indicating whether this update is being called from the physics process (true), or the regular process (false)
func _process_active_effects(delta: float, is_physics_pass: bool) -> void:
	if _active_effects.is_empty():
		return

	if delta < min_delta:
		return

	# Iterate over a current list of active effects so we can safely move effects while iterating.
	var now_sec := Time.get_ticks_msec() / 1000.0
	var active_ids: Array = _active_effects.keys()
	for effect_id in active_ids:
		if not _active_effects.has(effect_id):
			continue

		var record: ScheduleRecord = _active_effects[effect_id]
		if record == null or record.effect == null:
			_remove_from_active(effect_id)
			continue

		var effect: Effect = record.effect

		# Keep record timing info current for diagnostics and scheduler math (do not remove!)
		record.last_update_time = now_sec

		# Check if the effect should stop
		if _should_effect_stop(effect) or _should_end_from_duration(effect, delta):
			_move_active_to_exiting(effect_id)
			continue

		# check if we should run physics update or regular update
		if is_physics_pass:
			if _should_effect_physics_update(effect):
				_run_physics_update(effect, delta)
			continue

		if _should_effect_update(effect):
			_run_update(effect, delta)

		# Advance effect-managed counters once per frame update pass.
		if not _update_effect(effect, delta):
			_move_active_to_exiting(effect_id)

## Runs the exit() method for effects in the exiting queue and removes them from the exiting queue
func _process_exiting_effects() -> void:
	if _exiting_effects.is_empty():
		return

	# Iterate over the current list of exiting effects so we can safely remove effects while iterating
	var exiting_ids: Array = _exiting_effects.keys()
	for effect_id in exiting_ids:
		if not _exiting_effects.has(effect_id):
			continue

		var record: ScheduleRecord = _exiting_effects[effect_id]
		# just in case, check for null record or effect instance, if either is null, remove from exiting queue and skip
		if record == null or record.effect == null:
			_remove_from_exiting(effect_id)
			continue

		_run_exit(record.effect)
		_remove_from_exiting(effect_id)

# Handling adding and removing to queues #

## Add an effect to the waiting queue
## @param effect_id: the unique ID assigned to the effect for tracking purposes
## @param record: the ScheduleRecord containing the effect instance and timing details
## @return: true if the effect was successfully added to the waiting queue, false if the queue size limit has been reached
func _add_to_waiting(effect_id, record: ScheduleRecord) -> bool:
	# check for null record or record being null, then effect instance before adding to queue
	if record == null or record.effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot add null effect to waiting queue.")
		return false

	# Check if the queue size limit has been reached before adding
	if len(_waiting_effects) >= max_queue_size:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Waiting queue is full. Cannot add effect: " + _effect_info_basic(record.effect))
		return false

	# Add the record to the waiting queue.
	_waiting_effects[effect_id] = record
	return true

## add an effect to the entering queue (effects that will call enter() this frame)
## @param effect_id: the unique ID assigned to the effect for tracking purposes
## @param record: the ScheduleRecord containing the effect instance and timing details
## @return: true if the effect was successfully added to the entering queue, false otherwise
func _add_to_entering(effect_id, record: ScheduleRecord) -> bool:
	# check for null record or effect instance before adding to queue
	if record == null or record.effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot add null effect to entering queue.")
		return false

	if _entering_effects.has(effect_id):
		if debug_logging:
			_log_generic(_scheduler_identifer + " Effect already exists in entering queue. Effect ID: " + str(effect_id))
		return false

	_entering_effects[effect_id] = record
	return true

## Add an effect to the active effects list
## @param effect_id: the unique ID assigned to the effect for tracking purposes
## @param record: the ScheduleRecord containing the effect instance and timing details
## @return: true if the effect was successfully added to the active effects list, false otherwise
func _add_to_active(effect_id, record: ScheduleRecord) -> bool:
	# check for null record or effect instance before adding to active list
	if record == null or record.effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot add null effect to active effects.")
		return false

	if _active_effects.has(effect_id):
		if debug_logging:
			_log_generic(_scheduler_identifer + " Effect already exists in active effects. Effect ID: " + str(effect_id))
		return false

	_active_effects[effect_id] = record
	return true

## Add an effect to the exiting queue
## @param effect_id: the unique ID assigned to the effect for tracking purposes
## @param record: the ScheduleRecord containing the effect instance and timing details
## @return: true if the effect was successfully added to the exiting queue, false otherwise
func _add_to_exiting(effect_id, record: ScheduleRecord) -> bool:
	# check for null record or effect instance before adding to exiting queue
	if record == null or record.effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot add null effect to exiting queue.")
		return false

	if _exiting_effects.has(effect_id):
		if debug_logging:
			_log_generic(_scheduler_identifer + " Effect already exists in exiting queue. Effect ID: " + str(effect_id))
		return false

	_exiting_effects[effect_id] = record
	return true

## Remove an effect from any queue or active list, used for manual removal or when an effect finishes
## @param effect_id: the unique ID assigned to the effect for tracking purposes
## @return: true if the effect was found and removed from queue, false if the effect was not found in the queue
func _remove_from_waiting(effect_id) -> bool:
	if _waiting_effects.has(effect_id):
		_waiting_effects.erase(effect_id)
		return true
	return false

## Remove an effect from the entering queue, used for manual removal or when an effect finishes
## @param effect_id: the unique ID assigned to the effect
## @return: true if the effect was found and removed from the entering queue, false if the effect was not found in the entering queue
func _remove_from_entering(effect_id) -> bool:
	if _entering_effects.has(effect_id):
		_entering_effects.erase(effect_id)
		return true
	return false

## Remove an effect from the active effects list, used for manual removal or when an effect finishes
## @param effect_id: the unique ID assigned to the effect
## @return: true if the effect was found and removed from the active effects list, false if the effect was not found in the active effects list
func _remove_from_active(effect_id) -> bool:
	if _active_effects.has(effect_id):
		_active_effects.erase(effect_id)
		return true
	return false

## Remove an effect from the exiting queue, used for manual removal or when an effect finishes
## @param effect_id: the unique ID assigned to the effect
## @return: true if the effect was found and removed from the exiting queue, false if the effect was not found in the exiting queue
func _remove_from_exiting(effect_id) -> bool:
	if _exiting_effects.has(effect_id):
		_exiting_effects.erase(effect_id)
		return true
	return false


## Moves an effect from waiting to entering and applies transition timestamps.
func _move_waiting_to_entering(effect_id) -> bool:
	if not _waiting_effects.has(effect_id):
		return false

	var record: ScheduleRecord = _waiting_effects[effect_id]
	record.start_time = Time.get_ticks_msec() / 1000.0
	record.is_waiting = false
	record.is_entering = true

	if not _add_to_entering(effect_id, record):
		return false

	return _remove_from_waiting(effect_id)


## Moves an effect from entering to active and applies transition timestamps.
func _move_entering_to_active(effect_id) -> bool:
	if not _entering_effects.has(effect_id):
		return false

	var record: ScheduleRecord = _entering_effects[effect_id]
	record.last_update_time = Time.get_ticks_msec() / 1000.0
	record.is_entering = false
	record.is_active = true

	if not _add_to_active(effect_id, record):
		return false

	return _remove_from_entering(effect_id)


## Moves an effect from entering to exiting and applies transition timestamps.
func _move_entering_to_exiting(effect_id) -> bool:
	if not _entering_effects.has(effect_id):
		return false

	var record: ScheduleRecord = _entering_effects[effect_id]
	record.exit_time = Time.get_ticks_msec() / 1000.0
	record.is_entering = false
	record.is_exiting = true

	if not _add_to_exiting(effect_id, record):
		return false

	return _remove_from_entering(effect_id)


## Moves an effect from active to exiting and applies transition timestamps.
func _move_active_to_exiting(effect_id) -> bool:
	if not _active_effects.has(effect_id):
		return false

	var record: ScheduleRecord = _active_effects[effect_id]
	record.exit_time = Time.get_ticks_msec() / 1000.0
	record.is_active = false
	record.is_exiting = true

	if not _add_to_exiting(effect_id, record):
		return false

	return _remove_from_active(effect_id)

# Effect Condition Checks #

## Checks whether an effect should start based on the effect conditions and scheduler rules.
## @return: true if the effect should start, false otherwise.
func _should_effect_start(effect: Effect) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot start null effect.")
		return false

	return true

## Checks whether an active effect should be stopped based on the effect conditions and scheduler rules.
## @return: true if the effect should be stopped, false otherwise.
func _should_effect_stop(effect: Effect) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot stop null effect.")

		return true

	return effect.is_finished()

## Checks whether an active effect should be updated based on the effect conditions and scheduler rules.
## @return: true if the effect should be updated, false otherwise.
func _should_effect_update(effect: Effect) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot update null effect.")

		return false

	if effect.is_cooldown_enabled() and effect.is_on_cooldown():
		return false

	return effect.is_active()

## Checks whether an active effect should have its physics_update called based on the effect conditions and scheduler rules.
## @return: true if the effect should have physics_update called, false otherwise.
func _should_effect_physics_update(effect: Effect) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot physics update null effect.")

		return false

	if effect.is_cooldown_enabled() and effect.is_on_cooldown():
		return false

	return effect.is_active()

## Checks whether a time-bound effect should end based on elapsed duration.
## @return: true if the effect has reached its end and should be stopped.
func _should_end_from_duration(effect: Effect, delta: float) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot check duration for null effect.")

		return true

	if effect.is_persistent():
		return false

	if not effect.is_timing_enabled():
		return false

	if effect.get_duration() <= 0.0:
		return true

	return effect.get_elapsed_time() + delta >= effect.get_duration()

## Checks whether an effect should run another cycle (also includes persistent effects).
## @return: true if the effect should repeat, false otherwise.
func _should_repeat(effect: Effect) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot check repeat for null effect.")

		return false

	if effect.is_persistent():
		return false

	if not effect.is_repeat_enabled():
		return false

	return effect.get_repeat_count() < effect.get_repeat_max()

# Effect Execution #

## Calls effect.enter() and performs scheduler-side setup.
func _run_enter(effect: Effect) -> void:
	if debug_logging:
		_log_effect_entered(effect.get_instance_id(), effect)
	effect.enter()


## Calls effect.exit() and performs scheduler-side cleanup.
func _run_exit(effect: Effect) -> void:
	if debug_logging:
		_log_effect_exited(effect.get_instance_id(), effect)
	effect.exit()


## Calls effect.update(delta) each frame.
func _run_update(effect: Effect, delta: float) -> void:
	if debug_logging and debug_log_active_effects:
		_log_effect_updated(effect.get_instance_id(), effect, delta)
	effect.update(delta)


## Calls effect.physics_update(delta) each physics frame.
func _run_physics_update(effect: Effect, delta: float) -> void:
	if debug_logging and debug_log_active_effects:
		_log_effect_updated(effect.get_instance_id(), effect, delta)
	effect.physics_update(delta)


# API Methods #

## Queues an effect to be processed by the scheduler
## if the max queue size has been reached, the effect will be rejected and not added to the queue.
## @return: true if the effect was successfully added to the queue, false if the queue is full and the effect was rejected.
func add_effect(effect: Effect) -> bool:
	if _unique_effect_exists_in_queues(effect):
		if debug_logging:
			_log_generic("Unique effect already exists. Cannot add duplicate effect: " + _effect_info_basic(effect))
		return false
	
	# generate id, create record, add to waiting queue, emit signal, return true if successful, false if queue is full
	var effect_id = _generate_unique_effect_id()
	var record = ScheduleRecord.new()
	record.effect = effect
	record.time_added = Time.get_ticks_msec() / 1000.0
	record.is_waiting = true
	if not _add_to_waiting(effect_id, record):
		# delete record to free memory since it won't be used
		record.free()
		return false
	emit_signal("effect_added", effect)
	return true


## Manually removes an effect from the scheduler by its instance reference.
func remove_effect_by_instance(effect: Effect) -> bool:
	return false

## Manually removes an effect from the scheduler by its unique effect ID.
func remove_effect_by_id(effect_id: int) -> bool:
	return false

## Manually removes the first effect found in the scheduler that matches the specified type.
func remove_effect_by_type(effect_type) -> bool:
	return false

## Manually removes all effects from the scheduler that match the specified type.
func remove_all_effects_of_type(effect_type) -> bool:
	return false

## Manually removes the first effect found in the scheduler that matches the specified name.
func remove_effect_by_name(effect_name: String) -> bool:
	return false

## Manually removes all effects from the scheduler that match the specified name.
func remove_all_effects_by_name(effect_name: String) -> bool:
	return false

## Manually removes all effects from the scheduler that match the specified type and name.
func remove_all_persistent_effects() -> void:
	pass

## Manually removes all effects from the scheduler that are not marked as persistent.
func remove_all_non_persistent_effects() -> void:
	pass

## Manually removes all effects from the scheduler that are marked as unique.
func remove_all_unique_effects() -> void:
	pass

## Manually removes all effects from the scheduler that are not marked as unique.
func remove_all_non_unique_effects() -> void:
	pass

## Manually removes all effects from the scheduler that have timing enabled, including both duration and cooldown timers.
func remove_all_timed_effects() -> void:
	pass

## Manually removes all effects from the scheduler that have no timing enabled.
func remove_all_non_timed_effects() -> void:
	pass

## Manually removes all effects from the scheduler that have repeating enabled
func remove_all_repeating_effects() -> void:
	pass

## Manually removes all effects from the scheduler that do not have repeating enabled
func remove_all_non_repeating_effects() -> void:
	pass

## Manually removes all effects from the scheduler, regardless of type, name, or properties.
func remove_all_effects() -> void:
	pass


## Returns a shallow copy of the list of currently active effects.
## @return: an array of active effect instances.
func get_waiting_effects() -> Array:
	return _waiting_effects.values()

## Returns a shallow copy of the list of currently entering effects.
## @return: an array of entering effect instances.
func get_entering_effects() -> Array:
	return _entering_effects.values()

## Returns a shallow copy of the list of currently active effects.
## @return: an array of active effect instances.
func get_active_effects() -> Array:
	return _active_effects.values()

## Returns a shallow copy of the list of currently exiting effects.
## @return: an array of exiting effect instances.
func get_exiting_effects() -> Array:
	return _exiting_effects.values()


# Debugging and Logging #

func _log_generic(message:String) -> void:
	if debug_logging:
		print(_scheduler_identifer + " " + message)

func _log_effect_entered(effect_id:int, effect:Effect) -> void:
	if debug_logging:
		# prints the effect id, type, name
		print(_scheduler_identifer + " Effect Entered: ID=" + str(effect_id) + ", " + _effect_info_basic(effect))

func _log_effect_exited(effect_id:int, effect:Effect) -> void:
	if debug_logging:
		# prints the effect id, type, and name
		print(_scheduler_identifer + " Effect Exited: ID=" + str(effect_id) + ", " + _effect_info_basic(effect))

func _log_effect_updated(effect_id:int, effect:Effect, delta:float)->void:
	if debug_logging:
		# prints the effect id, type, name, and delta time
		# newline, effect flags
		# newline, effect timing details
		print(_scheduler_identifer + " Effect Updated: ID=" + str(effect_id) + ", " + _effect_info_basic(effect) + ", Delta=" + str(delta))
		print("\t" + _effect_info_flags(effect))
		print("\t" + _effect_info_timing(effect))
		print("\t" + _effect_info_cooldown(effect))


## Returns a string representation of the effect
func _effect_info(effect_id:int, effect:Effect)->String:
	return "ID=" + str(effect_id) + ", " + _effect_info_basic(effect) + ", " + _effect_info_timing(effect) + ", " + _effect_info_flags(effect)

## Returns the basic details of effect as a string
## @return: a string representation of the effect's type and name
func _effect_info_basic(effect:Effect)->String:
	return "Type=" + str(effect.get_type()) + ", Name=" + effect.get_effect_name()

## Returns the timing details of effect as a string
## @return: a string representation of the effect's duration, elapsed time, repeat count, and repeat index
func _effect_info_timing(effect:Effect)->String:
	return "Duration: " + str(effect.get_duration()) + ", Elapsed: " + str(effect.get_elapsed_time()) + ", Repeat Count: " + str(effect.get_repeat_count()) + ", Repeat Index: " + str(effect.get_repeat_index())

func _effect_info_cooldown(effect:Effect)->String:
	return "Cooldown Duration: " + str(effect.get_cooldown_duration()) + ", Cooldown Elapsed: " + str(effect.get_cooldown_elapsed_time())

## Returns the flag details of effect as a string
## @return: a string representation of the effect's unique and persistent flags
func _effect_info_flags(effect:Effect)->String:
	return "Unique: " + str(effect.is_unique()) + ", Persistent: " + str(effect.is_persistent()) + ", Timing Enabled: " + str(effect.is_timing_enabled()) + ", On Cooldown: " + str(effect.is_on_cooldown()) + ", Repeating: " + str(effect.is_repeat_enabled())


# Effect updater methods #
# effects store internally information about their own timing and repeats, so they must be updated each frame to keep that info accurate

## Updates the effects internal info:
## - increments elapsed time (if applicable)
## - increments cooldown time (if applicable)
## - increments repeat count (if applicable)
## @return: false if the effect is finished and should be stopped, true otherwise
func _update_effect(effect:Effect, delta:float) -> bool:
	if effect == null:
		return false

	if effect.is_finished():
		return false

	if effect.is_timing_enabled():
		effect.increment_elapsed_time(delta)

	if effect.is_cooldown_enabled() and effect.is_on_cooldown():
		effect.increment_cooldown_elapsed(delta)

	# If one timed cycle completed and repeats are enabled, advance repeat and reset cycle timer.
	if effect.is_repeat_enabled() and effect.is_timing_enabled() and effect.get_duration() > 0.0:
		if effect.get_elapsed_time() >= effect.get_duration() and effect.get_repeat_count() < effect.get_repeat_max():
			effect.increment_repeat()
			effect.reset_timing()

	return not effect.is_finished()


# Query Methods #

## Checks if an effect is currently queued in the waiting queue, this does not include effects that are entering, active, or exiting.
## @param effect: the effect instance to check for in the waiting queue
## @return: true if the effect is found in the waiting queue, false otherwise
func is_effect_waiting(effect:Effect) -> bool:
	# null check
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot check if null effect is queued.")
			return false
	# pull effect record and check
	var record: ScheduleRecord = _get_effect_record(effect)
	if record != null and record.is_waiting:
		return true

	return false

## Checks if an effect is currently active, this includes effects entering or exiting.
## @param effect: the effect instance to check for activity
## @return: true if the effect is active, false otherwise
func is_effect_active(effect:Effect) -> bool:
	var record: ScheduleRecord = _get_effect_record(effect)
	if record != null and (record.is_entering or record.is_active or record.is_exiting):
		return true
	return false

## Checks if an effect is queued in the scheduler by type, this includes effects in any queue or active list.
## @param effect_type: the type of the effect to check for in the scheduler
## @return: true if an effect of the specified type is found in the scheduler, false otherwise
func has_effect_of_type(effect_type) -> bool:
	var record: ScheduleRecord
	# check waiting queue for effect_type
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return true
	# check entering queue for effect_type
		record = _entering_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return true
	# check active effects for effect_type
		record = _active_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return true
	# check exiting queue for effect_type
		record = _exiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return true
	return false

## Checks if an effect name exists in the scheduler by name, this includes effects in any queue or active list.
## @param effect_name: the name of the effect to check for in the scheduler
## @return: true if an effect of the specified name is found in the scheduler, false otherwise
func has_effect_of_name(effect_name: String) -> bool:
	var record: ScheduleRecord
	# check waiting queue for effect_name
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return true
	# check entering queue for effect_name
		record = _entering_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return true
	# check active effects for effect_name
		record = _active_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return true
	# check exiting queue for effect_name
		record = _exiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return true
	return false

## checks if an effect instance exists in the scheduler, this includes effects in any queue or active list.
## @param effect: the effect instance to check for in the scheduler
## @return: true if the effect instance is found in the scheduler, false otherwise
func has_effect(effect: Effect) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot check if null effect exists in scheduler.")
			return false
	# pull effect record and check
	var record: ScheduleRecord = _get_effect_record(effect)
	if record != null:
		return true
	return false

## Checks if an effect with the specified unique effect ID exists in the scheduler, this includes effects in any queue or active list.
## @param effect_id: the unique effect ID to check for in the scheduler
## @return: true if an effect with the specified ID is found in the scheduler, false otherwise
func has_effect_with_id(effect_id: int) -> bool:
	if effect_id < 0:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot check if effect with invalid ID exists in scheduler.")
			return false
	# check all queues and active list for effect_id
	if _waiting_effects.has(effect_id) or _entering_effects.has(effect_id) or _active_effects.has(effect_id) or _exiting_effects.has(effect_id):
		return true
	return false



# Retrieval Methods #


## Retrieves the unique effect ID for a given effect instance. This ID is used for tracking the effect within the scheduler.
## @param effect: the effect instance for which to retrieve the unique ID
## @return: the unique effect ID if found, or -1 if the effect is not found in the scheduler
func get_effect_id(effect: Effect) -> int:
	# first check for null
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot get effect ID for null effect.")
			return -1
		
	# first check if the effect is in the waiting queue	for effect_id
	var record: ScheduleRecord
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect == effect:
			return effect_id
	# then check entering queue	for effect_id
		record = _entering_effects[effect_id]
		if record != null and record.effect == effect:
			return effect_id
	# then check active effects	for effect_id
		record = _active_effects[effect_id]
		if record != null and record.effect == effect:
			return effect_id
	# then check exiting queue	for effect_id
		record = _exiting_effects[effect_id]
		if record != null and record.effect == effect:
			return effect_id
	return -1

## Retrieves the unique effect ID for the first effect found in the scheduler that matches the specified type. This includes effects in any queue or active list.
## @param effect_type: the type of the effect for which to retrieve the unique ID
## @return: the unique effect ID if found, or -1 if no effect of the specified type is found in the scheduler
func get_effect_id_by_type(effect_type:Effect.Type) -> int:
	var record: ScheduleRecord
	# check waiting queue for effect_id
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return effect_id
	# check entering queue for effect_id
		record = _entering_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return effect_id
	# check active effects for effect_id
		record = _active_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return effect_id
	# check exiting queue for effect_id
		record = _exiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return effect_id

	return -1

## Retrieves the unique effect ID for the first effect found in the scheduler that matches the specified name. This includes effects in any queue or active list.
## @param effect_name: the name of the effect for which to retrieve the unique ID
## @return: the unique effect ID if found, or -1 if no effect of the specified name is found in the scheduler
func get_effect_id_by_name(effect_name: String) -> int:
	var record: ScheduleRecord
	# check waiting queue for effect_id
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return effect_id
	# check entering queue for effect_id
		record = _entering_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return effect_id
	# check active effects for effect_id
		record = _active_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return effect_id
	# check exiting queue for effect_id
		record = _exiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return effect_id

	return -1

## Retrieves an effect instance from the scheduler by its unique effect ID. This includes effects in any queue or active list.
## @param effect_id: the unique ID of the effect to retrieve
## @return: the effect instance if found, or null if no effect with the specified ID is found in the scheduler
func get_effect_by_id(effect_id: int) -> Effect:
	var record: ScheduleRecord
	# check waiting queue for effect_id
	if _waiting_effects.has(effect_id):
		record = _waiting_effects[effect_id]
		if record != null:
			return record.effect
	# check entering queue for effect_id
	if _entering_effects.has(effect_id):
		record = _entering_effects[effect_id]
		if record != null:
			return record.effect
	# check active effects for effect_id
	if _active_effects.has(effect_id):
		record = _active_effects[effect_id]
		if record != null:
			return record.effect
	# check exiting queue for effect_id
	if _exiting_effects.has(effect_id):
		record = _exiting_effects[effect_id]
		if record != null:
			return record.effect
	return null

## Retrieves the first effect instance found in the scheduler that matches the specified type. This includes effects in any queue or active list.
## @param effect_type: the type of the effect to retrieve
## @return: the effect instance if found, or null if no effect of the specified type is found in the scheduler
func get_effect_by_type(effect_type:Effect.Type) -> Effect:
	# check waiting queue for effect_type
	var record: ScheduleRecord
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return record.effect
	# check entering queue for effect_type
		record = _entering_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return record.effect
	# check active effects for effect_type
		record = _active_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return record.effect
	# check exiting queue for effect_type
		record = _exiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			return record.effect
	return null

## Retrieves all effect instances found in the scheduler that match the specified type. This includes effects in any queue or active list.
## @param effect_type: the type of the effects to retrieve
## @return: an array of effect instances that match the specified type, or an empty array if no effects of the specified type are found in the scheduler
func get_effects_by_type(effect_type:Effect.Type) -> Array:
	var effects: Array = []
	var record: ScheduleRecord
	# check waiting queue for effect_type
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			effects.append(record.effect)
	# check entering queue for effect_type
		record = _entering_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			effects.append(record.effect)
	# check active effects for effect_type
		record = _active_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			effects.append(record.effect)
	# check exiting queue for effect_type
		record = _exiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_type() == effect_type:
			effects.append(record.effect)
	return effects

## Retrieves the first effect instance found in the scheduler that matches the specified name. This includes effects in any queue or active list.
## @param effect_name: the name of the effect to retrieve
## @return: the effect instance if found, or null if no effect of the specified name is found in the scheduler
func get_effect_by_name(effect_name: String) -> Effect:
	# check waiting queue for effect_name
	var record: ScheduleRecord
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return record.effect
	# check entering queue for effect_name
		record = _entering_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return record.effect
	# check active effects for effect_name
		record = _active_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return record.effect
	# check exiting queue for effect_name
		record = _exiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			return record.effect
	return null

## Retrieves all effect instances found in the scheduler that match the specified name. This includes effects in any queue or active list.
## @param effect_name: the name of the effects to retrieve
## @return: an array of effect instances that match the specified name, or an empty array if no effects of the specified name are found in the scheduler
func get_effects_by_name(effect_name: String) -> Array:
	var effects: Array = []
	var record: ScheduleRecord
	# check waiting queue for effect_name
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			effects.append(record.effect)
	# check entering queue for effect_name
		record = _entering_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			effects.append(record.effect)
	# check active effects for effect_name
		record = _active_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			effects.append(record.effect)
	# check exiting queue for effect_name
		record = _exiting_effects[effect_id]
		if record != null and record.effect != null and record.effect.get_name() == effect_name:
			effects.append(record.effect)
	return effects

## Retrieves the scheduler record details for a given effect instance. This includes effects in any queue or active list.
## @param effect: the effect instance for which to retrieve the scheduler record details
## @return: a record containing the scheduler record details for the effect if found, or null if the effect is not found in the scheduler
func _get_effect_record(effect: Effect) -> ScheduleRecord:
	if effect == null:
		return null
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for record in queue.values():
			if record != null and record.effect == effect:
				return record
	return null

## Returns the scheduler record details for an effect by its unique effect ID.
## @param effect_id: the unique ID of the effect for which to retrieve the scheduler record details
## @return: a record containing the scheduler record details for the effect if found, or null if no effect with the specified ID is found in the scheduler
func get_effect_record_by_id(effect_id: int) -> ScheduleRecord:
	if _waiting_effects.has(effect_id):
		return _waiting_effects[effect_id]
	if _entering_effects.has(effect_id):
		return _entering_effects[effect_id]
	if _active_effects.has(effect_id):
		return _active_effects[effect_id]
	if _exiting_effects.has(effect_id):
		return _exiting_effects[effect_id]
	return null

## Returns the scheduler record details for the first effect found in the scheduler that matches the specified type.
## @param effect_type: the type of the effect for which to retrieve the scheduler record details
## @return: a record containing the scheduler record details for the effect if found, or null if no effect of the specified type is found in the scheduler
func get_effect_record_by_effect(effect: Effect) -> ScheduleRecord:
	if effect == null:
		return null
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for record in queue.values():
			if record != null and record.effect == effect:
				return record
	return null

## Returns the scheduler record details for the first effect found in the scheduler that matches the specified name.
## @param effect_name: the name of the effect for which to retrieve the scheduler record details
## @return: a record containing the scheduler record details for the effect if found, or null if no effect of the specified name is found in the scheduler
func get_effect_record_by_name(effect_name: String) -> ScheduleRecord:
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for record in queue.values():
			if record != null and record.effect != null and record.effect.get_effect_name() == effect_name:
				return record
	return null

# Utility Methods #


## Generates a unique effect ID for tracking purposes.
## NOTE: This method uses a simple counter that resets after reaching a maximum value to prevent overflow.
## @return: a unique integer ID for the effect
func _generate_unique_effect_id() -> int:
	var id = _effect_id_counter
	_effect_id_counter += 1
	# Reset the counter if it exceeds the maximum to prevent overflow, allows for reuse of IDs after a large number of effects have been processed.
	if _effect_id_counter >= _effect_id_max:
		_effect_id_counter = 0
	# check for collision with existing effect IDs in all queues and active list, if collision occurs, increment until a unique ID is found
	while _waiting_effects.has(id) or _entering_effects.has(id) or _active_effects.has(id) or _exiting_effects.has(id):
		id += 1
		# if we reached end, loop back to 0
		if id >= _effect_id_max:
			id = 0

	return id

## Checks if an effect is unique and if an instance of the same type already exists in any queue or active list.
## NOTE: internally checks if effect is unique before iterating
## @param effect: the effect instance to check for uniqueness
## @return: true if the effect is unique and an instance of the same type already exists
func _unique_effect_exists_in_queues(effect:Effect) -> bool:
	# Check if the effect is unique and if an instance of the same type already exists in any queue or active list
	if effect.is_unique():
		for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
			for existing_record in queue.values():
				if existing_record.effect.get_type() == effect.get_type():
					return true
	return false
