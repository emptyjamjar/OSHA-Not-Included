## Stores data related to items which can be packaged.
extends Resource
class_name ItemData

enum Type {
	GENERIC,
	ANOMALOUS,
	CONSUMABLE,
	PACKAGE,
}

@export var type : Type
@export var name : String
# Used for vending machine
@export var price : float = 1.0
# Description shown on hover
@export_multiline var description : String
@export var texture: Texture2D
@export var uiTexture: Texture2D:
	get:
		if uiTexture == null:
			return texture
		return uiTexture
# How much space it takes up in inventories
@export var size : int
# Used for slowing player down
@export var weight : float
@export var id : int 
@export var required_items : Dictionary #{ticket_id: quantity}
## Consumable effects this item will do
var consumables:Array[Effect] = []
## anomalous effects this item will do
var anomalies:Array[Effect] = []



func _init(p_type := Type.GENERIC, p_name := "Item", p_description := "Item data.",
		p_texture : Texture2D = null, p_inv : Texture2D = null, p_size := 1, p_weight := 1
	) -> void:
	type = p_type
	name = p_name
	description = p_description
	# Item's texture defaults to godot icon
	texture = p_texture
	uiTexture = p_inv
	size = p_size
	weight = p_weight
	
func return_type():
	return type

## Adds a consumable effect to the item
## @param an_effect: Effect class that does something when consumed
## @return: true if successfully added to list of consumable effects, false otherwise
func add_consumable_effect(an_effect:Effect) -> bool:
	if an_effect != null:
		self._consumables.append(an_effect)
		return true
	return false

## Returns whether this item contains consumable effects or not
## @return: true if there are consumable effects, false otherwise
func has_consumables() -> bool:
	return consumables.size() > 0

## Returns an array of all consumable effects
## @return: Array containing consumable effects (if any)
func get_all_consumables() -> Array:
	return self._consumables

## Returns the next consumable effect
## @return: An effect if there is any consumable effects, returns null otherwise
func next_consumable() -> Effect:
	return self._consumables.pop_front()

## Removes all consumable effects
func clear_consumables() -> void:
	self._consumables.clear()

## Adds a anomalous effect to the item
## @param an_effect: Effect class that does an anomalous thing
## @return: true if successfully added to list of _anomalies, false otherwise
func add_anomalous_effect(an_effect:Effect) -> bool:
	if an_effect != null:
		self._anomalies.append(an_effect)
		return true
	return false

## Returns whether this item contains anomalous effects or not
## @return: true if there are _anomalies in this item, false otherwise
func has_anomalies() -> bool:
	return anomalies.size() > 0

## Returns an array of all anomalous effects
## @return: Array containing anomalous effects (if any)
func get_all_anomalies() -> Array:
	return self._anomalies

## Returns the next anomalous effect
## @return: An effect if there is any anomalous effects, returns null otherwise
func next_anomoly() -> Effect:
	return self._anomalies.pop_front()

## Removes all anomalous effects
func clear_anomalies() -> void:
	self._anomalies.clear()
