extends Node2D
class_name TicketManager 

@onready var game_m = get_node("/root/Game/TicketTerminal")
@onready var TicketBox: CanvasLayer = game_m.get_node('TicketUI')
@onready var TicketTitle: RichTextLabel = TicketBox.get_node('TicketTile')
@onready var TicketDescription: RichTextLabel = TicketBox.get_node('TicketDescription')
# Called when the node enters the scene tree for the first time.


@export_group("TicketSettings")
@export var ticket_name: String 
@export var ticket_description: String 
@export var reached_goal_text: String #ui description text after reaching goal

#all ticket statuses 
enum TicketStatus {
	available, 
	started,
	reached_goal,
	finished,
}

@export var ticket_status: TicketStatus = TicketStatus.available

@export_group("RewardSettings")
@export var reward_money_amount: int
@export var performance_increase: int
