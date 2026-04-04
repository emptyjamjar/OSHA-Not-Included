extends Effect
class_name EF_Sanity_Restore_All

## Description:
## This restores the player's sanity to full/max.
## - Is instant
##
## Usage:
## 1. Attach player node to effect (if no player node is given, it will attempt to look for once in the scene tree)
## 2. Pass Effect to scheduler
##
## How it works:
## When the effect is applied, it checks if the player node is set. If not,
## it attempts to find and set the player node in the scene tree. If the player node is set and has a sanity component, 
## it restores sanity to full by increasing it by the difference between max and current sanity.
##
## Dependencies:
## - player.gd
## - sanity_component.gd

# Export Variables #
## Player node to restore sanity on. If not given, it will attempt to look for one in the scene tree.
@export var player:Player

## Init
func _init():
	self.set_effect_name("Sanity - Restore All")
	self.set_type(Type.BUFF)

## Called when the effect is applied to the player. Restores sanity to full.
## @param player_node The player node to apply the effect to.
## @return true if player was successfully set, false otherwise.
func set_player(player_node:Player) -> bool:
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

## Applies the effect to the player. Restores sanity to full.
func _apply_effect() -> void:
	# if player is not set, attempt to find and set it in the scene tree
	if player == null:
		var result = _find_and_set_player_in_scene_tree()
		if not result:
			if is_debug_enabled():
				_log_generic("_apply_effect - failed to find and set player node in scene tree. Effect will not be applied.")
			return
	# restore sanity to full
	# since the component doesnt handle overflows, we can just increase by the difference between max and current sanity
	var sanity_to_restore = player.sanity_component.get_max_sanity() - player.sanity_component.get_sanity()
	# guard against negative
	if sanity_to_restore < 0:
		if is_debug_enabled():
			_log_generic("_apply_effect - sanity_to_restore is negative. This should not happen. Effect will not be applied.")
		return
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
	super.enter(delta) # pass 0 duration since this is an instant effect
	_apply_effect()
	set_marked_done(true)
