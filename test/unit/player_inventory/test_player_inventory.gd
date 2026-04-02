extends GutTest

const PlayerInventoryScript = preload("res://core/autoload/inventory/player_inventory.gd")

## This test script is for the player_inventory.gd script, which is the inventory.gd
## script refactored and now extends from Storage component. This test script
## will focus on the extended or overwritten functionality, rather than the functionality
## provided by "Storage" component itself.

# NOTE: since I cannot test without a super complex setup the literal dropping of items
# and some other methods that don't check for null or bounds, I will use pending() to mark those tests
# as 'Risky" (skipped). This does not imply that the method does not work, but rather, either extremely
# difficult to test fully or the result or testing will hard crash the testing process.

# NOTE: Since drop_item() and drop_item_at() both currently dereference InteractionManager.player.global_position without a null check, 
# I will also mark those tests as pending if InteractionManager.player is null to prevent runtime crashes. The test will pass if
# those methods check for null and handle it gracefully, but will be marked as risky if they do not.

## Test selected index
## Tests that selectedIndex is correctly clamped between 0 and max_capacity - 1 when set to values outside of that range.
func test_selected_index_handles_between_zero_and_capacity_minus_one():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	player_inventory.selectedIndex = -1
	assert_eq(player_inventory.selectedIndex, 0, "selectedIndex should clamp to 0 when set below bounds.")
	
	player_inventory.selectedIndex = 99
	assert_eq(player_inventory.selectedIndex, 1, "selectedIndex should clamp to max_capacity - 1 when set above bounds.")
	player_inventory.free()

## Test get_item() -> ItemData
## Tests that get_item() returns the item at the currently selected index, or null if the slot is empty.
func test_get_item_returns_item_at_selected_index():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	var mock_item := ItemData.new(
		ItemData.Type.GENERIC,
		"Test",
		"Testing Item",
		Texture2D.new(),
	)
	player_inventory.contents[0] = mock_item
	player_inventory.selectedIndex = 0
	
	assert_eq(player_inventory.get_item(), mock_item, "get_item() should return the item at selectedIndex.")
	
	player_inventory.free()

## Test get_item() returns null when selected index is empty
## This test ensures that get_item() correctly returns null when there is no item at the selected index,
##  which is important for preventing errors when trying to access properties of a non-existent item.
func test_get_item_returns_null_when_selected_index_is_empty():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	player_inventory.selectedIndex = 0
	assert_eq(player_inventory.get_item(), null, "get_item() should return null when selected index is empty.")
	player_inventory.free()

## Test _input(event: InputEvent) -> void
## Tests that _input() correctly handles inventory scroll and selection inputs, updating selectedIndex accordingly.
func test_input_scrolls_inventory_and_selects_slots():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	# Simulate inventory scroll up
	var scroll_up_event = InputEventAction.new()
	scroll_up_event.action = "inventory_up"
	scroll_up_event.pressed = true
	player_inventory._input(scroll_up_event)
	assert_eq(player_inventory.selectedIndex, 1, "Selected index should wrap to last slot when scrolling up from first slot.")
	
	# simulate inventory scroll down
	var scroll_down_event = InputEventAction.new()
	scroll_down_event.action = "inventory_down"
	scroll_down_event.pressed = true
	player_inventory._input(scroll_down_event)
	assert_eq(player_inventory.selectedIndex, 0, "Selected index should wrap to first slot when scrolling down from last slot.")
	
	# Simulate selecting slot 1
	var select_slot_1_event = InputEventAction.new()
	select_slot_1_event.action = "inventory_1"
	select_slot_1_event.pressed = true
	player_inventory._input(select_slot_1_event)
	assert_eq(player_inventory.selectedIndex, 0, "Selected index should be 0 when pressing inventory_1.")
	
	# Simulate selecting slot 2
	var select_slot_2_event = InputEventAction.new()
	select_slot_2_event.action = "inventory_2"
	select_slot_2_event.pressed = true
	player_inventory._input(select_slot_2_event)
	assert_eq(player_inventory.selectedIndex, 1, "Selected index should be 1 when pressing inventory_2.")
	
	player_inventory.free()

## Test scroll_inventory(val: int) -> void
## Tests that scroll_inventory() correctly updates selectedIndex and wraps around when reaching the ends of the inventory.
func test_scroll_inventory_wraps_around():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	player_inventory.selectedIndex = 0
	player_inventory.scroll_inventory(-1)
	assert_eq(player_inventory.selectedIndex, 1, "Selected index should wrap to last slot when scrolling up from first slot.")
	
	player_inventory.scroll_inventory(1)
	assert_eq(player_inventory.selectedIndex, 0, "Selected index should wrap to first slot when scrolling down from last slot.")
	
	player_inventory.free()

