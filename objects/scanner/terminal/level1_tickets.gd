extends Resource

func get_templates() -> Array: 
	return [
		{
			"id": 1,
			"name": "Lost Package",
			"desc": "Find the missing package in the warehouse.",
			"goal": "Package found!",
			"reward": 50,
			"perf": 1, 
			"time_min": 60, 
			"time_max": 60, 
			"min_items": 1, 
			"max_items": 1
		},
		{
			"id": 2,
			"name": "Scanner Malfunction",
			"desc": "Diagnose the broken scanner.\nShip the replacement parts!",
			"goal": "Parts fixed!",
			"reward": 30,
			"perf": 1, 
			"time_min": 80, 
			"time_max": 80, 
			"min_items": 1,
			"max_items": 1
		},
		{
			"id": 3,
			"name": "School Supplies!",
			"desc": "School comeback begins.\nShip the wanted items!",
			"goal": "Supplies shipped!",
			"reward": 30,
			"perf": 1, 
			"time_min": 80, 
			"time_max": 80, 
			"min_items": 1,
			"max_items": 1
		},
		{
			"id": 4,
			"name": "Item Shortage",
			"desc": "Help family to buy the missing items!",
			"goal": "Order finished!",
			"reward": 30,
			"perf": 1, 
			"time_min": 80, 
			"time_max": 80, 
			"min_items": 1,
			"max_items": 1
		},
		{
			"id": 5,
			"name": "Energy Advertising",
			"desc": "New boost energy drinks! Plus ++",
			"goal": "Order finished!",
			"reward": 30,
			"perf": 1, 
			"time_min": 80, 
			"time_max": 80, 
			"min_items": 1,
			"max_items": 1
		},
		{
			"id": 6,
			"name": "Ghost Emerging!",
			"desc": "Seal the lost soul to get good fortune!",
			"goal": "Amazing!",
			"reward": 30,
			"perf": 1, 
			"time_min": 80, 
			"time_max": 80, 
			"min_items": 1,
			"max_items": 1
		}
	]
