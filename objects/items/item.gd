class_name Item extends Sprite2D

@export var itemData : ItemDataComponent
@export var iArea : InteractionArea


func _init(ticket: int, size: int = 1, weight: float = 1) -> void:
	itemData.ticket = ticket
	itemData.size = size
	itemData.weight = weight
