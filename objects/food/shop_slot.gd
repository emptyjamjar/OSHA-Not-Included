## ShopSlot - Item display slot in vending machine UI
##
## Panel UI component that shows a single purchasable item in the vending machine.
## Shows the item's icon, price, and slot code (e.g., "A1", "B2").
##
## Usage:
## - Used as part of shop_slot.tscn scene
## - Instantiated dynamically by VendingSystem
##
## Interaction:
## - Put it a code to purchase when vending machine is open
## - Automatically updates display when item property is set
##
## Dependencies:
## - Requires VendingSystem autoload
## - Works with ItemData resources

extends Panel

@export var slot_code: String
@export var item : ItemData:
	set(value):
		_item = value
		item = value
		if is_inside_tree():
			_update_display()
	get:
		return _item

var _item : ItemData = null
var is_hovered : bool = false
var _mouse_clicked : bool = false


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


func _on_gui_input(event: InputEvent):
	if not is_hovered or VendingSystem.mode == VendingSystem.MODE.OFF:
		return
	if event.is_action_pressed("left_mouse_click"):
		_mouse_clicked = true
		modulate = Color(0.63, 0.63, 0.63, 1)
	if _mouse_clicked and event.is_action_released("left_mouse_click"):
		modulate = Color(1, 1, 1, 1)
		_mouse_clicked = false
		VendingSystem.buy_item(item)


func _on_mouse_entered() -> void:
	modulate = Color(0.82,0.82,0.82, 1)
	#160
	is_hovered = true


func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1, 1)
	is_hovered = false
