extends GutTest

## This test script is for the item_base.gd script which contains the
## node instance information and interaction data.

## This is a fake item_base class with added methods for easier testing
class Mock_Item:
	extends ItemBase

	func create_interaction() -> void:
		self.iArea = InteractionArea.new()

	func create_sprite() -> void:
		self.sprite = Sprite2D.new()
		

	func create_data() -> void:
		if self.data == null:
			var new_data: ItemData = ItemData.new(
				ItemData.Type.GENERIC,
				"mock_data",
				"This is fake item data.",
				Texture2D.new(),
				Texture2D.new(),
				1,
				1
			)
			self.data = new_data
		else:
			self.data.type = ItemData.Type.GENERIC
			self.data.name = "mock_data"
			self.data.description = "This is fake item data."
			self.data.size = 1
			self.data.weight = 1
			if self.data.texture == null:
				self.data.texture = Texture2D.new()
			if self.data.uiTexture == null:
				self.data.uiTexture = Texture2D.new()

	func free_all() -> void:
		self.iArea.free()
		self.sprite.free()
		self.data = null


var _item: Mock_Item
var _picked_up_called: bool = false
var _picked_up_item: ItemBase = null


func _on_mock_item_picked_up(item: ItemBase) -> void:
	_picked_up_called = true
	_picked_up_item = item


func before_each() -> void:
	_item = Mock_Item.new()
	_item.create_interaction()
	_item.create_sprite()
	_item.create_data()
	_picked_up_called = false
	_picked_up_item = null
	add_child(_item)


func after_each() -> void:
	if _item == null:
		return
	_item.free_all()
	_item.free()
	_item = null


## Test that on_interact properly duplicates the item data and
## confirm that the item data in player inventory is the same as the original item data
func test_on_interact_duplicates_data() -> void:
	PlayerInventory.contents.fill(null)
	PlayerInventory.current_capacity = 0
	PlayerInventory.selectedIndex = 0

	_item._on_interact()

	var inventory_item: ItemData = PlayerInventory.get_item()
	assert_true(inventory_item != null, "Expected inventory to contain item data after interaction.")
	assert_true(inventory_item != _item.data, "Expected a duplicated ItemData resource, not the original reference.")
	assert_eq(inventory_item.type, _item.data.type, "Expected duplicated data type to match original.")
	assert_eq(inventory_item.name, _item.data.name, "Expected duplicated data name to match original.")
	assert_eq(inventory_item.description, _item.data.description, "Expected duplicated data description to match original.")
	assert_eq(inventory_item.size, _item.data.size, "Expected duplicated data size to match original.")
	assert_eq(inventory_item.weight, _item.data.weight, "Expected duplicated data weight to match original.")

## test that on_interact if result is false
func test_on_interact_result_false() -> void:
	PlayerInventory.contents.fill(null)
	PlayerInventory.current_capacity = 0
	PlayerInventory.selectedIndex = 0

	var existing_item_a := ItemData.new(ItemData.Type.GENERIC, "existing_a")
	var existing_item_b := ItemData.new(ItemData.Type.GENERIC, "existing_b")
	PlayerInventory.contents[0] = existing_item_a
	PlayerInventory.contents[1] = existing_item_b
	PlayerInventory.current_capacity = 2

	_item._on_interact()

	assert_eq(PlayerInventory.contents[0], existing_item_a, "Expected first inventory slot to remain unchanged when add fails.")
	assert_eq(PlayerInventory.contents[1], existing_item_b, "Expected second inventory slot to remain unchanged when add fails.")
	assert_eq(PlayerInventory.current_capacity, 2, "Expected inventory capacity to remain full when add fails.")
	assert_eq(_item.get_parent(), self, "Expected item to remain in scene when inventory add fails.")
	assert_eq(_item.is_queued_for_deletion(), false, "Expected item not to be queued for deletion when add fails.")

## test that on_interact if result is true
func test_on_interact_result_true() -> void:
	PlayerInventory.contents.fill(null)
	PlayerInventory.current_capacity = 0
	PlayerInventory.selectedIndex = 0

	_item.picked_up.connect(Callable(self, "_on_mock_item_picked_up"))
	_item._on_interact()

	assert_eq(PlayerInventory.current_capacity, 1, "Expected one item in inventory after successful pickup.")
	assert_true(PlayerInventory.contents[0] != null, "Expected first inventory slot to contain picked up item data.")
	assert_eq(_picked_up_called, true, "Expected picked_up signal to be emitted when add succeeds.")
	assert_eq(_picked_up_item, _item, "Expected picked_up signal to emit the interacted item.")
	assert_eq(_item.is_queued_for_deletion(), true, "Expected item to be queued for deletion after successful pickup.")
