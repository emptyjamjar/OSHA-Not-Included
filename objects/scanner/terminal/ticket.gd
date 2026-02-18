extends Resource
class_name Ticket

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

var status: TicketStatus = TicketStatus.AVAILABLE

func start():
	status = TicketStatus.STARTED

func reach_goal():
	status = TicketStatus.REACHED_GOAL

func finish():
	status = TicketStatus.FINISHED
