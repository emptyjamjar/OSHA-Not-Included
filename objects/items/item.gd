extends Resource

## This is a basic “data card” for any object in the game, like a tool, snack, 
## or weird artifact. It holds info like name, type, price, size, etc, but can also
## do special things like contain anomalous effects or be used benefically by
## storing consumable effects (or both).
##
## It’s meant to be stored, saved, and reused, not shown on screen directly.
## For that, you’d use a separate visual node that reads this data.


enum Type
{
	NONE,
	TEST, # item is for testing purposes
	BIOLOGICAL, # plants, or anything that is living or was?
	CONSUMABLE, # toilet paper, water bottles, snacks, energy tricks, good, etc
	RECOVERY_ITEM, # items that restore sanity, stamina, or other non-hp stats?
	TOOL, # wrench, screwdriver, flashlight, battery
	STORAGE, # box, crate, pallet, toolbox
	SAFETY, # vest, hard hat, gloves, fire extinguisher
	ELECTRONC, # phone, camera, radio, flashlight, tablet, computer
	DOCUMENT, # notebook, pen, clipboard, manifest, keycard
	FURNITURE, # chair, desk, shelf, locker
	MEDICAL, # first aid kit, bandages, medicine, suringes
	CLEANING, # mop, broom, bucket, cleaning supplies, soap
	CLOTHING, # jacket, pants, shoes, uniform
	EXPLOSIVE, # explosive items
	LUXURY, # non-essential comfort items (cigarettes, whiskey, perfume, silk stuff
	HORROR, # items tied to gear, dread, or supernatural effects (ex bloody diary)
	MISCELLANEOUS # catch all for anything that doesn't in the other categories
}

var _type: Type = Type.NONE
var _name: String = ""
var _description: String = ""
var _price: float = 0.00
var _size: Vector2 = Vector2(0, 0)
var _weight: float = 0.00
var _color: Color = Color.TRANSPARENT
var _texture_small: NinePatchRect = null
var _texture_large: NinePatchRect = null
var _anomaly_effects: Array[]
