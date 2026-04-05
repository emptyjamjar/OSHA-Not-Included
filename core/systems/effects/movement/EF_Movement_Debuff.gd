extends Effect
class_name EF_Movement_Debuff

## Description:
## Temporarily reduces the player's movement speed.
## - Is timed (default duration is 3 seconds)
##
## Usage:
## 1. Attach player node to effect (if no player node is given, it will attempt to find one in the scene tree)
## 2. Set the desired speed multiplier (e.g. 0.5 for 50% speed)
## 3. Set the duration of the effect (default is 3 seconds)
## 4. Pass Effect to scheduler
##
## How it works:
## On enter, this effect stores the player's current move_speed and applies a multiplier debuff.
## On exit, it restores the original move_speed.
##
## Dependencies:
## - effect.gd
## - player.gd
## - sanity_component.gd (indirectly)

# Export Variables #
## Player node to apply movement debuff to. If not given, it will attempt to look for one in the scene tree.
var player: Player
## Speed multiplier while debuff is active (0.5 = 50% speed).
@export_range(0.0, 1.0, 0.01) var speed_multiplier: float = 0.7

# Internal state #
var _original_move_speed: float = 0.0
var _is_applied: bool = false

## Init
func _init():
	self.set_effect_name("Movement - Debuff")
	self.set_type(Type.DEBUFF)
	self.set_enable_timing(true)
	self.set_duration(3.0)


## Called when assigning the player to this effect.
## @param player_node The player node to apply this effect to.
## @return true if player was successfully set, false otherwise.
func set_player(player_node: Player) -> bool:
	if player_node == null:
		if is_debug_enabled():
			_log_generic("set_player - player_node is null. Will attempt to find player node in scene tree when applying effect.")
		return false
	if not "move_speed" in player_node:
		if is_debug_enabled():
			_log_generic("set_player - player_node does not expose move_speed. Effect will not be applied to this node.")
		return false
	player = player_node
	return true

## Attempts to find the player node in the scene tree and set it. Returns true if successful, false otherwise.
## @return true if player was successfully found and set, false otherwise.
func _find_and_set_player_in_scene_tree() -> bool:
	# first checks the scene tree for the player
	var player_node = get_tree().get_root().find_node("Player", true, false)
	# then pass result to set_player as it will handle validation checks
	var result = set_player(player_node)
	if not result:
		if is_debug_enabled():
			_log_generic("_find_and_set_player_in_scene_tree - failed to find and set player node in scene tree.")
	return result

## Applies movement debuff to the player.
func _apply_effect() -> void:
	# if player is not set, attempt to find and set it in the scene tree
	if player == null:
		var result = _find_and_set_player_in_scene_tree()
		if not result:
			if is_debug_enabled():
				_log_generic("_apply_effect - failed to find and set player node in scene tree. Effect will not be applied.")
			set_marked_done(true)
			return

	# avoid duplicate apply if enter() is called again unexpectedly
	if _is_applied:
		if is_debug_enabled():
			_log_generic("_apply_effect - effect is already applied. Skipping re-application.")
		return

	_original_move_speed = player.move_speed
	var new_speed = _original_move_speed * speed_multiplier
	# guard against accidental negative values due to invalid multipliers
	if new_speed < 0:
		if is_debug_enabled():
			_log_generic("_apply_effect - computed new_speed is negative. Effect will not be applied.")
		set_marked_done(true)
		return

	if is_debug_enabled():
		_log_generic("_apply_effect - applying movement debuff. move_speed: " + str(_original_move_speed) + " -> " + str(new_speed))
	player.move_speed = new_speed
	_is_applied = true

## Reverts movement debuff on the player.
func _revert_effect() -> void:
	if not _is_applied:
		return
	if player == null:
		if is_debug_enabled():
			_log_generic("_revert_effect - player is null. Cannot restore move_speed.")
		return
	if is_debug_enabled():
		_log_generic("_revert_effect - restoring move_speed to " + str(_original_move_speed))
	player.move_speed = _original_move_speed
	_is_applied = false

func _ready() -> void:
	# if player is not set, attempt to find and set it in the scene tree
	if player == null:
		var result = _find_and_set_player_in_scene_tree()
		if not result:
			if is_debug_enabled():
				_log_generic("_ready - failed to find and set player node in scene tree. Effect will not be applied.")
	# if player is set, check if move_speed is valid
	elif not "move_speed" in player:
		if is_debug_enabled():
			_log_generic("_ready - player node does not expose move_speed. Effect will not be applied.")

## override enter() to apply movement debuff when this effect starts
func enter(delta: float = 0.0) -> void:
	super.enter(delta)
	_apply_effect()

## override exit() to restore movement speed when this effect ends
func exit(delta: float = 0.0) -> void:
	super.exit(delta)
	_revert_effect()
	super.exit(delta)
