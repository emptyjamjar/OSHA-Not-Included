## VendingSystem - Global vending machine UI and transaction manager
##
## Autoload singleton that manages the vending machine UI and purchase logic.
## Control node displays a grid of items you can buy with slot codes (A1, A2, B1, etc.)
##
## Usage:
## - Access globally via VendingSystem singleton
## - Toggle with 'U' key or via VendingMachine interaction
##
## Key Features:
## - Slot-based purchasing (type codes like "A1", "B2")
## - Dynamically loads item inventory
## - Processes even when game is paused
##
## Dependencies:
## - Requires shop_slot.tscn scene for individual item slots
## - Works with ItemData resources

extends Control

signal vending_closed

@export var ui : CanvasLayer
@export var currency_label : Label
@export var vending_slot_node : PackedScene = preload("res://objects/food/shop_slot.tscn")
@export var vending_items : Array[ItemData]
@export var vending_container : GridContainer
@export var slot_input : LineEdit

var _slot_text : String = ""
var is_loaded = false
var slot_map: Dictionary[String, ItemData] = {}
var _currency: float = 0.0
var currency: float:
	set(value):
		_currency = value
		if currency_label: 
			currency_label.text = "Currency : " + str(value)
	get:
		return _currency
var _mode: MODE = MODE.OFF
var mode: MODE:
	set(value):
		var old_mode = _mode
		_mode = value
		slot_input.text = ""
		if value == MODE.OFF:
			if ui:
				ui.hide()
			if old_mode == MODE.ON:
				vending_closed.emit()
		else:
			if ui:
				ui.show()
			if slot_input:
				slot_input.call_deferred("grab_focus")
	get:
		return _mode

enum MODE {
	ON,
	OFF
}


func _input(event):
	if mode == MODE.ON and event.is_action_pressed("pause"):
		mode = MODE.OFF
		print("VENDING MACHINE IS OFF: ", mode)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	currency = 100
	
	if ui:
		ui.hide()
	if not is_loaded and vending_items.size() > 0:
		load_shop_inventory()
		is_loaded = true
	else:
		printerr("NOT loading because is_loaded=", is_loaded, " or items size=", vending_items.size())
	
	if slot_input:
		slot_input.text_submitted.connect(_on_code_entered)


func buy_item(item: ItemData) -> bool:
	if item == null:
		return false
	
	if item.price > currency:
		print("Not enough money")
		return false
	
	currency -= item.price
	print("Bought item: ", item.name)
	Audio.play_vending_machine()
	return true


func free_previous_slots():
	for slot in vending_container.get_children():
		slot.free()
	
func load_shop_inventory():
	slot_map.clear()
	
	for i in range(vending_items.size()):
		var item = vending_items[i]
		var code = index_to_code(i)
		
		slot_map[code] = item
		
		var vending_slot = vending_slot_node.instantiate()
		vending_container.add_child(vending_slot)
		vending_slot.slot_code = code
		vending_slot.item = item


func index_to_code(index: int) -> String:
	var cols := vending_container.columns
	@warning_ignore("integer_division")
	var row := index / cols
	var col := index % cols
	
	var row_letter := char(ord("A") + row)
	var col_number := col + 1
	
	return row_letter + str(col_number)


func _on_code_entered(code: String):
	code = code.strip_edges().to_upper()
	slot_input.text = ""
	if not slot_map.has(code):
		print("Invalid slot: ", code)
		Audio.play_invalid_interaction()
		return
	var item := slot_map[code]
	if buy_item(item):
		print("BOUGHT FROM SLOT ", code)
		mode = MODE.OFF # turn off

func set_shop_inventory(list : Array[ItemData]):
	free_previous_slots()
	vending_items = list
	load_shop_inventory()


func _btn_to_text(text: String):
	slot_input.text += text.to_upper()
	slot_input.text_changed.emit(slot_input.text)


func _on_button_a_pressed() -> void:
	_btn_to_text("A")


func _on_button_b_pressed() -> void:
	_btn_to_text("B")


func _on_button_c_pressed() -> void:
	_btn_to_text("C")


func _on_button_1_pressed() -> void:
	_btn_to_text("1")


func _on_button_2_pressed() -> void:
	_btn_to_text("2")


func _on_button_3_pressed() -> void:
	_btn_to_text("3")


func _on_button_delete_pressed() -> void:
	var slotLen = slot_input.text.length() - 1
	if slotLen < 0:
		return
	slot_input.text = slot_input.text.erase(slotLen)
	slot_input.text_changed.emit(slot_input.text)


func _on_button_enter_pressed() -> void:
	_on_code_entered(slot_input.text)


func _on_line_edit_text_changed(new_text: String) -> void:
	if _slot_text.length() > new_text.length():
		Audio.play_exit_click()
	elif _slot_text.length() < new_text.length():
		Audio.play_click()
	else:
		Audio.play_invalid_interaction()
	_slot_text = new_text
