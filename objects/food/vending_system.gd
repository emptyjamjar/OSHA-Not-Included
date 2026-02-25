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
@export var ui : CanvasLayer
@export var currency_label : Label
@export var vending_slot_node : PackedScene = preload("res://objects/food/shop_slot.tscn")
@export var vending_items : Array[ItemData]
@export var vending_container : GridContainer
@export var slot_input : LineEdit
signal vending_closed
var is_loaded = false
var slot_map: Dictionary[String, ItemData] = {}
enum MODE {
	ON,
	OFF
}
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

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_U:
			if mode == MODE.ON:
				mode = MODE.OFF
				print("VENDING MACHINE IS OFF")
			else:
				mode = MODE.ON
				print("VENDING MACHINE IS ON: ", mode)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("VendingSystem _ready called")
	print("Vending Items count: ", vending_items.size())
	print("Vending Container: ", vending_container)
	print("Node path:", get_path())
	currency = 100
	print("starting currency: ", currency)
	for item in vending_items:
		print(item)
	
	if ui:
		ui.hide()
	if not is_loaded and vending_items.size() > 0:
		load_shop_inventory()
		is_loaded = true
		print("Is loaded set to: ", is_loaded)
	else:
		print("NOT loading because is_loaded=", is_loaded, " or items size=", vending_items.size())
	
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
	if not slot_map.has(code):
		print("Invalid slot: ", code)
		return
	var item := slot_map[code]
	if buy_item(item):
		print("BOUGHT FROM SLOT ", code)

func set_shop_inventory(list : Array[ItemData]):
	free_previous_slots()
	vending_items = list
	load_shop_inventory()
