## A view for the PlayerInventory model
extends TextureRect

@export var slot1 : TextureRect
@export var slot1Btn : TextureButton
@export var slot2 : TextureRect
@export var slot2Btn : TextureButton

var slots : Array[TextureRect] = []


func _ready() -> void:
	slots.push_back(slot1)
	slots.push_back(slot2)
	PlayerInventory.storage_updated.connect(_on_inventory_updated)


func _on_slot_1_button_pressed() -> void:
	PlayerInventory.selectedIndex = 0


func _on_slot_2_button_pressed() -> void:
	PlayerInventory.selectedIndex = 1


func _on_inventory_updated():
	# Update currently selected slot
	match PlayerInventory.selectedIndex:
		0:
			slot1Btn.set_pressed_no_signal(true)
		1:
			slot2Btn.set_pressed_no_signal(true)
	
	# Update inventory slots
	for i in PlayerInventory.max_capacity:
		if PlayerInventory.contents[i] != null:
			slots[i].texture = PlayerInventory.contents[i].uiTexture
			slots[i].tooltip_text = PlayerInventory.contents[i].description
		else:
			slots[i].texture = null
			slots[i].tooltip_text = ""
