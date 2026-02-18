extends Node
class_name TicketManager

var active_ticket: Ticket = null

# Reference to UI (assigned at runtime)
var ticket_ui: CanvasLayer
var title_label: RichTextLabel
var desc_label: RichTextLabel

func register_ui(ui: CanvasLayer):
	ticket_ui = ui
	title_label = ui.get_node("TicketTile")
	desc_label = ui.get_node("TicketDescription")

func request_ticket() -> Ticket:
	if active_ticket and active_ticket.status != Ticket.TicketStatus.FINISHED:
		return active_ticket

	active_ticket = generate_random_ticket()
	active_ticket.start()
	update_ui()
	return active_ticket

func generate_random_ticket() -> Ticket:
	var t := Ticket.new()
	var templates = [
		{
			"name": "Lost Package",
			"desc": "Find the missing package in the warehouse.",
			"goal": "Package found!",
			"reward": 50,
			"perf": 1
		},
		{
			"name": "Scanner Malfunction",
			"desc": "Diagnose the broken scanner.",
			"goal": "Scanner fixed!",
			"reward": 30,
			"perf": 1
		}
	]

	var data = templates.pick_random()
	t.ticket_name = data.name
	t.ticket_description = data.desc
	t.reached_goal_text = data.goal
	t.reward_money_amount = data.reward
	t.performance_increase = data.perf

	return t

func update_ui():
	if not active_ticket:
		return

	ticket_ui.visible = true
	title_label.text = active_ticket.ticket_name
	desc_label.text = active_ticket.ticket_description

func reach_goal():
	if active_ticket and active_ticket.status == Ticket.TicketStatus.STARTED:
		active_ticket.reach_goal()
		desc_label.text = active_ticket.reached_goal_text

func finish_ticket():
	if active_ticket and active_ticket.status == Ticket.TicketStatus.REACHED_GOAL:
		active_ticket.finish()
		ticket_ui.visible = false
