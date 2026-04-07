extends Node2D

@onready var hud: CanvasLayer = $Camera2D/HUD
@onready var money := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for child in self.find_children("*"):
		print(child)


func _on_shipper_get_money() -> void:
	money += 10
	hud.update_money(money)
	
