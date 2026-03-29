## A view for the PlayerInventory model
extends TextureRect

@export var slot1 : TextureRect
@export var slot1Btn : TextureButton
@export var boxedItem1: TextureRect
@export var slot2 : TextureRect
@export var slot2Btn : TextureButton
@export var boxedItem2: TextureRect
@export var AnimPlayer: AnimationPlayer

var slots : Array[TextureRect] = []
var boxed_item_slots : Array[TextureRect] = []


func _ready() -> void:
	slots.push_back(slot1)
	slots.push_back(slot2)
	boxed_item_slots.push_back(boxedItem1)
	boxed_item_slots.push_back(boxedItem2)
	PlayerInventory.storage_updated.connect(_on_inventory_updated)
	InteractionManager.invalid_interact.connect(_hud_shake)


func _on_slot_1_button_pressed() -> void:
	PlayerInventory.selectedIndex = 0


func _on_slot_2_button_pressed() -> void:
	PlayerInventory.selectedIndex = 1


##Make selection sprite shake
func _hud_shake():
	AnimPlayer.play("HUD_Shake")


func _on_inventory_updated():
	# Update currently selected slot 
	match PlayerInventory.selectedIndex:
		0:
			slot1Btn.button_pressed = true
		1:
			slot2Btn.button_pressed = true
	
	# Update inventory slots
	for i in PlayerInventory.max_capacity:
		if PlayerInventory.contents[i] != null:
			slots[i].texture = PlayerInventory.contents[i].texture
			slots[i].tooltip_text = PlayerInventory.contents[i].name + "\n" + PlayerInventory.contents[i].description
			if PlayerInventory.contents[i].type == ItemData.Type.PACKAGE:
				boxed_item_slots[i].texture = PlayerInventory.contents[i].uiTexture
		else:
			slots[i].texture = null
			slots[i].tooltip_text = ""
			boxed_item_slots[i].texture = null
