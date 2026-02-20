extends Panel

var _item : ItemData = null

@export var slot_code: String
@export var item : ItemData:
	set(value):
		_item = value
		if is_inside_tree():
			_update_display()
	get:
		return _item

func _update_display():	
	if _item == null:
		print("item is nonexistent")
		return
	
	if has_node("VBoxContainer/Icon"):
		$VBoxContainer/Icon.texture = _item.texture
	if has_node("VBoxContainer/HBoxContainer/Cost"):
		$VBoxContainer/HBoxContainer/Cost.text = "$ " + str(_item.price)
	if has_node("VBoxContainer/HBoxContainer/Code"):
		$VBoxContainer/HBoxContainer/Code.text = slot_code
		
func _on_gui_input(event):
	if event is InputEventMouseButton and VendingSystem.mode == VendingSystem.MODE.ON:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			if VendingSystem.buy_item(item):
				# add to inventory later
				#Inventory.add_item(item, 1)
				print("WOW ADDED TO THE INV")
				# TODO: Add to INV
