extends Resource
class_name ItemData

enum Type {
	ANOMALOUS,
	GENERIC,
	CONSUMABLE,
	PACKAGE,
}

@export var type : Type
@export var name : String
@export var price : float = 1.0
# Description shown on hover
@export_multiline var description : String
@export var texture: Texture2D
# Ticket associated with item
@export var ticket : int
# How much space it takes up in inventories
@export var size : int
# Used for slowing player down
@export var weight : float


@export var id:int 
@export var required_items : Dictionary #{ticket_id: quantity}


func _init(p_type := Type.GENERIC, p_name := "Item", p_description := "Item data.",
		p_texture : Texture2D = null, p_ticket := 0, p_size := 1, p_weight := 1
	) -> void:
	type = p_type
	name = p_name
	description = p_description
	# Item's texture defaults to godot icon
	if p_texture:
		texture = p_texture
	else:
		texture = load("res://icon.svg")
	ticket = p_ticket
	size = p_size
	weight = p_weight
