extends Node
class_name Effect

# Signals
signal started() # this effect has started
signal ended() # this effect has ended

# Attributes #
enum Type
{
	NONE,			# placeholder type or can mean no effect
	STRUCTURAL,		# Affects buildings, walls, doors, or physical structures (like the level itself)
	OBJECT,			# Affects items, props, or movable objects
	ATMOSPHERE,		# changes weather, fog, lighting, or ambient mood
	BIOLOGICAL,		# Affects living things (health, stamina, sanity, etc.)
	AUDIO,			# Plays sounds, music, or voice lines
	VISUAL,			# Changes colors, overlays, screen effects, or particle systems
	SIGNAGE,		# Shows text, signs, or UI messages
	TEMPORAL,		# Alters time (slow-mo, fast-forward, time stop), or time based stuff
	BUFF,			# Positive effect (e.g., +speed, +health)
	DEBUFF,			# Negative effect (e.g., -vision, -stamina)
	ENVIRONMENTAL,	# Affects the world (gravity, wind, temperature, etc.)
	HAZARD			# Dangerous effect (fire, poison, radiation, etc.)
}
# basic info
@export_category("Information")
## Effect type, used to help categorize what this effect does
@export var _type: Type = Type.NONE
## Name for effect (helpful for debugging)
@export var _effect_name: String = ""

# flags
@export_category("Additional Properties")
## Only one of this effect may be active
@export var _is_unique: bool = false
## is this effect always on? (until manually turned off)
@export var _is_persistent: bool = false

# Timing
@export_category("Duration")
## Enable effect timing/duration
@export var _enable_timing:bool = false
## how long should this effect be active for (in seconds) or until next repeat
@export var _duration: float = 0.0 
## Time elapsed so far
@export var _elapsed_time: float = 0.0 # time active

# Repeating
@export_category("Repeating")
## Enable effect repeating
@export var _enable_repeat:bool = false
## how many times to repeat this effect
@export var _repeat_max: int = 0
## Repeats so far
@export var _repeat_count: int = 0

# cooldown
@export_category("Cooldown")
## Enable cooldown after effect ends before it can be applied again
@export var _enable_cooldown: bool = false
## Cooldown duration in seconds
@export var _cooldown_duration: float = 0.0
## Time elapsed in cooldown
@export var _cooldown_elapsed: float = 0.0

# Basic constructor for Effect
func _init(type: Type = Type.NONE, effect_name: String = "No_Name") -> void:
	_type = type
	_effect_name = effect_name

# API Methods #

## Called when the effect starts (e.g., play sound, start particles)
## @param delta: float - Time since last frame (for timing), timing can be omitted if not needed
func enter(delta: float = 0.0) -> void:
	started.emit() # be sure to use .super().enter(delta optional) if overriding to ensure signal is emitted
	pass

## Called when the effect ends (e.g., stop sound, remove particles)
## @param delta: float - Time since last frame, timing can be omitted if not needed
func exit(delta: float = 0.0) -> void:
	ended.emit() # be sure to use .super().exit(delta optional) if overriding to ensure signal is emitted
	pass

## Called every frame while the effect is active (for visual/audio updates)
## @param delta: float - Time since last frame, timing can be omitted if not needed
func update(delta: float = 0.0) -> void:
	pass

## Called every physics frame while the effect is active (for movement/collision)
## @param delta: float - Time since last physics frame, timing can be omitted if not needed
func physics_update(delta: float = 0.0) -> void:
	pass


# Getters/Setters #


## Sets the type of effect (e.g BUFF, VISUAL, HAZARD)
## @param new_type: Type - The new effect type to assign
func set_type(new_type: Type) -> void:
	self._type = new_type

## Gets the current effect type
## @return: Type - The current effect type
func get_type() -> Type:
	return _type

## Sets the name of the effect (for debugging or logging)
## @param new_name: String - The new name to assign
func set_effect_name(new_name: String) -> void:
	self._effect_name = new_name

## Gets the name of the effect
## @return: String - The current name of the effect
func get_effect_name() -> String:
	return _effect_name

