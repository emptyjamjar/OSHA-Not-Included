class_name ItemData extends Resource

enum Type {
	ANOMALOUS,
	GENERIC,
	CONSUMABLE,
	PACKAGE,
}

@export var type : Type
@export var name : String
# Description shown on hover
@export_multiline var description : String
# How the item appears within inventories
@export var invTexture: Texture2D
