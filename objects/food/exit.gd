extends Button


func _on_button_up() -> void:
	Audio.play_exit_click()
	$"../../..".mode = $"../../..".MODE.OFF # apparently this sets the signal to stop?
