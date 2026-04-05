## Checks sanity level and shows relevant effects
extends Node
class_name SanityChecker

@export var sanity : SanityComponent

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
	
	# Hide all eyeballs
	for eyeball in eyeballs:
		eyeball.visible = false


func _on_sanity_changed(val: int):
	for key in milestones.keys():
		if val <= key:
			if not milestones[key][1]:
				milestones[key][0].call(true)
		else:
			milestones[key][0].call(false)


func _spawn_eye_ball(is_on: bool = false):
	if is_on and _activated_eyeballs < eyeballs.size():
		eyeballs[_activated_eyeballs].visible = true
		_activated_eyeballs += 1
	elif not is_on and _activated_eyeballs >= eyeballs.size():
		eyeballs[_activated_eyeballs].visible = false
		_activated_eyeballs -= 1
