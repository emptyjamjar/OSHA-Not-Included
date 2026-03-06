extends CanvasLayer

@onready var healthbar: TextureProgressBar = $Badge/HealthBar
@onready var energybar: TextureProgressBar = $Badge/StaminaBar
@onready var needsbar: TextureProgressBar = $Badge/NeedsBar
@onready var sanitybar: TextureProgressBar = $Badge/SanityBar
@onready var healthcomp: HealthComponent = $"../../Player/HealthComponent"
@onready var energycomp: EnergyComponent = $"../../Player/EnergyComponent"
@onready var needscomp: NeedsComponent = $"../../Player/NeedsComponent"
@onready var sanitycomp: SanityComponent = $"../../Player/SanityComponent"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	energybar.max_value = energycomp.MAX_ENERGY
	energybar.value = energycomp.energy


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	energybar.value = energycomp.energy

func update_money(money) -> void:
	$Background/Money.text = "Money: " + str(money)



func _on_health_component_health_change(diff: float) -> void:
	healthbar.max_value = healthcomp.get_max_health()
	healthbar.value = healthcomp.get_health()
	
	
func _on_needs_component_needs_change() -> void:
	needsbar.max_value = needscomp.get_max_needs()
	needsbar.value = needscomp.get_needs()
