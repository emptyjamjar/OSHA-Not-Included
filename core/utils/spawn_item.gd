## Script to instantiate an ItemBase easily.
## 
## Call spawn_item with an enum from Items to receive an instantiated
## ItemBase node. Then add the node as a child of whatever scene you want.
extends Node

## All items that the conveyor can spawn are found here
## Connected to a list of String paths to resources
enum Items {
	TOILET_PAPER,
	BLACK_WATER_BOTTLE,
	BLUE_WATER_BOTTLE,
	PINK_WATER_BOTTLE,
}

# The ItemBase scene
var item_scene : PackedScene = load("res://objects/items/item_base.tscn")

# Preloaded resources of item data.
# Should follow the order presented in the Items enum
var item_resources : Array[ItemData] = [
	preload("res://objects/items/toilet_paper/toilet_paper.tres"),
	preload("res://objects/items/water_bottles/black_water_bottle.tres"),
	preload("res://objects/items/water_bottles/blue_water_bottle.tres"),
	preload("res://objects/items/water_bottles/pink_water_bottle.tres"),
]


func spawn(item: Items) -> ItemBase:
	var scene := item_scene.instantiate() as ItemBase
	scene.data = item_resources[item].duplicate(true)
	return scene


func spawn_with_data(item: ItemData) -> ItemBase:
	var scene := item_scene.instantiate() as ItemBase
	scene.data = item
	return scene
