extends TextureRect

class_name LevelClock

signal deduct_productivity(val: int) ## For changing productivity. Used in Hud.gd

@export var clock: Label ##Label showing clock
@export var clock_no_ticket: Label ##Label to show when terminal has not been turned on.
@export var level_time: float = 0
@export var productivity_decay: int = 2 ##How many seconds you need to be in overtime until 1 point of productivity is deducted.
@export var anim_player: AnimationPlayer

var clock_time:float = 0
var performance: float = 0 ## How much the player will be deducted for not doing their job fast enough.
var clock_start:bool = false ##If the timer should start.



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Ticket_Manager.tickets_generated.connect(start_clock)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_clock(delta)


func start_clock():
	clock_start = true
	clock_time = get_clock_time()


func update_clock(delta: float):
	if clock_start:
		clock.visible = true
		clock_no_ticket.visible = false
		
		#If time has run out
		if clock_time <= 0:
			
			performance -= delta / productivity_decay
			#This is just because productivity is an int so small values just become 0 and nothing happen.
			if performance <= -1:
				deduct_productivity.emit(performance)
				performance = 0
		
		#If the time hasn't run out.
		else:
			#Special animation for low time.
			if (clock_time <= 30):
				anim_player.play("LowTime")
			else:
				anim_player.play("RESET")
			
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
		anim_player.play("LogIntoTerminal")
		clock.visible = false
		clock_no_ticket.visible = true


func get_clock_time()->float:
	if level_time <= 0:
		var tickets: Array[Ticket] = Ticket_Manager.all_tickets
		var sum_time: float = 0
		
		for ticket in tickets:
			sum_time += ticket.max_time
		
		return sum_time * .75
	#This is case we decide to have a customized time limit for the level instead of automatically generating it.
	#If we decide to have a cuztomized time per level just set level_time
	else:
		return level_time

##Animation when the timer is still going but has reached 0.
func overtime_animation():
	pass
