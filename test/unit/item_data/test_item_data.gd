extends GutTest

## This test script is for the item_data.gd script which contains the individual data for items
## Since item_data is a resource, it will be limited to testing the data itself and not any interactions with it.

var _item_data: ItemData

## Creates a new item data as if it was brand new
func before_each() -> void:
	_item_data = ItemData.new(
		ItemData.Type.CONSUMABLE,
		"Test Item",
		"This is a test item.",
		Texture2D.new(),
		Texture2D.new(),
		2,
		1.5
	)

## Tests if the initialization of item data is correct
func test_item_data_initialization() -> void:
	assert_eq(_item_data.type, ItemData.Type.CONSUMABLE)
	assert_eq(_item_data.name, "Test Item")
	assert_eq(_item_data.description, "This is a test item.")
	assert_eq(_item_data.size, 2, "Expected size to be 2")
	assert_eq(_item_data.weight, 1.5, "Expected weight to be 1.5")
	assert_true(_item_data.texture != null, "Expected texture to be initialized.")
	assert_true(_item_data.uiTexture != null, "Expected UI texture to be initialized.")

## Tests if the type is correctly returned
func test_item_data_return_type() -> void:
	assert_eq(_item_data.return_type(), ItemData.Type.CONSUMABLE)
