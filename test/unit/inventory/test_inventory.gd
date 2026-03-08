extends GutTest

## This test script runs tests on inventory.gd. This test may or may not be comprehensive, but
## will cover each signal, method, etc.

# Globals
var mock_item:ItemData
var inv:Inventory

## Run before all tests
## create new item/inventory
func before_all():
	mock_item = ItemData.new(
		ItemData.Type.GENERIC,
		"Test",
		"Testing Item",
		Texture2D.new(),
	)
	inv = Inventory.new()

## Run after all tests
## reset inventory/item
func after_all():
	inv.free()
	mock_item = null

## Initital State
## Tests the initial state of inventory
func test_initial_state():
	assert_eq(inv.held_item, null, "Unexpected initial state, expected held_item to be null.")

## add_held_item()
## Tests the behavior add new items to inventory
func test_add_held_item():
	# add item when no item held
	assert_eq(inv.add_held_item(mock_item), true, "Expected true after adding item, got false.")
	assert_eq(inv.held_item, mock_item, "Unexpected held item, expected mock_item.")
	# add item when item is already held
	var mock_item2 = ItemData.new(
		ItemData.Type.GENERIC,
		"Test",
		"Testing Item",
		Texture2D.new(),
	)
	assert_eq(inv.add_held_item(mock_item2), false, "Expected false as there is already held item, got true.")
	assert_eq(inv.held_item, mock_item, "held_item is holding mock_item2 but held_item shouldn't be changed.")

## has_item()
## Tests if has_item works as intended
func test_has_item():
	# has new item
	inv.held_item = mock_item
	assert_eq(inv.has_item(), true, "has_item() returned false when true was expected after adding mock_item.")
	# has no item, by setting held_item to null
	inv.held_item = null
	assert_eq(inv.has_item(), false, "has_item() returned true when false was expected after directly setting held_item to null.")
	# has no item, by using remove_held_item()
	inv.add_held_item(mock_item)
	inv.remove_held_item()
	assert_eq(inv.has_item(), false, "has_item() returned true when false was expected after using remove_held_item() to remove item.")

## remove_held_item()
## Tests removing items from inventory
func test_remove_held_item():
	# has no item to remove
	assert_eq(inv.remove_held_item(), null, "Unexpected result, no item was set, yet remove_held_item() didn't return null.")
	# has item to remove
	inv.held_item = mock_item
	assert_eq(inv.remove_held_item(), mock_item, "Unexpected result, mock_item was not returned.")
	assert_eq(inv.held_item, null, "held_item not set to null after remove_held_item().")
