class_name ItemReceipt extends TextureRect
## Reusable receipt class for the HUD inventory slots.
## Shows a receipt texture with an item.

## Item to be shown over the receipt texture.
@onready var item:TextureRect = $Item

## Sets the texture of [member item] to [param item_texture].
func set_item_texture(item_texture:Texture2D) -> void:
	item.texture = item_texture
