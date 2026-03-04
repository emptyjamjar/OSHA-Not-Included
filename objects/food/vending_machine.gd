## VendingMachine - Interactive vending machine object
##
## StaticBody2D node that represents a physical vending machine in the world.
## Player can interact with this object to open the VendingSystem UI and purchase items.
## 
## Usage:
## - Attach to a StaticBody2D node in your scene
## - Assign an InteractionArea child node for player interaction detection
## - You can add ItemData resources to available_items to override default inventory
## - Manager NPCs in the "managers" group will prevent usage when nearby
##
## Dependencies:
## - Requires VendingSystem autoload singleton
## - Requires InteractionArea component
## - Works with ItemData resources


extends StaticBody2D
class_name VendingMachine

@export var machine_name: String = "Vending Machine"
@export var available_items: Array[ItemData] = []
@export var interaction_area: InteractionArea
@export var manager_interrupt_distance: float = 150.0

signal item_purchased(item: ItemData)

var is_menu_open: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set up interaction area
	if interaction_area:
		interaction_area.action_name = "use vending machine"
		interaction_area.interact = Callable(self, "_on_interact")
	
	# Connect to VendingSystem's close signal
	VendingSystem.vending_closed.connect(_on_vending_closed)

func _on_interact():
	if is_menu_open:
		return
	
	# Check if manager is nearby
	if _is_manager_nearby():
		print("Cannot use while being watched...")
		return
	
	_open_vending_menu()
	await VendingSystem.vending_closed

func _open_vending_menu():
	is_menu_open = true
	
	# Load items into VendingSystem if we have custom items
	if available_items.size() > 0:
		VendingSystem.set_shop_inventory(available_items)
	
	# Turn on the vending system
	VendingSystem.mode = VendingSystem.MODE.ON
	
	# Pause the game
	get_tree().paused = true

func _on_vending_closed():
	# Called when VendingSystem closes (from pressing U)
	if is_menu_open:
		is_menu_open = false
		get_tree().paused = false

func _is_manager_nearby() -> bool:
	var managers = get_tree().get_nodes_in_group("managers")
	for manager in managers:
		if manager and manager is Node2D:
			var distance = global_position.distance_to(manager.global_position)
			if distance < manager_interrupt_distance:
				return true
	return false
