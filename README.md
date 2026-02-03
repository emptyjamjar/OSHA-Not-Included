# single



## File Organizational Structure

```
res://
	addons/ # plugins
		docs/ # design notes, references, conventions
		tools/ # external scripts, imported stuff
	
	core/ # shared code used by many features/systems
		autoload/ # singleton managers (autoloads)
		components/ # reusables, like progressbars maybe, interactions
		systems/ # cross systems
			sanity/ # sanity system
			needs/ # food, restroom systems
			scoring/ # scoring system for packages?
			penalties/
		utils/ # Things like math, extensions, helper scripts, etc
		data/ # For things like enums, constants, groups, tags (.tres files?)

	game/ # actual game content, organized by feature
		actors/
			player/
			states/ # different player states (idle, carry, etc)
			ui/ # UI that are specific to the player
		manager/
			ai/
			states/ # different manager states

	objects/
		package/ # package(s) data
		data/ # package data/properties, perhaps such as type, weight, barcode, etc (nice palce for .tres files)
		conveyor/ # brings packages or items
		scanner/ # package scanner object to find out what it is?
		sorter/ # sorting object, if we're sorting packages/items
		packager/ # the packer object, if we are packaging items
		shelves/ # the shelves placed around the warehouse
		food/ # food items
		restroom/ # restroom (if its an object?)

	levels/
		warehouse_01/
			navigation/ # an example where to store nav info?
			layout/ # tilemaps, spawn points, etc
		warehouse_02/
		shared/ # level stuff that is reused across multiple levels (lights, environment)
	
	ui/
		hud/
		widgets/ # UI like timer, penalty popups, progress bars, package counters, warning icons
		menus/
		horror/ # psychological horror UI elements could be separated here
```
