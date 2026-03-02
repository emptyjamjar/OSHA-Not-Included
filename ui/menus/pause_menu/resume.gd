## Resume button for pause menu.
extends TextureButton


func _on_button_up() -> void:
	get_tree().paused = false
	$"..".visible = false
