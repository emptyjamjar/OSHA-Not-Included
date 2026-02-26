extends Resource

## This is a basic “data card” for any object in the game, like a tool, snack, 
## or weird artifact. It holds info like name, type, price, size, etc, but can also
## do special things like contain anomalous effects or be used benefically by
## storing consumable effects (or both).
##
## It’s meant to be stored, saved, and reused, not shown on screen directly.
## For that, you’d use a separate visual node that reads this data.

# Attributes #
enum Type
{
	NONE,
	TEST,			# item is for testing purposes
	BIOLOGICAL, 	# plants, or anything that is living or was?
	CONSUMABLE, 	# toilet paper, water bottles, snacks, energy tricks, good, etc
	RECOVERY_ITEM, 	# items that restore sanity, stamina, or other non-hp stats?
	TOOL, 			# wrench, screwdriver, flashlight, battery
	STORAGE, 		# box, crate, pallet, toolbox
	SAFETY, 		# vest, hard hat, gloves, fire extinguisher
	ELECTRONC, 		# phone, camera, radio, flashlight, tablet, computer
	DOCUMENT, 		# notebook, pen, clipboard, manifest, keycard
	FURNITURE, 		# chair, desk, shelf, locker
	MEDICAL, 		# first aid kit, bandages, medicine, suringes
	CLEANING, 		# mop, broom, bucket, cleaning supplies, soap
	CLOTHING, 		# jacket, pants, shoes, uniform
	EXPLOSIVE, 		# explosive items
	LUXURY, 		# non-essential comfort items (cigarettes, whiskey, perfume, silk stuff
	HORROR, 		# items tied to gear, dread, or supernatural effects (ex bloody diary)
	MISCELLANEOUS 	# catch all for anything that doesn't in the other categories
}

var _type: Type = Type.NONE
var _item_name: String = ""
var _description: String = ""
var _price: float = 0.00
var _size: Vector2 = Vector2(0, 0)
var _weight: float = 0.00
var _color: Color = Color.TRANSPARENT
var _texture_small: NinePatchRect = null
var _texture_large: NinePatchRect = null
var _anomaly_effects: Array[Effect] = []
var _consumable_effects: Array[Effect] = []

## Basic constructor for item
func _init(type: Type = Type.NONE, item_name: String = "No_Name") -> void:
	_type = type
	_item_name = item_name

# API methods #


# Getter/Setters #
## Sets the item’s category type (e.g., CONSUMABLE, TOOL, MEDICAL)
## @param new_type: Type - The new item type to assign
func set_type(new_type: Type) -> void:
	_type = new_type

## Gets the item’s category type
## @return: Type - The current item type
func get_type() -> Type:
	return _type

## Sets the item’s display name
## @param new_name: String - The new name to assign
func set_item_name(new_name: String) -> void:
	_item_name = new_name

## Gets the item’s display name
## @return: String - The current item name
func get_item_name() -> String:
	return _item_name

## Sets the item’s description (for tooltips or logs)
## @param new_desc: String - The new description text
func set_description(new_desc: String) -> void:
	_description = new_desc

## Gets the item’s description
## @return: String - The current description
func get_description() -> String:
	return _description

## Sets the item’s price or value
## @param new_price: float - The new price (can be 0 for free items)
func set_price(new_price: float) -> void:
	_price = new_price

## Gets the item’s price
## @return: float - The current price
func get_price() -> float:
	return _price

## Sets the item’s size (width, height) for inventory or physics
## @param new_size: Vector2 - The new size (e.g., Vector2(32, 32))
func set_size(new_size: Vector2) -> void:
	_size = new_size

## Gets the item’s size
## @return: Vector2 - The current size
func get_size() -> Vector2:
	return _size

## Sets the item’s weight (for carrying limits or physics)
## @param new_weight: float - The new weight value
func set_weight(new_weight: float) -> void:
	_weight = new_weight

## Gets the item’s weight
## @return: float - The current weight
func get_weight() -> float:
	return _weight

