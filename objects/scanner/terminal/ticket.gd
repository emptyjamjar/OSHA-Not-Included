extends Resource
class_name Ticket

## Individual ticket for orders. Tracks the status
## of player's ticket progress.

signal time_updated(remaining_time: float)
signal time_expired

enum TicketStatus {
	AVAILABLE,
	STARTED,
	REACHED_GOAL,
	FINISHED
}

@export var ticket_name: String
@export var ticket_description: String
@export var reached_goal_text: String

@export var reward_money_amount: int
@export var performance_increase: int

@export var required_items : Dictionary = {} #{ticket_id: quantity}
var delivered_items : Dictionary = {} #{ticket_id: quantity}


var status: TicketStatus = TicketStatus.AVAILABLE

#Timer settings
var max_time: float = 30.0 #seconds per ticket 
var remaining_time : float = 0.0

func start():
	status = TicketStatus.STARTED
	remaining_time = max_time


func reach_goal():
	status = TicketStatus.REACHED_GOAL

func finish():
	status = TicketStatus.FINISHED
