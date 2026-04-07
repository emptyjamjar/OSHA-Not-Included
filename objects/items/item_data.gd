## Stores data related to items which can be packaged.
extends Resource
class_name ItemData

enum Type {
	GENERIC,
	ANOMALOUS,
	CONSUMABLE,
	PACKAGE,
}

@export var type : Type
@export var name : String
# Used for vending machine
@export var price : float = 1.0
# Description shown on hover
@export_multiline var description : String
@export var texture: Texture2D
@export var uiTexture: Texture2D:
	get:
		if uiTexture == null:
			return texture
		return uiTexture
# How much space it takes up in inventories
@export var size : int
# Used for slowing player down
@export var weight : float
@export var id : int 
@export var required_items : Dictionary #{ticket_id: quantity}
## Consumable effects this item will do
var consumables : Array = []
## anomalous effects this item will do
var anomalies : Array = []



func _init(p_type := Type.GENERIC, p_name := "Item", p_description := "Item data.",
		p_texture : Texture2D = null, p_inv : Texture2D = null, p_size := 1, p_weight := 1
	) -> void:
	type = p_type
	name = p_name
	description = p_description
	# Item's texture defaults to godot icon
	texture = p_texture
	uiTexture = p_inv
	size = p_size
	weight = p_weight
	
func return_type():
	return type
