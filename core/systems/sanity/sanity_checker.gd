## Checks sanity level and shows relevant effects
## Make sure to connect the SanityComponent and Player
extends Node
class_name SanityChecker

@export var sanity : SanityComponent
@export var player : Player

## To use add SanityEyeball nodes to the scene and to the array of eyeballs
## For each eyeball, add desired effect to milestones array
@export var eyeballs : Array[SanityEyeball] = []
var _activated_eyeballs : int = 0

enum Effects {
	SPAWN_EYE_BALL,
}

## Calls given function when key is reached
## milestone_val: [effect_function, bool]
var milestones : Dictionary[int, Array] = {
	50: [_spawn_eye_ball, false],
}


func _ready() -> void:
	sanity.sanity_changed.connect(_on_sanity_changed)
	PlayerInventory.storage_updated.connect(_on_inventory_updated)
	
	# Hide all eyeballs
	for eyeball in eyeballs:
		eyeball.visible = false
		eyeball.player = player
		eyeball.enabled = false
		eyeball.hitbox.call_deferred("set_disabled", true)


func _on_sanity_changed(val: int):
	for key in milestones.keys():
		if val <= key:
			if not milestones[key][1]:
				milestones[key][0].call(true)
		else:
			milestones[key][0].call(false)


func _on_inventory_updated():
	# Check for anomalous items and start a timer to decrease sanity
	for idx in range(PlayerInventory.max_capacity):
		var timer = get_tree().create_timer(1)
		timer.timeout.connect(_on_anomalous_timeout.bind(idx))


func _on_anomalous_timeout(index: int):
	if PlayerInventory.contents[index].type == ItemData.Type.ANOMALOUS:
		sanity.decrease(5)
		var timer = get_tree().create_timer(1)
		timer.timeout.connect(_on_anomalous_timeout.bind(index))


func _spawn_eye_ball(is_on: bool = false):
	if is_on and _activated_eyeballs < eyeballs.size():
		eyeballs[_activated_eyeballs].visible = true
		eyeballs[_activated_eyeballs].enabled = true
		eyeballs[_activated_eyeballs].hitbox.call_deferred("set_disabled", false)
		_activated_eyeballs += 1
	elif not is_on and _activated_eyeballs >= eyeballs.size():
		_activated_eyeballs -= 1
		eyeballs[_activated_eyeballs].visible = false
		eyeballs[_activated_eyeballs].enabled = false
		eyeballs[_activated_eyeballs].hitbox.call_deferred("set_disabled", true)
