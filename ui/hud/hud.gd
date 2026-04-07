extends Control

@onready var healthbar: TextureProgressBar = $Badge/HealthBar
@onready var energybar: TextureProgressBar = $Badge/StaminaBar
@onready var needsbar: TextureProgressBar = $Badge/NeedsBar
@onready var sanitybar: TextureProgressBar = $Badge/SanityBar
@onready var inventory: TextureRect = $Inventory
@onready var healthcomp: HealthComponent = $"../../Player/HealthComponent"
@onready var energycomp: EnergyComponent = $"../../Player/EnergyComponent"
@onready var needscomp: NeedsComponent = $"../../Player/NeedsComponent"
@onready var sanitycomp: SanityComponent = $"../../Player/SanityComponent"

@export var anim_player: AnimationPlayer

@export var clock: LevelClock

@export var productivity_manager: ProductivityManager
var ticket_manager: TicketManager

@export var quota: Label
var quota_size: int
var old_quota_size: int

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
	
	if productivity_manager == null:
		printerr("Connect Score Node (Under UI) to HUD's productivity_manager export var (Under Camera2D)")
	##IMPORTANT: READ THE ERROR ABOVE THIS MESSAGE IF YOU GET AN ERROR POINTING TO HERE.
	print(productivity_manager)
	clock.deduct_productivity.connect(productivity_manager.add_productivity)
	
	ticket_manager = get_tree().get_first_node_in_group("Ticket Manager")
	
	ticket_manager.ticket_timed_out.connect(_missed_quota)
	ticket_manager.ticket_submitted.connect(_submitted_quota)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	energybar.value = energycomp.energy
	if PlayerInventory.has_box():
		energycomp.draining = true
	else:
		energycomp.draining = false
	
	_update_quota()


func _update_quota():
	quota.text = str(ticket_manager.all_tickets.size() + ticket_manager.visible_queue.size())


##TODO: Add animation.
func _missed_quota():
	#Play animation.
	print("FASDDDDDDDDDDDDDDDDDDDDdd")
	anim_player.play("TicketMissed")


##TODO: Add animation.
func _submitted_quota():
	#Play animation.
	anim_player.play("TicketSubmitted")


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
