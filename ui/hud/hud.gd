extends CanvasLayer

@onready var healthbar: TextureProgressBar = $Badge/HealthBar
@onready var energybar: TextureProgressBar = $Badge/StaminaBar
@onready var needsbar: TextureProgressBar = $Badge/NeedsBar
@onready var sanitybar: TextureProgressBar = $Badge/SanityBar
@onready var inventory: TextureRect = $Inventory
@onready var healthcomp: HealthComponent = $"../../Player/HealthComponent"
@onready var energycomp: EnergyComponent = $"../../Player/EnergyComponent"
@onready var needscomp: NeedsComponent = $"../../Player/NeedsComponent"
@onready var sanitycomp: SanityComponent = $"../../Player/SanityComponent"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	energybar.max_value = energycomp.MAX_ENERGY
	energybar.value = energycomp.energy
	healthbar.max_value = healthcomp.MAX_HEALTH
	healthbar.value = healthcomp.health
	sanitybar.max_value = sanitycomp.sanity_cap
	sanitybar.value = sanitycomp.sanity_cap
	needsbar.max_value = needscomp.MAX_NEEDS
	needsbar.value = needscomp.needs


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	energybar.value = energycomp.energy
	if PlayerInventory.has_box():
		energycomp.draining = true
	else:
		energycomp.draining = false
	

func update_money(money) -> void:
	$Background/Money.text = str(money)



func _on_health_component_health_change(_diff: float) -> void:
	healthbar.max_value = healthcomp.get_max_health()
	healthbar.value = healthcomp.get_health()
	
	
func _on_needs_component_needs_change() -> void:
	needsbar.max_value = needscomp.get_max_needs()
	needsbar.value = needscomp.get_needs()


func _on_energy_component_energy_change() -> void:
	energybar.max_value = energycomp.get_max_energy()
	energybar.value = energycomp.get_energy()


func _on_sanity_component_sanity_changed(new_value: int) -> void:
	sanitybar.max_value = sanitycomp.get_max_sanity()
	sanitybar.value = sanitycomp.get_sanity()