## Sets the item’s visual color tint
## @param new_color: Color - The new color (e.g., Color.RED)
func set_color(new_color: Color) -> void:
	_color = new_color

## Gets the item’s color tint
## @return: Color - The current color
func get_color() -> Color:
	return _color

## Sets the small icon texture (for inventory or UI)
## @param new_texture: NinePatchRect - The new small texture
func set_texture_small(new_texture: NinePatchRect) -> void:
	_texture_small = new_texture

## Gets the small icon texture
## @return: NinePatchRect - The current small texture
func get_texture_small() -> NinePatchRect:
	return _texture_small

## Sets the large display texture (for world or detail view)
## @param new_texture: NinePatchRect - The new large texture
func set_texture_large(new_texture: NinePatchRect) -> void:
	_texture_large = new_texture

## Gets the large display texture
## @return: NinePatchRect - The current large texture
func get_texture_large() -> NinePatchRect:
	return _texture_large

## Adds an anomaly effect to the item
## @param effect: Effect - The effect to add
func add_anomaly_effect(effect: Effect) -> void:
	if not _anomaly_effects.has(effect):
		_anomaly_effects.append(effect)

## Removes an anomaly effect from the item
## @param effect: Effect - The effect to remove
## @return: bool - True if removed, false if not found
func remove_anomaly_effect(effect: Effect) -> bool:
	if _anomaly_effects.has(effect):
		_anomaly_effects.erase(effect)
		return true
	return false

## Gets all anomaly effects
## @return: Array[Effect] - List of all anomaly effects
func get_anomaly_effects() -> Array[Effect]:
	return _anomaly_effects.duplicate()

## Adds a consumable effect to the item
## @param effect: Effect - The effect to add
func add_consumable_effect(effect: Effect) -> void:
	if not _consumable_effects.has(effect):
		_consumable_effects.append(effect)

## Removes a consumable effect from the item
## @param effect: Effect - The effect to remove
## @return: bool - True if removed, false if not found
func remove_consumable_effect(effect: Effect) -> bool:
	if _consumable_effects.has(effect):
		_consumable_effects.erase(effect)
		return true
	return false

## Gets all consumable effects
## @return: Array[Effect] - List of all consumable effects
func get_consumable_effects() -> Array[Effect]:
	return _consumable_effects.duplicate()

# Utility / Helper Methods #

## Clears all effects (anomaly and consumable)
func clear_all_effects() -> void:
	_anomaly_effects.clear()
	_consumable_effects.clear()

## Creates a deep copy of this item
## @return:Item - A new Item instance with same data
func clone() -> Item:
	var new_item = Item.new()
	new_item.set_type(_type)
	new_item.set_item_name(_item_name)
	new_item.set_description(_description)
	new_item.set_price(_price)
	new_item.set_size(_size)
	new_item.set_weight(_weight)
	new_item.set_color(_color)
	new_item.set_texture_small(_texture_small)
	new_item.set_texture_large(_texture_large)
	new_item._anomaly_effects = _anomaly_effects.duplicate()
	new_item._consumable_effects = _consumable_effects.duplicate()
	return new_item

## Exports item data as a dictionary
## @return: Dict -Dictionary containing all item properties
func export_to_dict() -> Dictionary:
	return {
		"type": _type,
		"name": _item_name,
		"description": _description,
		"price": _price,
		"size": _size,
		"weight": _weight,
		"color": _color,
		"texture_small": _texture_small,
		"texture_large": _texture_large,
		"anomaly_effects": _anomaly_effects,
		"consumable_effects": _consumable_effects
	}

## Resets item to base state (keeps type and name, clears effects, resets price/size/weight)
func reset_to_defaults() -> void:
	_description = ""
	_price = 0.0
	_size = Vector2(0, 0)
	_weight = 0.0
	_color = Color.TRANSPARENT
	_texture_small = null
	_texture_large = null
	clear_all_effects()

