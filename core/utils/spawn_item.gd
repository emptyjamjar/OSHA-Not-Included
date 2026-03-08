## Script to instantiate an ItemBase easily.
## 
## Call spawn_item with an enum from ItemDataList to receive an instantiated
## ItemBase node. Then add the node as a child of whatever node you want.
class_name SpawnItem extends Node

## All items that the conveyor can spawn are found here
## Connected to a list of String paths to resources
enum ItemDataList {
	TOILET_PAPER,
	BLACK_WATER_BOTTLE,
	BLUE_WATER_BOTTLE,
	PINK_WATER_BOTTLE,
}

# Item Base scene
var item_scene : PackedScene
## Preloaded resources of item data
var item_resources : Array[ItemData]


func _ready() -> void:
	item_scene = load("res://objects/items/item_base.tscn")
	# Fill item_resources with needed item data
	# Items should follow the order presented in the ItemDataList enum
	item_resources.append(preload("res://objects/items/toilet_paper/toilet_paper.tres"))
	item_resources.append(preload("res://objects/items/water_bottles/black_water_bottle.tres"))
	item_resources.append(preload("res://objects/items/water_bottles/blue_water_bottle.tres"))
	item_resources.append(preload("res://objects/items/water_bottles/pink_water_bottle.tres"))


func spawn_item(item: ItemDataList) -> ItemBase:
	var scene := item_scene.instantiate() as ItemBase
	scene.data = item_resources[item].duplicate(true)
	return scene
