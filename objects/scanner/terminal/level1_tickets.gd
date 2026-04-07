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
		}
	]