# Query methods #

## Checks if the item has at least one anomaly effect
## @return: bool - True if has anomaly effects, false otherwise
func is_anomalous() -> bool:
	return _anomaly_effects.size() > 0

## Checks if the item has at least one consumable effect
## @return: bool - True if has consumable effects, false otherwise
func is_consumable() -> bool:
	return _consumable_effects.size() > 0

## Checks if the item has any effects (anomaly or consumable)
## @return: bool - True if has any effects, false otherwise
func has_effects() -> bool:
	return _anomaly_effects.size() > 0 or _consumable_effects.size() > 0

## Gets the total number of effects (anomaly + consumable)
## @return: int - Total effect count
func get_total_effects_count() -> int:
	return _anomaly_effects.size() + _consumable_effects.size()

## Gets the number of anomaly effects
## @return: int - Count of anomaly effects
func get_anomaly_count() -> int:
	return _anomaly_effects.size()

## Gets the number of consumable effects
## @return: int - Count of consumable effects
func get_consumable_count() -> int:
	return _consumable_effects.size()

## Checks if the item is empty (no effects), zero price, empty name
## @return: bool - True if all criteria met, false otherwise
func is_empty() -> bool:
	return (
		_anomaly_effects.size() == 0 and
		_consumable_effects.size() == 0
	)

## Gets unique effect type names from all effects (anomaly + consumable)
## @return: Array[String] - List of unique type names (e.g., ["BUFF", "HAZARD"])
func get_effect_types() -> Array[String]:
	var types = []
	for effect in _anomaly_effects:
		var type_name = effect.get_type_name()
		if not types.has(type_name):
			types.append(type_name)
	for effect in _consumable_effects:
		var type_name = effect.get_type_name()
		if not types.has(type_name):
			types.append(type_name)
	return types

## Gets display names of all effects (anomaly + consumable)
## @return: Array[String] - List of effect names (e.g., ["Adrenaline Boost", "Poison Cloud"])
func get_effect_names() -> Array[String]:
	var names = []
	for effect in _anomaly_effects:
		names.append(effect.get_effect_name())
	for effect in _consumable_effects:
		names.append(effect.get_effect_name())
	return names

## Calculates value per weight (price / weight) — useful for inventory optimization
## @return: float - Value per unit weight, or 0 if weight is 0
func get_value_per_weight() -> float:
	if _weight == 0:
		return 0.0
	return _price / _weight

## Calculates volume (width × height) — useful for inventory space or physics
## @return: float - Volume (size.x * size.y)
func get_volume() -> float:
	return _size.x * _size.y

## Checks if this item can stack with another item (same type, name, effects)
## @param other: Item - The item to compare with
## @return: bool - True if stackable, false otherwise
func is_stackable_with(other: Item) -> bool:
	if not other:
		return false
	if _type != other.get_type():
		return false
	if _item_name != other.get_item_name():
		return false
	if _anomaly_effects.size() != other.get_anomaly_count():
		return false
	if _consumable_effects.size() != other.get_consumable_count():
		return false
	# Optional: Deep compare effect contents if needed
	return true

## Checks if any effect (anomaly or consumable) matches a given class name
## @param effect_class: String - The class/type name to check (e.g., "BUFF", "HAZARD")
## @return: bool - True if any effect matches, false otherwise
func has_any_effect_of_type(effect_class: String) -> bool:
	for effect in _anomaly_effects:
		if effect.get_type_name() == effect_class:
			return true
	for effect in _consumable_effects:
		if effect.get_type_name() == effect_class:
			return true
	return false

## Returns the first effect (anomaly or consumable) matching a given name
## @param name: String - The effect name to search for
## @return: Effect - First matching effect, or null if not found
func get_effect_by_name(name: String) -> Effect:
	for effect in _anomaly_effects:
		if effect.get_effect_name() == name:
			return effect
	for effect in _consumable_effects:
		if effect.get_effect_name() == name:
			return effect
	return null