## Sets whether only one instance of this effect can be active at once
## @param enable: bool - True if only one instance allowed
func set_unique(enable: bool) -> void:
	self._is_unique = enable

## Checks if only one instance of this effect can be active
## @return: bool - True if unique, false otherwise
func is_unique() -> bool:
	return _is_unique

## Sets whether the effect stays active until manually stopped
## @param enable: bool - True if effect never expires
func set_persistent(enable: bool) -> void:
	self._is_persistent = enable

## Checks if the effect is persistent (never expires)
## @return: bool - True if persistent, false otherwise
func is_persistent() -> bool:
	return self._is_persistent

## Enables or disables timing for the effect (if disabled, duration is ignored and effect must be manually stopped)
## @param enable: bool - True to enable timing, false to disable
func set_enable_timing(enable: bool) -> void:
	self._enable_timing = enable

## Checks if timing is enabled for the effect
## @return: bool - True if timing enabled, false otherwise
func is_timing_enabled() -> bool:
	return self._enable_timing

## Sets the duration of the effect (in seconds)
## @param new_duration: float - Duration in seconds (0 = instant)
## @return: bool - True if set successfully, false if invalid duration
func set_duration(new_duration: float) -> bool:
	if new_duration < 0:
		return false
	self._duration = new_duration
	return true

## Gets the duration of the effect
## @return: float - Duration in seconds
func get_duration() -> float:
	return self._duration

## Enables or disables repeating for the effect (if disabled, repeat count is ignored and effect must be manually stopped)
## @param enable: bool - True to enable repeating, false to disable
func set_enable_repeat(enable: bool) -> void:
	self._enable_repeat = enable

## Checks if repeating is enabled for the effect
## @return: bool - True if repeating enabled, false otherwise
func is_repeat_enabled() -> bool:
	return self._enable_repeat

## Sets how many times the effect should repeat
## @param new_count: int - Number of times to repeat (0 = no repeat)
## @return: bool - True if set successfully, false if invalid count
func set_repeat_max(new_count: int) -> bool:
	if new_count < 0:
		return false
	self._repeat_max = new_count
	return true

## Gets the number of times the effect should repeat
## @return: int - Number of repeats
func get_repeat_max() -> int:
	return self._repeat_max

## Sets the elapsed time since the effect started
## @param new_time: float - Time in seconds since effect began
## @return: bool - True if set successfully, false if invalid time
func set_elapsed_time(new_time: float) -> bool:
	if new_time < 0:
		return false
	self._elapsed_time = new_time
	return true

## Gets the elapsed time since the effect started
## @return: float - Time in seconds
func get_elapsed_time() -> float:
	return self._elapsed_time

## Sets the current repeat cycle index
## @param new_count: int - Current repeat count (0 = first)
## @return: bool - True if set successfully, false if invalid count
func set_repeat_count(new_count: int) -> bool:
	if new_count < 0:
		return false
	self._repeat_count = new_count
	return true

## Gets the current repeat cycle index
## @return: int - Current repeat count
func get_repeat_count() -> int:
	return self._repeat_count

## Enables or disables cooldown for the effect (if enabled, effect cannot be applied again until cooldown expires)
## @param enable: bool - True to enable cooldown, false to disable
func set_enable_cooldown(enable: bool) -> void:
	self._enable_cooldown = enable

## Checks if cooldown is enabled for the effect
## @return: bool - True if cooldown enabled, false otherwise
func is_cooldown_enabled() -> bool:
	return self._enable_cooldown

## Sets the cooldown duration after the effect ends (in seconds)
## @param new_duration: float - Cooldown duration in seconds
## @return: bool - True if set successfully, false if invalid duration
func set_cooldown_duration(new_duration: float) -> bool:
	if new_duration < 0:
		return false
	self._cooldown_duration = new_duration
	return true

## Gets the cooldown duration after the effect ends
## @return: float - Cooldown duration in seconds
func get_cooldown_duration() -> float:
	return self._cooldown_duration

