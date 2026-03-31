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
## Master enable/disable switch for the entire EffectScheduler. When disabled, the scheduler will not process any effects, but they will remain in their queues and can be resumed when re-enabled.
@export var is_enabled: bool = true

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
	# The unique ID assigned to the effect for tracking purposes.
	var id: int = 0
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
	var is_paused:bool = false

## The next candidate ID to try when no recycled IDs are available.
var _next_effect_id: int = 0

## A stack of freed IDs that can be reused quickly.
var _free_effect_ids: Array[int] = []

## max number of unique IDs before resetting the counter to prevent overflow. 
const _effect_id_max:int = 1048576
## IDs currently in use by effects in the scheduler.
var _used_effect_ids: Dictionary = {} # {Effect_ID: true}
## IDs blocked from allocation (for special/manual reservation use-cases).
var _reserved_effect_ids: Dictionary = {} # {Effect_ID: true}

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

func _process(delta: float) -> void:
	# Only process if scheduler is enabled
	if not is_enabled:
		return
	_process_waiting_effects()
	_process_entering_effects()
	_process_active_effects(delta * time_scale, false)
	_process_exiting_effects()


func _physics_process(delta: float) -> void:
	# Only process if scheduler is enabled
	if not is_enabled:
		return
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
			_recycle_effect_id(effect_id)
			continue

		# if the effect is paused, skip processing it but keep it in the waiting queue so it can be resumed later
		if record.is_paused:
			continue

		# Marked-done effects should not progress through any queues.
		if record.effect.is_marked_done():
			_remove_from_waiting(effect_id)
			_recycle_effect_id(effect_id)
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
			_recycle_effect_id(effect_id)
			continue

		# if the effect is paused, skip processing it but keep it in the entering queue so it can be resumed later
		if record.is_paused:
			continue

		# Marked done effects should not run enter()
		if record.effect.is_marked_done():
			_remove_from_entering(effect_id)
			_recycle_effect_id(effect_id)
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
			_recycle_effect_id(effect_id)
			continue

		# if the effect is paused, skip processing it but keep it in the active effects list so it can be resumed later
		if record.is_paused:
			continue

		var effect: Effect = record.effect

		# Marked-done effects are immediately advanced to exiting.
		if effect.is_marked_done():
			_move_active_to_exiting(effect_id)
			continue

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
			_recycle_effect_id(effect_id)
			continue

		# if the effect is paused, skip processing it but keep it in the exiting queue so it can be resumed later
		if record.is_paused:
			continue

		_run_exit(record.effect)
		_remove_from_exiting(effect_id)
		_recycle_effect_id(effect_id)

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
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot enter null effect.")
		return
	if debug_logging:
		_log_effect_entered(effect.get_instance_id(), effect)
	effect.enter()


## Calls effect.exit() and performs scheduler-side cleanup.
func _run_exit(effect: Effect) -> void:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot exit null effect.")
		return
	if debug_logging:
		_log_effect_exited(effect.get_instance_id(), effect)
	effect.exit()


## Calls effect.update(delta) each frame.
func _run_update(effect: Effect, delta: float) -> void:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot update null effect.")
		return
	if debug_logging and debug_log_active_effects:
		_log_effect_updated(effect.get_instance_id(), effect, delta)
	effect.update(delta)


## Calls effect.physics_update(delta) each physics frame.
func _run_physics_update(effect: Effect, delta: float) -> void:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot physics update null effect.")
		return
	if debug_logging and debug_log_active_effects:
		_log_effect_updated(effect.get_instance_id(), effect, delta)
	effect.physics_update(delta)


# API Methods #

## Enables the scheduler, allowing it to process effects in its queues. When enabled, the scheduler will continue processing effects as normal.
func enable_scheduler() -> void:
	is_enabled = true

## Disables the scheduler, preventing any effects from being processed.
func disable_scheduler() -> void:
	is_enabled = false