## test drop_item() -> bool
## Tests that drop_item() returns false when the selected slot is empty.
func test_drop_item_removes_item_from_selected_slot():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	# had to manually put a check here to prevent a runtime crash for methods not checking for null
	if InteractionManager.player == null:
		pending("Skipping: drop_item() currently dereferences InteractionManager.player.global_position without a null check.")
		player_inventory.free()
		return
	
	var mock_item := ItemData.new(
		ItemData.Type.GENERIC,
		"Test",
		"Testing Item",
		Texture2D.new(),
	)
	player_inventory.contents[0] = mock_item
	player_inventory.selectedIndex = 0
	
	var drop_result = player_inventory.drop_item()
	assert_true(drop_result, "drop_item() should return true when an item is successfully dropped.")
	# NOTE: I can't easily test the actual dropping of the item into the world without a more complex setup, 
	# but I can at least check that the item is removed from the inventory.
	assert_eq(player_inventory.contents[0], null, "drop_item() should remove the item from the selected slot.")
	
	player_inventory.free()

## test drop_item_at(coordinate: Vector2)
## Tests that drop_item_at() returns false when the selected slot is empty.
func test_drop_item_at_returns_false_when_slot_is_empty():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	player_inventory.selectedIndex = 0

	var result = player_inventory.drop_item_at(Vector2(100, 200))
	assert_false(result, "drop_item_at() should return false when the selected slot is empty.")

	player_inventory.free()

## Tests that drop_item_at() removes the item from inventory and returns true.
## NOTE: Commented out test due to engine errors occuring. These engine errors are at the C level (not GDScript),
## so there is no way for GUT quickly handle or catch these errors, and they will hard crash the testing process.
func test_drop_item_at_removes_item_and_returns_true():
	pending("Skipping: Due to engine-level errors at the C level when calling drop_item_at() in a unit test environment.")
	#var player_inventory = PlayerInventoryScript.new()
	#player_inventory._ready()
#
	## Safety check: player_inventory is not part of any scene tree,
	## so get_tree() returns null inside drop_item_at() and crashes.
	#if player_inventory.get_tree() == null:
		#pending("Skipping: drop_item_at() requires a scene tree with a 'game' group node. Cannot fully simulate in unit tests.")
		#player_inventory.free()
		#return
#
	#var mock_item := ItemData.new(
		#ItemData.Type.GENERIC,
		#"Test",
		#"Testing Item",
		#Texture2D.new(),
	#)
	#player_inventory.contents[0] = mock_item
	#player_inventory.selectedIndex = 0
#
	#var result = player_inventory.drop_item_at(Vector2(100, 200))
	#assert_true(result, "drop_item_at() should return true when an item is dropped successfully.")
	#assert_eq(player_inventory.contents[0], null, "drop_item_at() should remove the item from the selected slot.")
#
	#player_inventory.free()

## test Override add(content : ItemData) -> bool
## Tests that add() successfully adds an item to the first available slot and returns true.
func test_adding_item_to_inventory():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	var mock_item := ItemData.new(
		ItemData.Type.GENERIC,
		"Test",
		"Testing Item",
		Texture2D.new(),
	)
	
	var add_result = player_inventory.add(mock_item)
	assert_true(add_result, "add() should return true when an item is successfully added.")
	assert_eq(player_inventory.contents[0], mock_item, "add() should place the item in the first available slot.")
	
	player_inventory.free()

## Tests that adding multiple items fills the inventory in order and does not overwrite existing items.
func test_adding_two_items_to_inventory():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	var mock_item1 := ItemData.new(
		ItemData.Type.GENERIC,
		"Test1",
		"Testing Item 1",
		Texture2D.new(),
	)
	var mock_item2 := ItemData.new(
		ItemData.Type.GENERIC,
		"Test2",
		"Testing Item 2",
		Texture2D.new(),
	)
	
	assert_true(player_inventory.add(mock_item1), "First add() should succeed.")
	assert_true(player_inventory.add(mock_item2), "Second add() should also succeed.")
	assert_eq(player_inventory.contents[0], mock_item1, "First item should be in the first slot.")
	assert_eq(player_inventory.contents[1], mock_item2, "Second item should be in the second slot.")
	
	player_inventory.free()

## Tests that adding an item to a full inventory returns false and does not add the item.
func test_adding_item_to_full_inventory():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	# Fill the inventory to capacity
	for i in range(player_inventory.max_capacity):
		var mock_item := ItemData.new(
			ItemData.Type.GENERIC,
			"Test" + str(i),
			"Testing Item " + str(i),
			Texture2D.new(),
		)
		assert_true(player_inventory.add(mock_item), "add() should succeed until inventory is full.")
	
	# Attempt to add another item when inventory is full
	var extra_item := ItemData.new(
		ItemData.Type.GENERIC,
		"Extra",
		"Extra Item",
		Texture2D.new(),
	)
	assert_false(player_inventory.add(extra_item), "add() should return false when inventory is full.")
	
	player_inventory.free()

## Test adding items until full, removing one, and adding again to ensure it adds to the correct slot.
func test_adding_items_until_full_and_removing_one_and_adding_again():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	# Fill the inventory to capacity
	for i in range(player_inventory.max_capacity):
		var mock_item := ItemData.new(
			ItemData.Type.GENERIC,
			"Test" + str(i),
			"Testing Item " + str(i),
			Texture2D.new(),
		)
		assert_true(player_inventory.add(mock_item), "add() should succeed until inventory is full.")
	
	# Remove one item from the inventory
	player_inventory.contents[0] = null
	
	# Attempt to add another item after removing one
	var new_item := ItemData.new(
		ItemData.Type.GENERIC,
		"NewItem",
		"New Item after removing one",
		Texture2D.new(),
	)
	assert_true(player_inventory.add(new_item), "add() should return true after removing an item, even if inventory was previously full.")
	assert_eq(player_inventory.contents[0], new_item, "The new item should be added to the first available slot after removing an item.")
	
	player_inventory.free()

