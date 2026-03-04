extends CanvasLayer

@onready var healthbar: TextureProgressBar = $Badge/HealthBar
@onready var energybar: TextureProgressBar = $Badge/StaminaBar
@onready var healthcomp: HealthComponent = $"../../Player/HealthComponent"
@onready var energycomp: EnergyComponent = $"../../Player/EnergyComponent"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthcomp.health_change.connect(update_health)
	update_health()
	energybar.max_value = energycomp.MAX_ENERGY
	energybar.value = energycomp.energy
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	energybar.value = energycomp.energy

func update_money(money) -> void:
	$Background/Money.text = "Money: " + str(money)

func update_health() -> void:
	healthbar.max_value = healthcomp.get_max_health()
	healthbar.value = healthcomp.get_health()
	print(healthbar.value)


func _on_health_component_health_change(diff: float) -> void:
	healthbar.max_value = healthcomp.get_max_health()
	healthbar.value = healthcomp.get_health()
	print(healthbar.value)