## Queues an effect to be processed by the scheduler
## if the max queue size has been reached, the effect will be rejected and not added to the queue.
## @param effect: the effect instance to be added to the scheduler
## @param reserved_id: if an id has been reserved for this effect, it can be added here, note that if queue is already at capacity, adding the effect will be rejected and the reserved id will not be used.
## @return: true if the effect was successfully added to the queue, false if the queue is full and the effect was rejected.
func add_effect(effect: Effect, reserved_id: int = -1) -> bool:
	if _unique_effect_exists_in_queues(effect):
		if debug_logging:
			_log_generic(_scheduler_identifer + " Unique effect already exists. Cannot add duplicate effect: " + _effect_info_basic(effect))
		return false
	
	# generate id, create record, add to waiting queue, emit signal, return true if successful, false if queue is full
	# attempts to generate id, if there isnt room, it will return -1 and the effect will be rejected to prevent infinite loop
	var effect_id = reserved_id
	var consumed_reservation := false
	if effect_id == -1:
		effect_id = _allocate_effect_id()
	else:
		# Reserved IDs must transition from reserved -> registered before queueing.
		if is_effect_id_reserved(effect_id):
			consumed_reservation = true
			unreserve_effect_id(effect_id)
		if not _register_effect_id(effect_id):
			if consumed_reservation:
				reserve_effect_id(effect_id)
			if debug_logging:
				_log_generic(_scheduler_identifer + " Failed to register provided effect ID. Effect will be rejected: " + _effect_info_basic(effect))
			return false
	if effect_id == -1:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Failed to generate unique effect ID. Effect will be rejected: " + _effect_info_basic(effect))
		return false
	var record = ScheduleRecord.new()
	record.effect = effect
	record.time_added = Time.get_ticks_msec() / 1000.0
	record.id = effect_id
	record.is_waiting = true
	if not _add_to_waiting(effect_id, record):
		# delete record to free memory since it won't be used
		_recycle_effect_id(effect_id)
		if consumed_reservation:
			reserve_effect_id(effect_id)
		if debug_logging:
			_log_generic(_scheduler_identifer + " Failed to add effect to waiting queue. Effect will be rejected: " + _effect_info_basic(effect))
		return false
	emit_signal("effect_added", effect)
	return true

## Pauses an active effect by its unique effect ID. The effect will not be processed until it is resumed.
## @param effect_id: the unique ID assigned to the effect
## @return: true if the effect was found and paused, false if the effect was not found or could not be paused.
func pause_effect(effect_id: int) -> bool:
	var record: ScheduleRecord = get_effect_record_by_id(effect_id)
	if record != null:
		record.is_paused = true
		if debug_logging:
			_log_generic(_scheduler_identifer + " Paused effect: " + _effect_info_basic(record.effect))
		return true

	return false

## Resumes a paused effect by its unique effect ID. The effect will continue to be processed by the scheduler.
## @param effect_id: the unique ID assigned to the effect
## @return: true if the effect was found and resumed, false if the effect was not found or could not be resumed.
func resume_effect(effect_id: int) -> bool:
	var record: ScheduleRecord = get_effect_record_by_id(effect_id)
	if record != null:
		record.is_paused = false
		if debug_logging:
			_log_generic(_scheduler_identifer + " Resumed effect: " + _effect_info_basic(record.effect))
		return true

	return false

## Pauses all effects in the scheduler. Paused effects will remain in their current state until they are resumed.
## NOTE: This only applies to effects already in the scheduler. If an effect is added while the scheduler is paused, it will be added in a normal state and will not be automatically paused.
## @return: true if there were effects to pause and they were successfully paused, false if there were no effects to pause.
func pause_all_effects() -> bool:
	if debug_logging:
		_log_generic(_scheduler_identifer + " Pausing all effects.")
	if _waiting_effects.is_empty() and _entering_effects.is_empty() and _active_effects.is_empty() and _exiting_effects.is_empty():
		return false

	for effect_id in _waiting_effects.keys():
		pause_effect(effect_id)
	for effect_id in _entering_effects.keys():
		pause_effect(effect_id)
	for effect_id in _active_effects.keys():
		pause_effect(effect_id)
	for effect_id in _exiting_effects.keys():
		pause_effect(effect_id)

	return true

## Resumes all effects in the scheduler so they can continue being processed.
## @return: true if there were effects to resume, false if there were no effects in the scheduler.
func resume_all_effects() -> bool:
	if debug_logging:
		_log_generic(_scheduler_identifer + " Resuming all effects.")
	if _waiting_effects.is_empty() and _entering_effects.is_empty() and _active_effects.is_empty() and _exiting_effects.is_empty():
		return false

	for effect_id in _waiting_effects.keys():
		resume_effect(effect_id)
	for effect_id in _entering_effects.keys():
		resume_effect(effect_id)
	for effect_id in _active_effects.keys():
		resume_effect(effect_id)
	for effect_id in _exiting_effects.keys():
		resume_effect(effect_id)

	return true

