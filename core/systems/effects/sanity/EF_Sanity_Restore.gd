extends Effect
class_name EF_Sanity_Restore

## Description:
## This restores a set amount of the player's sanity.
## - Is instant
##
## Usage:
## 1. Attach player node to effect (if no player node is given, it will attempt to look for one in the scene tree)
## 2. Set restore amount via inspector or API
## 3. Pass Effect to scheduler
##
## How it works:
## When the effect is applied, it checks if the player node is set. If not,
## it attempts to find and set the player node in the scene tree. If the player node is set and has a sanity component,
## it restores sanity by the configured amount to remaining max sanity.
##
## Dependencies:
## - player.gd
## - sanity_component.gd

# Export Variables #
## Player node to restore sanity on. If not given, it will attempt to look for one in the scene tree.
@export var player: Player
## Amount of sanity to restore when effect is applied.
@export var restore_amount: int = 10

## Init
func _init():
	self.set_effect_name("Sanity - Restore")
	self.set_type(Type.BUFF)

## Sets the amount of sanity restored when this effect is applied.
## @param amount: int - Amount of sanity to restore (must be >= 0)
## @return: bool - True if set successfully, false if invalid
func set_restore_amount(amount: int) -> bool:
	if amount < 0:
		return false
	restore_amount = amount
	return true

## Gets the configured sanity restore amount.
## @return: int - Amount of sanity restored
func get_restore_amount() -> int:
	return restore_amount

## Called when the effect is applied to the player.
## @param player_node The player node to apply the effect to.
## @return true if player was successfully set, false otherwise.
func set_player(player_node: Player) -> bool:
	if player_node == null:
		if is_debug_enabled():
			_log_generic("set_player - player_node is null. Will attempt to find player node in scene tree when applying effect.")
		return false
	## verify that the player node has a sanity component
	if player_node.sanity_component == null:
		if is_debug_enabled():
			_log_generic("set_player - player_node does not have a sanity component. Effect will not be applied to this node.")
		return false
	player = player_node
	return true

## Attempts to find the player node in the scene tree and set it. Returns true if successful, false otherwise.
## @return true if player was successfully found and set, false otherwise.
func _find_and_set_player_in_scene_tree() -> bool:
	# first checks the scene tree for the player
	var player_node = get_tree().get_root().find_node("Player", true, false)
	# then pass result to set_player as it will handle the sanity component check
	var result = set_player(player_node)
	if not result:
		if is_debug_enabled():
			_log_generic("_find_and_set_player_in_scene_tree - failed to find and set player node in scene tree.")
	return result

## Applies the effect to the player. Restores sanity by the configured amount.
func _apply_effect() -> void:
	# if player is not set, attempt to find and set it in the scene tree
	if player == null:
		var result = _find_and_set_player_in_scene_tree()
		if not result:
			if is_debug_enabled():
				_log_generic("_apply_effect - failed to find and set player node in scene tree. Effect will not be applied.")
			return

	# guard against invalid configured restore values
	if restore_amount < 0:
		if is_debug_enabled():
			_log_generic("_apply_effect - restore_amount is negative. Effect will not be applied.")
		return

	# to avoid over-restoring above max sanity
	var missing_sanity = player.sanity_component.get_max_sanity() - player.sanity_component.get_sanity()
	if missing_sanity <= 0:
		if is_debug_enabled():
			_log_generic("_apply_effect - player sanity is already full. No restore needed.")
		return
	var sanity_to_restore = min(restore_amount, missing_sanity)
	if is_debug_enabled():
		_log_generic("_apply_effect - restoring sanity by " + str(sanity_to_restore) + " to player.")
	player.sanity_component.increase(sanity_to_restore)

func _ready() -> void:
	# if player is not set, attempt to find and set it in the scene tree
	if player == null:
		var result = _find_and_set_player_in_scene_tree()
		if not result:
			if is_debug_enabled():
				_log_generic("_ready - failed to find and set player node in scene tree. Effect will not be applied.")
	# if player is set, check if sanity component is valid
	elif player.sanity_component == null:
		if is_debug_enabled():
			_log_generic("_ready - player node does not have a sanity component. Effect will not be applied.")

## override enter() to immediately apply the effect since this is an instant effect
func enter(delta: float = 0.0) -> void:
	super.enter(delta)
	_apply_effect()
	set_marked_done(true)
