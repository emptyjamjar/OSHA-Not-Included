class_name Conveyor extends Node2D
## The conveyor belt outputs items


@export_category("Item Lists")
## Preloaded resources of all possible ItemData that this conveyor can generate.
@export var item_resources : Array[ItemData]
##List of ItemData important to the story that this conveyor can generate.
@export var special_resources: Array[ItemData]

@export_category("Components")
##The Belt Tile_map
@export var tile_map: TileMapLayer
##The item spawner/despawner Tile_map
@export var spawn_despawn_map: TileMapLayer

@export_category("Values")
##How many random items will be spawned in between items that are required by the current tickets.
##Example: The current ticket needs a black bottle, the conveyor will queue up a black bottle with 
## 3 random_items in between each guaranteed black bottle.
@export var random_items: int = 3
## Affects how quickly items are moved/Animation speed
## (Default: 5)
@export var conveyor_speed:int = 5
## Affects how quickly items are output onto the conveyor belt
## (Default: 1)
@export var output_speed:int = 1
## How many items can be on the conveyor max.
@export var slots_max:int = 1

@export_category("Spawning Variables")
# Item Base scene
@export var item_scene : PackedScene

## The position where all items will be spawned from.
var _spawn_tile_pos: Vector2
## The position where items will be despawned from.
var _despawn_tile_pos: Vector2
## Cache of ItemData to be generated onto the conveyor.
var _queue:Array[ItemData] = []
## Collection of items spawned on the conveyor.
var _slots: Array[ItemBase] = []
## Timer for output speed control
var _output_timer: float = 0.0


func _ready() -> void:
	add_to_group("conveyor")
	# Fill item_resources with needed item data if it is somehow empty.
	if item_resources.is_empty():
		item_resources.append(preload("res://objects/items/toilet_paper/toilet_paper.tres"))
		item_resources.append(preload("res://objects/items/water_bottles/black_water_bottle.tres"))
		item_resources.append(preload("res://objects/items/water_bottles/blue_water_bottle.tres"))
		item_resources.append(preload("res://objects/items/water_bottles/pink_water_bottle.tres"))
	
	# Used to instantiate new children
	item_scene = load("res://objects/items/item_base.tscn")
	
	_slots.resize(slots_max)
	
	#Check all used cells in spawn_despawn_map
	for tile in spawn_despawn_map.get_used_cells():
		#If the tile is marked as a SpawnTile then set _spawn_tile_pos to that tile's global position.
		if spawn_despawn_map.get_cell_tile_data(tile).get_custom_data("SpawnTile") == true:
			_spawn_tile_pos = spawn_despawn_map.map_to_local(tile)
			_spawn_tile_pos = to_global(_spawn_tile_pos)
		#Does the same as above but for Despawn tile.
		if spawn_despawn_map.get_cell_tile_data(tile).get_custom_data("DeSpawnTile") == true:
			_despawn_tile_pos = spawn_despawn_map.map_to_local(tile)
			_despawn_tile_pos = to_global(_despawn_tile_pos)
	
	if(_spawn_tile_pos == null):
		printerr("No conveyor spawn tile. Make sure to draw the tile in the right Tilemap (Spawn Despawn Tilemap)")
	elif(_despawn_tile_pos == null):
		printerr("No conveyor despawn tile. Make sure to draw the tile in the right Tilemap (Spawn Despawn Tilemap)")


func _process(delta: float) -> void:
	# Process queue and spawn items onto belt at output_speed rate
	_output_timer += delta
	var output_interval = 1.0 / output_speed
	
	#TODO: CHANGE THIS.
	# PLACEHOLDER: Below will move into method later
	# Continue processing while enough time has passed and items are waiting in queue
	while _output_timer >= output_interval and _queue.size() > 0:
		# Subtract the output interval from the timer (allows multiple spawns per frame if needed)
		_output_timer -= output_interval
		# Remove the first item from the queue
		var item = _queue.pop_front()
		# Attempt to spawn the item into the first available slot on the belt
		_spawn_into_first_slot(item)
	
	if _queue.is_empty() and !Ticket_Manager.visible_queue.is_empty():
		_fill_queue()
	
	if !_slots.is_empty():
		_move_items()


## Adds an item to the conveyor
## @param item: item to be added
func input(item:ItemData)->void:
	_queue.push_back(item)


## Returns the front-most item in the conveyor
func output()->ItemData:
	return self._queue.pop_front()


func _move_items():
	Path2D
	for item in _slots:
		pass


## Fills queue with items, some are random, some are items from the current ticket queue.
func _fill_queue():
	#Get current visible tickets.
	var ticket_pool: Array[Ticket] = Ticket_Manager.visible_queue
	var ticket_items: Array[ItemData] = []
	
	#This grabs all the visible active tickets, and gets all the ItemData.id that's stored in a dictionary
	#within it. Then it takes those ids and converts them back into ItemData.
	for ticket in ticket_pool:
		var ticket_item_ids = ticket.required_items.keys()
		#Yes it's two for loops. I am so sorry. This is the only way.
		for id in ticket_item_ids:
			ticket_items.append(get_item_by_id(id))
	
	#Puts a relevant item into the queue
	input(ticket_items.pick_random())
	#Puts random items into the queue
	for i in range(random_items):
		input(item_resources.pick_random())


## Spawns an item into the first available slot on the conveyor belt.
## Creates a visual representation of the item at the slot position and stores
## the reference in the slots array. If all slots are occupied, the item is not spawned.
## PLACEHOLDER: contains print statements for debug (remove later)
## @param item: The Item data to spawn onto the conveyor belt
func _spawn_into_first_slot(item: ItemData) -> void:
	for i in _slots.size():
		if _slots[i] == null:
			# Create sprite of texture
			var scene := item_scene.instantiate() as ItemBase
			
			scene.rotation = self.rotation # for levels where conveyor is rotated
			
			# Connect to function to remove from list on pickup
			scene.picked_up.connect(_on_item_picked_up.bind(i))
			
			scene.data = item.duplicate(true)
			add_child(scene)
			#Spawn onto the spawn tile
			scene.global_position = _spawn_tile_pos
			_slots[i] = scene
			
			return
	# No free slots so add back to queue
	_queue.push_front(item)


## Removes item from conveyor slots using index
## Then disconnects the function from item signal
func _on_item_picked_up(item: ItemBase, index: int):
	_slots[index] = null
	item.picked_up.disconnect(_on_item_picked_up)


# functions to help return all the item in the conveyor array 
func get_all_items() -> Array[ItemData]: 
	return item_resources


func get_item_by_id(id: int) -> ItemData: 
	for item in item_resources: 
		if item.id == id: 
			return item
	return null 
