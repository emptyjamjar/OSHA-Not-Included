extends Node
class_name Effect

# Signals
signal started() # this effect has started
signal ended() # this effect has ended

# Attributes #
enum Type
{
	NONE, # placeholder type or can mean no effect
	STRUCTURAL, # Affects buildings, walls, doors, or physical structures (like the level itself)
	OBJECT, # Affects items, props, or movable objects
	ATMOSPHERE, # changes weather, fog, lighting, or ambient mood
	BIOLOGICAL, # Affects living things (health, stamina, sanity, etc.)
	AUDIO, # Plays sounds, music, or voice lines
	VISUAL, # Changes colors, overlays, screen effects, or particle systems
	SIGNAGE, # Shows text, signs, or UI messages
	TEMPORAL, # Alters time (slow-mo, fast-forward, time stop), or time based stuff
	BUFF, # Positive effect (e.g., +speed, +health)
	DEBUFF, # Negative effect (e.g., -vision, -stamina)
	ENVIRONMENTAL, # Affects the world (gravity, wind, temperature, etc.)
	HAZARD # Dangerous effect (fire, poison, radiation, etc.)
}

var _type: Type = Type.NONE
var _effect_name: String = ""
var _is_unique: bool = false
var _is_persistent: bool = false # is this effect always on? (until manually turned off)
var _duration: float = 0.0 # how long should this effect be active for (in seconds)
var _repeat_count: int = 0 # how many times to repeat this effect
var _repeat_limit: int = -1 # (-1 = infinite), acts as a ceiling cap
var _elapsed_time: float = 0.0 # time active
var _repeat_index: int = 0 # tracks current cycle (ex: 5th cycle)

# API Methods #

## Called when the effect starts (e.g., play sound, start particles)
## @param delta: float - Time since last frame (for timing)
func enter(delta: float) -> void:
	pass

## Called when the effect ends (e.g., stop sound, remove particles)
## @param delta: float - Time since last frame
func exit(delta: float) -> void:
	pass

## Called every frame while the effect is active (for visual/audio updates)
## @param delta: float - Time since last frame
func update(delta: float) -> void:
	pass

## Called every physics frame while the effect is active (for movement/collision)
## @param delta: float - Time since last physics frame
func physics_update(delta: float) -> void:
	pass

# Getters/Setters #
## Sets the type of effect (e.g BUFF, VISUAL, HAZARD)
## @param new_type: Type - The new effect type to assign
func set_type(new_type: Type) -> void:
	_type = new_type

## Gets the current effect type
## @return: Type - The current effect type
func get_type() -> Type:
	return _type

## Sets the name of the effect (for debugging or logging)
## @param new_name: String - The new name to assign
func set_effect_name(new_name: String) -> void:
	_effect_name = new_name

## Gets the name of the effect
## @return: String - The current name of the effect
func get_effect_name() -> String:
	return _effect_name

## Sets whether only one instance of this effect can be active at once
## @param is_unique: bool - True if only one instance allowed
func set_unique(is_unique: bool) -> void:
	_is_unique = is_unique

## Checks if only one instance of this effect can be active
## @return: bool - True if unique, false otherwise
func is_unique() -> bool:
	return _is_unique

## Sets whether the effect stays active until manually stopped
## @param is_persistent: bool - True if effect never expires
func set_persistent(is_persistent: bool) -> void:
	_is_persistent = is_persistent

## Checks if the effect is persistent (never expires)
## @return: bool - True if persistent, false otherwise
func is_persistent() -> bool:
	return _is_persistent

## Sets the duration of the effect (in seconds)
## @param new_duration: float - Duration in seconds (0 = instant)
func set_duration(new_duration: float) -> void:
	_duration = new_duration

## Gets the duration of the effect
## @return: float - Duration in seconds
func get_duration() -> float:
	return _duration

## Sets how many times the effect should repeat
## @param new_count: int - Number of times to repeat (0 = no repeat)
func set_repeat_count(new_count: int) -> void:
	_repeat_count = new_count

## Gets the number of times the effect should repeat
## @return: int - Number of repeats
func get_repeat_count() -> int:
	return _repeat_count

## Sets the maximum number of times the effect can repeat
## @param new_limit: int - Maximum repeats (-1 = infinite)
func set_repeat_limit(new_limit: int) -> void:
	_repeat_limit = new_limit

## Gets the maximum number of repeats
## @return: int - Maximum repeats (-1 = infinite)
func get_repeat_limit() -> int:
	return _repeat_limit

## Sets the elapsed time since the effect started
## @param new_time: float - Time in seconds since effect began
func set_elapsed_time(new_time: float) -> void:
	_elapsed_time = new_time

## Gets the elapsed time since the effect started
## @return: float - Time in seconds
func get_elapsed_time() -> float:
	return _elapsed_time

## Sets the current repeat cycle index
## @param new_index: int - Current repeat count (0 = first)
func set_repeat_index(new_index: int) -> void:
	_repeat_index = new_index

## Gets the current repeat cycle index
## @return: int - Current repeat count
func get_repeat_index() -> int:
	return _repeat_index