## Manually removes an effect from the scheduler by its instance reference.
## @param effect: the effect instance to be removed from the scheduler
## @return: true if the effect was found and removed from the scheduler, false if the effect was not found in the scheduler or could not be removed.
func remove_effect_by_instance(effect: Effect) -> bool:
	var record: ScheduleRecord = get_effect_record_by_instance(effect)
	if record != null:
		var result: bool = remove_effect_by_id(record.id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed effect by instance: " + _effect_info_basic(effect))
		return result
	return false

## Manually removes an effect from the scheduler by its unique effect ID.
## @param effect_id: the unique ID assigned to the effect for tracking purposes
## @return: true if the effect was found and removed from the scheduler, false if the effect was not found in the scheduler or could not be removed.
func remove_effect_by_id(effect_id: int) -> bool:
	var record: ScheduleRecord = get_effect_record_by_id(effect_id)
	if record != null:
		var effect: Effect = record.effect
		var result: bool = _remove_effect_from_scheduler(effect_id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed effect by ID: " + _effect_info_basic(effect))
		emit_signal("effect_removed", effect)
		return result
	return false

## Manually removes the first effect found in the scheduler that matches the specified type.
## @param effect_type: the type of effect to be removed from the scheduler
## @return: true if an effect of the specified type was found and removed from the scheduler, false if no effect of the specified type was found in the scheduler or could be removed.
func remove_effect_by_type(effect_type:Effect.Type) -> bool:
	var record:ScheduleRecord = get_effect_record_by_instance(get_effect_by_type(effect_type))
	if record != null:
		# removes the first effect found of the specified type
		var effect: Effect = record.effect
		var result: bool = remove_effect_by_id(record.id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed effect by type: " + _effect_info_basic(effect))
		return result
	return false

## Manually removes all effects from the scheduler that match the specified type.
## @param effect_type: the type of effects to be removed from the scheduler
## @return: true if at least one effect of the specified type was found and removed from the scheduler, false if no effects of the specified type were found in the scheduler or could be removed
func remove_all_effects_of_type(effect_type:Effect.Type) -> bool:
	var records:Array = get_all_records_by_type(effect_type)
	var result: bool = false
	for record in records:
		var effect_id = record.id
		result = remove_effect_by_id(effect_id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed effect by type: " + _effect_info_basic(record.effect))
		emit_signal("effect_removed", record.effect)
	return result

## Manually removes the first effect found in the scheduler that matches the specified name.
## @param effect_name: the name of the effect to be removed from the scheduler
## @return: true if an effect of the specified name was found and removed from the scheduler, false if no effect of the specified name was found in the scheduler or could be removed.
func remove_effect_by_name(effect_name: String) -> bool:
	var record:ScheduleRecord = get_effect_record_by_instance(get_effect_by_name(effect_name))
	if record != null:	# removes the first effect found of the specified name
		var effect: Effect = record.effect
		var effect_id = record.id
		var result: bool = false
		result = remove_effect_by_id(effect_id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed effect by name: " + _effect_info_basic(effect))
		emit_signal("effect_removed", effect)
		return result
	return false

## Manually removes all effects from the scheduler that match the specified name.
## @param effect_name: the name of the effects to be removed from the scheduler
## @return: true if at least one effect of the specified name was found and removed from
func remove_all_effects_by_name(effect_name: String) -> bool:
	var records:Array = get_all_records_by_name(effect_name)
	var result: bool = false
	for record in records:
		var effect_id = record.id
		result = remove_effect_by_id(effect_id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed effect by name: " + _effect_info_basic(record.effect))
		emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler that match the specified type and name.
## @return: true if at least one effect matching the specified type and name was found and removed from the scheduler, false if no effects matching the specified type and name were found in the scheduler
func remove_all_persistent_effects() -> bool:
	var records:Array = get_all_persistent_records()
	var result: bool = false
	for record in records:
		var effect_id = record.id
		result = remove_effect_by_id(effect_id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed persistent effect: " + _effect_info_basic(record.effect))
		emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler that are not marked as persistent.
## @return: true if at least one non-persistent effect was found and removed from the scheduler, false if no non-persistent effects were found in the scheduler or could be removed.
func remove_all_non_persistent_effects() -> bool:
	var records:Array = get_all_records()
	var result: bool = false
	for record in records:
		if not record.effect.is_persistent():
			var effect_id = record.id
			result = remove_effect_by_id(effect_id)
			if debug_logging and result:
				_log_generic(_scheduler_identifer + " Removed non-persistent effect: " + _effect_info_basic(record.effect))
			emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler that are marked as unique.
## @return: true if at least one unique effect was found and removed from the scheduler, false if no unique effects were found in the scheduler or could be removed.
func remove_all_unique_effects() -> bool:
	var records:Array = get_all_unique_records()
	var result: bool = false
	for record in records:
		var effect_id = record.id
		result = remove_effect_by_id(effect_id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed unique effect: " + _effect_info_basic(record.effect))
		emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler that are not marked as unique.
## @return: true if at least one non-unique effect was found and removed from the scheduler, false if no non-unique effects were found in the scheduler or could be removed.
func remove_all_non_unique_effects() -> bool:
	var records:Array = get_all_records()
	var result: bool = false
	for record in records:
		if not record.effect.is_unique():
			var effect_id = record.id
			result = remove_effect_by_id(effect_id)
			if debug_logging and result:
				_log_generic(_scheduler_identifer + " Removed non-unique effect: " + _effect_info_basic(record.effect))
			emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler that have timing enabled, including both duration and cooldown timers.
## @return: true if at least one effect with timing enabled was found and removed from the scheduler, false if no effects with timing enabled were found in the scheduler or could be removed.
func remove_all_timed_effects() -> bool:
	var records:Array = get_all_records()
	var result: bool = false
	for record in records:
		if record.effect.is_timing_enabled():
			var effect_id = record.id
			result = remove_effect_by_id(effect_id)
			if debug_logging and result:
				_log_generic(_scheduler_identifer + " Removed timed effect: " + _effect_info_basic(record.effect))
			emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler that have no timing enabled.
## @return: true if at least one effect with no timing enabled was found and removed from the scheduler, false if no effects with no timing enabled were found in the scheduler or could be removed.
func remove_all_non_timed_effects() -> bool:
	var records:Array = get_all_records()
	var result: bool = false
	for record in records:
		if not record.effect.is_timing_enabled():
			var effect_id = record.id
			result = remove_effect_by_id(effect_id)
			if debug_logging and result:
				_log_generic(_scheduler_identifer + " Removed non-timed effect: " + _effect_info_basic(record.effect))
			emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler that have repeating enabled
## @return: true if at least one repeating effect was found and removed from the scheduler, false if no repeating effects were found in the scheduler or could be removed.
func remove_all_repeating_effects() -> bool:
	var records:Array[ScheduleRecord] = get_all_records()
	if records.is_empty():
		return false
	var result: bool = false
	for record in records:
		if record.effect.is_repeat_enabled():
			var effect_id = record.id
			result = remove_effect_by_id(effect_id)
			if debug_logging and result:
				_log_generic(_scheduler_identifer + " Removed repeating effect: " + _effect_info_basic(record.effect))
			emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler that do not have repeating enabled
## @return: true if at least one non-repeating effect was found and removed from the scheduler, false if no non-repeating effects were found in the scheduler or could be removed.
func remove_all_non_repeating_effects() -> bool:
	var records:Array[ScheduleRecord] = get_all_records()
	if records.is_empty():
		return false
	var result: bool = false
	for record in records:
		if not record.effect.is_repeat_enabled():
			var effect_id = record.id
			result = remove_effect_by_id(effect_id)
			if debug_logging and result:
				_log_generic(_scheduler_identifer + " Removed non-repeating effect: " + _effect_info_basic(record.effect))
			emit_signal("effect_removed", record.effect)
	return result

## Manually removes all effects from the scheduler, regardless of type, name, or properties.
## @return: true if at least one effect was found and removed from the scheduler, false if no effects were found in the scheduler or could be removed.
func remove_all_effects() -> bool:
	var records:Array[ScheduleRecord] = get_all_records()
	if records.is_empty():
		return false
	var result: bool = false
	for record in records:
		var effect_id = record.id
		result = remove_effect_by_id(effect_id)
		if debug_logging and result:
			_log_generic(_scheduler_identifer + " Removed effect: " + _effect_info_basic(record.effect))
		emit_signal("effect_removed", record.effect)
	return result


## Returns a shallow copy of the list of currently active effects.
## @return: an array of active effect instances.
func get_waiting_effects() -> Array:
	var effects:Array = []
	for record in _waiting_effects.values():
		if record != null and record.effect != null:
			effects.append(record.effect)
	return effects

## Returns a shallow copy of the list of currently entering effects.
## @return: an array of entering effect instances.
func get_entering_effects() -> Array:
	var effects:Array = []
	for record in _entering_effects.values():
		if record != null and record.effect != null:
			effects.append(record.effect)
	return effects

## Returns a shallow copy of the list of currently active effects.
## @return: an array of active effect instances.
func get_active_effects() -> Array:
	var effects:Array = []
	for record in _active_effects.values():
		if record != null and record.effect != null:
			effects.append(record.effect)
	return effects

## Returns a shallow copy of the list of currently exiting effects.
## @return: an array of exiting effect instances.
func get_exiting_effects() -> Array:
	var effects:Array = []
	for record in _exiting_effects.values():
		if record != null and record.effect != null:
			effects.append(record.effect)
	return effects


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

	# only update effects currently tracked by this scheduler.
	if _get_effect_record(effect) == null:
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
## NOTE: A paused effect will still be considered waiting if it is in the waiting queue, since paused effects should still be processed by the scheduler to check for conditions to transition to entering.
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
## NOTE: A paused effect will not be considered active even if it is in the active queue, since paused effects should not be processed by the scheduler until they are resumed.
## @param effect: the effect instance to check for activity
## @return: true if the effect is active, false otherwise
func is_effect_active(effect:Effect) -> bool:
	var record: ScheduleRecord = _get_effect_record(effect)
	if record == null or record.is_paused:
		return false
	if record.is_entering or record.is_active or record.is_exiting:
		return true
	return false

## Checks if an effect is queued in the scheduler by type, this includes effects in any queue or active list.
## @param effect_type: the type of the effect to check for in the scheduler
## @return: true if an effect of the specified type is found in the scheduler, false otherwise
func has_effect_of_type(effect_type) -> bool:
	var record: ScheduleRecord
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			record = queue[effect_id]
			if record != null and record.effect != null and record.effect.get_type() == effect_type:
				return true
	return false

## Checks if an effect name exists in the scheduler by name, this includes effects in any queue or active list.
## @param effect_name: the name of the effect to check for in the scheduler
## @return: true if an effect of the specified name is found in the scheduler, false otherwise
func has_effect_of_name(effect_name: String) -> bool:
	var record: ScheduleRecord
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			record = queue[effect_id]
			if record != null and record.effect != null and record.effect.get_effect_name() == effect_name:
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
	return _used_effect_ids.has(effect_id)

## Checks if an effect is currently paused, this includes effects in any queue or active list.
## @param effect: the effect instance to check for paused status
## @return: true if the effect is paused, false otherwise
func is_effect_paused(effect: Effect) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot check if null effect is paused.")
		return false
	# pull effect record and check
	var record: ScheduleRecord = _get_effect_record(effect)
	if record != null:
		return record.is_paused
	return false

## Checks if the scheduler is currently enabled, allowing it to process effects in its queues.
## @return: true if the scheduler is enabled, false otherwise
func is_scheduler_enabled() -> bool:
	return is_enabled

## Checks if the scheduler is currently disabled, preventing it from processing any effects in its queues.
## @return: true if the scheduler is disabled, false otherwise
func is_scheduler_disabled() -> bool:
	return not is_enabled

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

	# first check if the effect is in the waiting queue
	var record: ScheduleRecord
	for effect_id in _waiting_effects.keys():
		record = _waiting_effects[effect_id]
		if record != null and record.effect == effect:
			return effect_id

	# then check entering queue
	for effect_id in _entering_effects.keys():
		record = _entering_effects[effect_id]
		if record != null and record.effect == effect:
			return effect_id

	# then check active effects
	for effect_id in _active_effects.keys():
		record = _active_effects[effect_id]
		if record != null and record.effect == effect:
			return effect_id

	# then check exiting queue
	for effect_id in _exiting_effects.keys():
		record = _exiting_effects[effect_id]
		if record != null and record.effect == effect:
			return effect_id
	return -1

## Retrieves the unique effect ID for the first effect found in the scheduler that matches the specified type. This includes effects in any queue or active list.
## @param effect_type: the type of the effect for which to retrieve the unique ID
## @return: the unique effect ID if found, or -1 if no effect of the specified type is found in the scheduler
func get_effect_id_by_type(effect_type:Effect.Type) -> int:
	var record: ScheduleRecord
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			record = queue[effect_id]
			if record != null and record.effect != null and record.effect.get_type() == effect_type:
				return effect_id

	return -1

## Retrieves the unique effect ID for the first effect found in the scheduler that matches the specified name. This includes effects in any queue or active list.
## @param effect_name: the name of the effect for which to retrieve the unique ID
## @return: the unique effect ID if found, or -1 if no effect of the specified name is found in the scheduler
func get_effect_id_by_name(effect_name: String) -> int:
	var record: ScheduleRecord
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			record = queue[effect_id]
			if record != null and record.effect != null and record.effect.get_effect_name() == effect_name:
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
	var record: ScheduleRecord
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			record = queue[effect_id]
			if record != null and record.effect != null and record.effect.get_type() == effect_type:
				return record.effect
	return null

## Retrieves all effect instances found in the scheduler that match the specified type. This includes effects in any queue or active list.
## @param effect_type: the type of the effects to retrieve
## @return: an array of effect instances that match the specified type, or an empty array if no effects of the specified type are found in the scheduler
func get_effects_by_type(effect_type:Effect.Type) -> Array:
	var effects: Array = []
	var record: ScheduleRecord
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			record = queue[effect_id]
			if record != null and record.effect != null and record.effect.get_type() == effect_type:
				effects.append(record.effect)
	return effects

## Retrieves the first effect instance found in the scheduler that matches the specified name. This includes effects in any queue or active list.
## @param effect_name: the name of the effect to retrieve
## @return: the effect instance if found, or null if no effect of the specified name is found in the scheduler
func get_effect_by_name(effect_name: String) -> Effect:
	var record: ScheduleRecord
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			record = queue[effect_id]
			if record != null and record.effect != null and record.effect.get_effect_name() == effect_name:
				return record.effect
	return null

## Retrieves all effect instances found in the scheduler that match the specified name. This includes effects in any queue or active list.
## @param effect_name: the name of the effects to retrieve
## @return: an array of effect instances that match the specified name, or an empty array if no effects of the specified name are found in the scheduler
func get_effects_by_name(effect_name: String) -> Array:
	var effects: Array = []
	var record: ScheduleRecord
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			record = queue[effect_id]
			if record != null and record.effect != null and record.effect.get_effect_name() == effect_name:
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
func get_effect_record_by_instance(effect: Effect) -> ScheduleRecord:
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

## Returns a list of scheduler record details for all effects found in the scheduler that match the specified type.
## @param effect_type: the type of the effects for which to retrieve the scheduler record details
## @return: an array of records containing the scheduler record details for all effects that match the specified type
func get_all_records_by_type(effect_type:Effect.Type) -> Array[ScheduleRecord]:
	var records: Array[ScheduleRecord] = []
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			var record: ScheduleRecord = queue[effect_id]
			if record == null or record.effect == null:
				continue
			if record.effect.get_type() == effect_type:
				records.append(record)
	return records

## Returns a list of scheduler record details for all effects found in the scheduler that match the specified name.
## @param effect_name: the name of the effects for which to retrieve the scheduler record details
## @return: an array of records containing the scheduler record details for all effects that match the specified name
func get_all_records_by_name(effect_name: String) -> Array[ScheduleRecord]:
	var records: Array[ScheduleRecord] = []
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			var record: ScheduleRecord = queue[effect_id]
			if record == null or record.effect == null:
				continue
			if record.effect.get_effect_name() == effect_name:
				records.append(record)
	return records

## Returns a list of scheduler record details for all effects found in the scheduler that are marked as persistent.
## @return: an array of records containing the scheduler record details for all effects that are marked as persistent
func get_all_persistent_records() -> Array[ScheduleRecord]:
	var records: Array[ScheduleRecord] = []
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			var record: ScheduleRecord = queue[effect_id]
			if record != null and record.effect != null and record.effect.is_persistent():
				records.append(record)
	return records

## Returns a list of scheduler record details for all effects found in the scheduler that are marked as unique.
## @return: an array of records containing the scheduler record details for all effects that are marked as unique
func get_all_unique_records() -> Array[ScheduleRecord]:
	var records: Array[ScheduleRecord] = []
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			var record: ScheduleRecord = queue[effect_id]
			if record != null and record.effect != null and record.effect.is_unique():
				records.append(record)
	return records

## Returns a list of scheduler record details for all effects currently in the scheduler
## @return: an array of records containing the scheduler record details for all effects currently in the scheduler
func get_all_records() -> Array[ScheduleRecord]:
	var records: Array[ScheduleRecord] = []
	for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
		for effect_id in queue.keys():
			var record: ScheduleRecord = queue[effect_id]
			if record != null:
				records.append(record)
	return records

# Utility Methods #


## Allocates and registers the next usable effect ID.
## NOTE: IDs are sourced from recycled IDs first, then sequential scan candidates.
## @return: a registered effect ID, or -1 if allocation fails.
func _allocate_effect_id() -> int:
	var effect_id := get_id_next_available()
	if effect_id == -1:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Unable to generate unique effect ID after full scan.")
		return -1
	if not _register_effect_id(effect_id):
		if debug_logging:
			_log_generic(_scheduler_identifer + " Failed to register generated effect ID: " + str(effect_id))
		return -1
	return effect_id

## Backward-compatible alias for _allocate_effect_id().
func _generate_unique_effect_id() -> int:
	return _allocate_effect_id()

## Recycles a registered ID by unregistering it.
## NOTE: Unregistered IDs are pushed back to the free pool unless still reserved.
## @param effect_id: the unique effect ID to recycle
func _recycle_effect_id(effect_id: int) -> bool:
	# if id is invalid or not currently registered, cannot recycle
	if not _is_valid_effect_id(effect_id) or not _used_effect_ids.has(effect_id):
		return false
	unregister_effect_id(effect_id)
	return true

## Removes an effect from all scheduler states and recycles its ID.
## @param effect_id: the unique effect ID of the effect to remove
## @return: true if the effect was removed, false otherwise
func _remove_effect_from_scheduler(effect_id: int) -> bool:
	if _remove_from_waiting(effect_id) or _remove_from_entering(effect_id) or _remove_from_active(effect_id) or _remove_from_exiting(effect_id):
		_recycle_effect_id(effect_id)
		return true
	return false

## Reserves an ID so it cannot be returned by allocation queries.
## @param effect_id: the unique effect ID to reserve
## @return: true if reserved, false if invalid or currently in use.
func reserve_effect_id(effect_id: int) -> bool:
	if not _is_valid_effect_id(effect_id):
		return false
	if _reserved_effect_ids.has(effect_id):
		return false
	if _used_effect_ids.has(effect_id):
		return false
	_reserved_effect_ids[effect_id] = true
	_free_effect_ids.erase(effect_id)
	return true

## Checks if an ID is currently reserved from allocation.
## @param effect_id: the unique effect ID to check
## @return: true if the ID is reserved, false otherwise
func is_effect_id_reserved(effect_id: int) -> bool:
	if not _is_valid_effect_id(effect_id):
		return false
	return _reserved_effect_ids.has(effect_id)

## Checks if an ID is currently in use by the scheduler.
## @param effect_id: the unique effect ID to check
## @return: true if the ID is in use, false otherwise
func is_effect_id_in_use(effect_id: int) -> bool:
	if not _is_valid_effect_id(effect_id):
		return false
	return _used_effect_ids.has(effect_id)

## Returns the next allocatable ID that is not currently in use or reserved.
## NOTE: Returned ID is a candidate only and is not registered automatically.
## @return: an allocatable effect ID, or -1 if none are available.
func get_id_next_available() -> int:
	var max_allocatable_ids := _effect_id_max - _reserved_effect_ids.size()
	if _used_effect_ids.size() >= max_allocatable_ids:
		if debug_logging:
			_log_generic(_scheduler_identifer + " All effect IDs are currently in use. No available ID to return.")
		return -1

	# Check recycled IDs first for quick availability.
	while not _free_effect_ids.is_empty():
		var recycled_id: int = _free_effect_ids.back()
		if recycled_id < 0 or recycled_id >= _effect_id_max:
			_free_effect_ids.pop_back()
			continue
		if _reserved_effect_ids.has(recycled_id) or _used_effect_ids.has(recycled_id):
			_free_effect_ids.pop_back()
			continue
		return recycled_id

	# Probe sequentially with wrap-around, skipping used and reserved IDs.
	var attempts := 0
	while attempts < _effect_id_max:
		var id := _next_effect_id
		_next_effect_id += 1
		if _next_effect_id >= _effect_id_max:
			_next_effect_id = 0
		attempts += 1

		if _reserved_effect_ids.has(id) or _used_effect_ids.has(id):
			continue

		return id

	if debug_logging:
		_log_generic(_scheduler_identifer + " Unable to find available effect ID after full scan.")
	return -1

## Backward-compatible alias for get_id_next_available().
func get_available_id() -> int:
	return get_id_next_available()

## Registers an ID as in-use by the scheduler.
## @param effect_id: the unique effect ID to register
## @return: true if the ID was successfully registered.
func _register_effect_id(effect_id: int) -> bool:
	if not _is_valid_effect_id(effect_id):
		return false
	if _reserved_effect_ids.has(effect_id):
		return false
	if _used_effect_ids.has(effect_id):
		return false
	_used_effect_ids[effect_id] = true
	_free_effect_ids.erase(effect_id)
	return true


## Unregisters an in-use ID and returns it to the free pool when possible.
## @param effect_id: the unique effect ID to unregister
## @return: true if the ID was currently registered and is now unregistered.
func unregister_effect_id(effect_id: int) -> bool:
	if not _is_valid_effect_id(effect_id):
		return false
	if not _used_effect_ids.erase(effect_id):
		return false
	if _reserved_effect_ids.has(effect_id):
		return true
	if not _free_effect_ids.has(effect_id):
		_free_effect_ids.append(effect_id)
	return true

## Removes a reservation from an ID.
## @param effect_id: the unique effect ID to unreserve
## @return: true if reservation existed and was removed.
func unreserve_effect_id(effect_id: int) -> bool:
	if not _is_valid_effect_id(effect_id):
		return false
	if not _reserved_effect_ids.has(effect_id):
		return false
	_reserved_effect_ids.erase(effect_id)
	return true

## Validates that an effect ID is within the scheduler allocation range.
## @param effect_id: the unique effect ID to validate
## @return: true if the ID is valid for allocation, false otherwise
func _is_valid_effect_id(effect_id: int) -> bool:
	return effect_id >= 0 and effect_id < _effect_id_max

## Returns a deep copy of the list of currently reserved IDs.
## @return: an array of reserved effect IDs.
func get_reserved_ids() -> Array:
	return _reserved_effect_ids.keys()

## Returns a deep copy of the list of currently used IDs.
## @return: an array of used effect IDs.
func get_used_ids() -> Array:
	return _used_effect_ids.keys()

## Clears all reserved IDs
## NOTE: This does not unregister any currently used IDs, but it does make all IDs available for allocation again.
func clear_reserved_ids() -> void:
	_reserved_effect_ids.clear()

## Checks if an effect is unique and if an instance of the same type already exists in any queue or active list.
## NOTE: internally checks if effect is unique before iterating
## @param effect: the effect instance to check for uniqueness
## @return: true if the effect is unique and an instance of the same type already exists
func _unique_effect_exists_in_queues(effect:Effect) -> bool:
	if effect == null:
		if debug_logging:
			_log_generic(_scheduler_identifer + " Cannot check if null effect is unique in queues.")
		return false
	# Check if the effect is unique and if an instance of the same type already exists in any queue or active list
	if effect.is_unique():
		for queue in [_waiting_effects, _entering_effects, _active_effects, _exiting_effects]:
			for existing_record in queue.values():
				if existing_record.effect.get_type() == effect.get_type():
					return true
	return false

## Clears all queues, active lists, and ID tracking in the scheduler. This effectively resets the scheduler to an empty state.
func clear() -> void:
	_waiting_effects.clear()
	_entering_effects.clear()
	_active_effects.clear()
	_exiting_effects.clear()
	_used_effect_ids.clear()
	_free_effect_ids.clear()
	_reserved_effect_ids.clear()
	_next_effect_id = 0
