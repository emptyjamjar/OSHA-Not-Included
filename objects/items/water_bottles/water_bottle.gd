class_name WaterBottle extends Sprite2D

enum Colour {
	BLACK,
	BLUE,
	PINK,
}

@export var itemData : ItemDataComponent

func _init(colour: Colour) -> void:
	var resourcePath := "res://objects/items/water_bottles/resources/"
	match colour:
		Colour.BLACK:
			texture = load(resourcePath + "warehouse-large-black.png")
			itemData.data = load(resourcePath + "black_water_bottle.tres")
		Colour.BLUE:
			texture = load(resourcePath + "warehouse-large-blue.png")
			itemData.data = load(resourcePath + "blue_water_bottle.tres")
		Colour.PINK:
			texture = load(resourcePath + "warehouse-large-pink.png")
			itemData.data = load(resourcePath + "pink_water_bottle.tres")
