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

@export var clock: Label
@export var clock_no_ticket: Label
var clock_time:float = 0
var clock_start:bool = false #If the timer should start.

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
	
	Ticket_Manager.tickets_generated.connect(start_clock)
	
	Ticket_Manager.ticket_timed_out.connect(_missed_quota)
	Ticket_Manager.ticket_submitted.connect(_submitted_quota)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	energybar.value = energycomp.energy
	if PlayerInventory.has_box():
		energycomp.draining = true
	else:
		energycomp.draining = false
	
	update_clock(delta)
	_update_quota()


func get_clock_time()->float:
	var tickets: Array[Ticket] = Ticket_Manager.all_tickets
	var sum_time: float = 0
	
	for ticket in tickets:
		sum_time += ticket.max_time
	
	return sum_time


func start_clock():
	clock_start = true
	clock_time = get_clock_time()


func update_clock(delta: float):
	if clock_start:
		clock.visible = true
		clock_no_ticket.visible = false
		
		clock_time -= delta
		
		var minutes: float = fmod(clock_time, 60.0)
		var minutes_text: String = str(int(minutes))
		
		#Just makes sure that single digit seconds fit the clock
		if minutes < 10:
			minutes_text = "0" + str(int(minutes))
		elif minutes < 0:
			minutes_text = "00"
		
		clock.text = str(int(clock_time/60)) +  ":" + minutes_text
	else:
		clock.visible = false
		clock_no_ticket.visible = true


func _update_quota():
	if clock_start:
		quota.text = str(Ticket_Manager.all_tickets.size() + Ticket_Manager.visible_queue.size())


##TODO: Add animation.
func _missed_quota():
	print("MISSED")
	#Play animation.


##TODO: Add animation.
func _submitted_quota():
	print("SUBMITTED")
	#Play animation.


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