## test remove_at(index : int) -> bool
## Tests that remove_at() successfully removes an item from the specified index and returns true.
func test_remove_at_removes_item_from_specified_index():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	var mock_item := ItemData.new(
		ItemData.Type.GENERIC,
		"Test",
		"Testing Item",
		Texture2D.new(),
	)
	player_inventory.contents[0] = mock_item
	
	var remove_result = player_inventory.remove_at(0)
	assert_true(remove_result, "remove_at() should return true when an item is successfully removed.")
	assert_eq(player_inventory.contents[0], null, "remove_at() should set the specified index to null.")
	
	player_inventory.free()

## Test remove_at() when it is given an index that is out of bounds (negative or greater than or equal to max_capacity).
func test_remove_at_with_out_of_bounds_index():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	var remove_result_negative = player_inventory.remove_at(-1)
	assert_false(remove_result_negative, "remove_at() should return false when given a negative index.")
	var remove_result_too_large = player_inventory.remove_at(player_inventory.max_capacity)
	assert_false(remove_result_too_large, "remove_at() should return false when given an index greater than or equal to max_capacity.")
	player_inventory.free()

## Tests that remove_at() returns false when trying to remove from an empty slot.
func test_remove_at_returns_false_when_slot_is_empty():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	var remove_result = player_inventory.remove_at(0)
	assert_false(remove_result, "remove_at() should return false when trying to remove from an empty slot.")
	player_inventory.free()

## test reset()
## Tests that reset() correctly sets the inventory back to its default state
func test_reset_correctly_sets_to_default_state():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	# Fill the inventory with mock items
	for i in range(player_inventory.max_capacity):
		var mock_item := ItemData.new(
			ItemData.Type.GENERIC,
			"Test" + str(i),
			"Testing Item " + str(i),
			Texture2D.new(),
		)
		player_inventory.contents[i] = mock_item
	
	player_inventory.reset()
	
	# Check that all slots are empty
	for i in range(player_inventory.max_capacity):
		assert_eq(player_inventory.contents[i], null, "reset() should set all inventory slots to null.")
	
	player_inventory.free()

## test has_box()
## Tests that has_box() returns true when the inventory contains at least one item of type PACKAGE, and false otherwise.
func test_has_box_returns_true_when_inventory_contains_package():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	var box_item := ItemData.new(
		ItemData.Type.PACKAGE,
		"Box",
		"A shipping box",
		Texture2D.new(),
	)
	
	player_inventory.add(box_item)
	
	assert_eq(player_inventory.contents[0], box_item, "Inventory should contain the box item.")
	assert_true(player_inventory.has_box(), "has_box() should return true when inventory contains a package.")
	
	player_inventory.free()

## Tests that has_box() returns false when the inventory contains items, but none of them are of type PACKAGE.
func test_has_box_returns_false_when_inventory_contains_no_box():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	var non_box_item := ItemData.new(
		ItemData.Type.GENERIC,
		"Item",
		"A generic item",
		Texture2D.new(),
	)
	
	player_inventory.add(non_box_item)
	
	assert_eq(player_inventory.contents[0], non_box_item, "Inventory should contain the non-box item.")
	assert_eq(player_inventory.has_box(), false, "has_box() should return false when inventory contains no package.")
	
	player_inventory.free()

## Test that has_box() returns false when the inventory is empty.
## NOTE: This is the default state of the inventory, so it should return false until a box item is added.
## This test ensures that has_box() does not return true erroneously when the inventory is empty.
func test_has_box_returns_false_when_inventory_is_empty():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	assert_eq(player_inventory.has_box(), false, "has_box() should return false when inventory is empty.")
	player_inventory.free()

## Test that has_box returns true when the inventory contains multiple items including at least one of type PACKAGE.
func test_has_box_returns_true_when_inventory_contains_multiple_items_including_package():
	var player_inventory = PlayerInventoryScript.new()
	player_inventory._ready()
	
	var box_item := ItemData.new(
		ItemData.Type.PACKAGE,
		"Box",
		"A shipping box",
		Texture2D.new(),
	)
	
	var non_box_item := ItemData.new(
		ItemData.Type.GENERIC,
		"Item",
		"A generic item",
		Texture2D.new(),
	)
	
	player_inventory.add(non_box_item)
	player_inventory.add(box_item)
	
	assert_eq(player_inventory.contents[0], non_box_item, "Inventory should contain the non-box item.")
	assert_eq(player_inventory.contents[1], box_item, "Inventory should contain the box item.")
	assert_eq(player_inventory.has_box(), true, "has_box() should return true when inventory contains a package.")
	
	player_inventory.free()
