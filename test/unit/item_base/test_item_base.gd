extends GutTest

## This test script is for the item_base.gd script which contains the
## node instance information and interaction data.

## This is a fake item_base class with added methods for easier testing
class mock_item:
	extends ItemBase
	
	func create_interaction()->void:
		self.iArea = InteractionArea.new()
	
	func create_sprite()->void:
		self.sprite = Sprite2D.new()
	
	func create_data()->void:
		var new_data:ItemData = ItemData.new(
			ItemData.Type.GENERIC,
			"mock_data",
			"This is fake item data.",
			Texture2D.new(),
			Texture2D.new(),
			1,
			1
		)
		self.data = new_data
	
	func free_all()->void:
		self.iArea.free()
		self.sprite.free()
		self.data.texture.free()
		self.data.uiTexture.free()
		self.data.free()



## Test initialization steps of creating an item base

## Test _on_interact() method conditionals