## Sets the elapsed time in cooldown since the effect ended
## @param new_time: float - Time in seconds since cooldown started
## @return: bool - True if set successfully, false if invalid time
func set_cooldown_elapsed(new_time: float) -> bool:
	if new_time < 0:
		return false
	self._cooldown_elapsed = new_time
	return true

## Gets the elapsed time in cooldown since the effect ended
## @return: float - Time in seconds since cooldown started
func get_cooldown_elapsed() -> float:
	return self._cooldown_elapsed

# Reset methods #

## Resets the effect to its initial state
func reset() -> void:
	# reset basic info
	self._type = Type.NONE
	self._effect_name = ""
	# reset flags
	self._is_unique = false
	self._is_persistent = false
	# reset timing
	self._enable_timing = false
	self._duration = 0.0
	self._elapsed_time = 0.0
	# reset repeating
	self._enable_repeat = false
	self._repeat_max = 0
	self._repeat_count = 0
	# reset cooldown
	self._enable_cooldown = false
	self._cooldown_duration = 0.0
	self._cooldown_elapsed = 0.0

## Resets only the timing (elapsed time) of the effect
func reset_timing() -> void:
	self._elapsed_time = 0.0

## Resets only the repeating (repeat count) of the effect
func reset_repeating() -> void:
	self._repeat_count = 0

## Resets only the cooldown (cooldown elapsed time) of the effect
func reset_cooldown() -> void:
	self._cooldown_elapsed = 0.0

# Incremental methods #

## Increments the repeat count (called after each cycle)
func increment_repeat() -> void:
	self._repeat_count += 1

## Increments the elapsed time by the given delta (called each frame)
## @param delta: float - Time in seconds to add to elapsed time
func increment_elapsed_time(delta: float) -> bool:
	if delta < 0:
		return false
	self._elapsed_time += delta
	return true

## Increments the cooldown elapsed time by the given delta (called each frame)
## @param delta: float - Time in seconds to add to cooldown elapsed time
func increment_cooldown_elapsed(delta: float) -> bool:
	if delta < 0:
		return false
	self._cooldown_elapsed += delta
	return true


# Query methods #

## Checks if the effect is still active (duration, repeating)
## @return: bool- True if active, false if expired
func is_active() -> bool:
	# if persistent, always active
	if self._is_persistent:
		return true
	# if both timing and repeat are enabled:
	# duration is a per-cycle timer — only inactive when all repeat cycles are exhausted
	if self._enable_timing and self._enable_repeat:
		if self._repeat_max > 0 and self._repeat_count >= self._repeat_max:
			return false
		return true
	# if only timing enabled: inactive when duration is exceeded
	if self._enable_timing and self._elapsed_time >= self._duration:
		return false
	# if only repeating enabled: inactive when all repeat cycles are exhausted
	if self._enable_repeat and self._repeat_max > 0 and self._repeat_count >= self._repeat_max:
		return false
	return true

## Checks if the effect has finished (expired and not persistent)
## @return: bool - True if finished, false if still active
func is_finished() -> bool:
	return not is_active()

## Checks if the effect is currently on cooldown (after finishing and before it can be applied again)
## @return: bool - True if on cooldown, false otherwise
func is_on_cooldown() -> bool:
	if not self._enable_cooldown:
		return false
	return self._cooldown_elapsed < self._cooldown_duration

## Gets the percentage of duration completed (0.0 to 1.0)
## @return: float - Progress as percentage (0.0 = start, 1.0 = end)
func get_progress() -> float:
	if self._duration <= 0:
		return 1.0
	return min(self._elapsed_time / self._duration, 1.0)

## Gets the remaining time until effect ends (0 if persistent or expired)
## @return: float: Seconds left, or 0 if persistent/expired
func get_remaining_time() -> float:
	if self._is_persistent:
		return 0.0
	if self._elapsed_time >= self._duration:
		return 0.0
	return self._duration - self._elapsed_time

# helper methods #

## Gets the effect’s type as a string ("BUFF", "HAZARD")
## @return: String - Type name without "Type." (honestly great to have)
func get_type_as_string() -> String:
	return str(self._type).replace("Type.", "")
