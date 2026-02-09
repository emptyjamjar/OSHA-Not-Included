class_name Item extends Sprite2D

@export var itemData : ItemDataComponent

func _init(ticket: int, size: int, weight: int) -> void:
	itemData.ticket = ticket
	itemData.size = size
	itemData.weight = weight
