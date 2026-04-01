extends GutTest

## Description:
## These tests check TicketManager behavior for ticking time, expiring tickets,
## queue flow, timers, delivery registration, and finishing tickets.
##
## Changes:
## 1. Updated tests to call _on_ticket_tick(ticket) with a ticket argument.
## 2. Updated setup to use queue based state (visible_queue and active_ticket).
## 3. Updated timer tests to use per-ticket timers in the timers dictionary.
## 4. Updated expiration and finish tests to check queue removal and timer cleanup.
## 5. Replaced UI override in test double with update_queue_ui()
##
## Notes:
## The entire test needed major updates because TicketManager changed from older single-ticket logic to queue-based logic.
##The tick method now requires a ticket argument, and timers are tracked per ticket, so many old test assumptions no longer matched the real behavior.



## Test double for TicketManager to track UI updates without needing actual UI elements.
class TestTicketManager extends TicketManager:
	var update_ui_call_count: int = 0

	func update_queue_ui():
		update_ui_call_count += 1


var tm: TestTicketManager

## Helper function to create a dummy ticket with default values for testing.
func ticket_dummy() -> Ticket:
	var new_ticket: Ticket = Ticket.new()
	new_ticket.status = Ticket.TicketStatus.STARTED
	new_ticket.max_time = 30.0
	new_ticket.remaining_time = 30.0
	new_ticket.required_items = {}
	new_ticket.delivered_items = {}
	return new_ticket

## Helper function to add a timer for a ticket and track it in the test manager's timers dictionary.
func add_running_timer_for(ticket: Ticket) -> Timer:
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	tm.add_child(timer)
	tm.timers[ticket] = timer
	timer.start()
	return timer

## Setup function to initialize a fresh TestTicketManager before each test.
func before_each():
	tm = TestTicketManager.new()
	add_child_autofree(tm)
	tm.max_visible = 4

## Test that ticking a ticket decrements its remaining time and updates the UI when it does not expire.
func test_on_ticket_tick_decrements_time_and_updates_ui_once():
	var ticket := ticket_dummy()
	ticket.remaining_time = 5.0
	tm.visible_queue = [ticket]
	tm.active_ticket = ticket

	tm._on_ticket_tick(ticket)

	assert_eq(ticket.remaining_time, 4.0, "remaining_time should decrease by 1 each tick")
	assert_eq(ticket.status, Ticket.TicketStatus.STARTED, "ticket should remain STARTED while time is left")
	assert_eq(tm.update_ui_call_count, 1, "update_queue_ui should be called once when ticket does not expire")

## Test that ticking a ticket that expires it sets remaining time to 0, marks it as FINISHED, removes it from the queue, and stops its timer.
func test_on_ticket_tick_expires_ticket_and_removes_it_from_tracking():
	var ticket := ticket_dummy()
	ticket.remaining_time = 1.0
	tm.visible_queue = [ticket]
	tm.active_ticket = ticket
	var timer := add_running_timer_for(ticket)

	tm._on_ticket_tick(ticket)

	assert_eq(ticket.remaining_time, 0.0, "remaining_time should reach 0 on expiration tick")
	assert_eq(ticket.status, Ticket.TicketStatus.FINISHED, "expired ticket should be marked FINISHED")
	assert_false(tm.visible_queue.has(ticket), "expired ticket should be removed from visible_queue")
	assert_false(tm.timers.has(ticket), "expired ticket timer should be removed from timers dictionary")
	assert_true(timer.is_stopped(), "expired ticket timer should be stopped")
	assert_eq(tm.update_ui_call_count, 2, "update_queue_ui should be called by tick and expire handling")

## Test that fill_visible_queue promotes the first ticket to active and fills visible_queue up to max_visible.
func test_fill_visible_queue_sets_first_ticket_as_active():
	var t1 := ticket_dummy()
	t1.ticket_name = "T1"
	var t2 := ticket_dummy()
	t2.ticket_name = "T2"
	tm.max_visible = 1
	tm.all_tickets = [t1, t2]

	tm.fill_visible_queue()

	assert_eq(tm.visible_queue.size(), 1, "visible_queue should fill up to max_visible")
	assert_eq(tm.visible_queue[0], t1, "first queued ticket should be visible")
	assert_eq(tm.active_ticket, t1, "active_ticket should become first visible ticket")
	assert_eq(tm.all_tickets.size(), 1, "remaining tickets should stay in all_tickets")

## Test that start_timers_for_visible_queue creates one timer per visible ticket and starts them.
func test_start_timers_for_visible_queue_creates_one_timer_per_ticket():
	var t1 := ticket_dummy()
	var t2 := ticket_dummy()
	tm.visible_queue = [t1, t2]

	tm.start_timers_for_visible_queue()
	tm.start_timers_for_visible_queue()

	assert_eq(tm.timers.size(), 2, "each visible ticket should have exactly one timer")
	assert_true(tm.timers[t1].is_stopped() == false, "timer for first ticket should be running")
	assert_true(tm.timers[t2].is_stopped() == false, "timer for second ticket should be running")

## Test that register_delivery increments the delivered item count for the active ticket and returns true, or returns false if there is no active ticket.
func test_register_delivery_increments_delivered_count_and_returns_true():
	var ticket := ticket_dummy()
	ticket.required_items = {7: 2}
	ticket.delivered_items = {}
	tm.active_ticket = ticket
	tm.visible_queue = [ticket]

	var ok := tm.register_delivery(7)

	assert_true(ok, "register_delivery should return true when active_ticket exists")
	assert_eq(ticket.delivered_items[7], 1, "register_delivery should increment delivered item count")

## Test that register_delivery returns false if there is no active ticket to register the delivery for.
func test_register_delivery_returns_false_without_active_ticket():
	tm.active_ticket = null

	var ok := tm.register_delivery(7)

	assert_false(ok, "register_delivery should return false when there is no active ticket")

## Test that _is_ticket_complete returns true when all required items have been delivered for the active ticket.
func test_is_ticket_complete_returns_true_when_requirements_met():
	var ticket := ticket_dummy()
	ticket.required_items = {1: 2, 2: 1}
	ticket.delivered_items = {1: 2, 2: 1}
	tm.active_ticket = ticket

	var result := tm._is_ticket_complete()

	assert_true(result, "_is_ticket_complete should return true when all requirements are met")

## Test that reach_goal sets the active ticket's status to REACHED_GOAL and stops its timer.
func test_reach_goal_sets_status_and_stops_active_timer():
	var ticket := ticket_dummy()
	tm.active_ticket = ticket
	var timer := add_running_timer_for(ticket)

	tm.reach_goal()

	assert_eq(ticket.status, Ticket.TicketStatus.REACHED_GOAL, "reach_goal should set ticket status to REACHED_GOAL")
	assert_true(timer.is_stopped(), "active ticket timer should be stopped when goal is reached")

## Test that finish_ticket finalizes a reached-goal ticket, removes it from the queue, stops its timer, and promotes the next ticket to active.
func test_finish_ticket_removes_reached_goal_ticket_and_promotes_next():
	var finished_ticket := ticket_dummy()
	finished_ticket.status = Ticket.TicketStatus.REACHED_GOAL
	var next_ticket := ticket_dummy()
	next_ticket.status = Ticket.TicketStatus.STARTED
	tm.active_ticket = finished_ticket
	tm.visible_queue = [finished_ticket, next_ticket]
	var finished_timer := add_running_timer_for(finished_ticket)

	tm.finish_ticket()

	assert_eq(finished_ticket.status, Ticket.TicketStatus.FINISHED, "finish_ticket should finalize reached-goal ticket")
	assert_false(tm.visible_queue.has(finished_ticket), "finished ticket should be removed from visible_queue")
	assert_false(tm.timers.has(finished_ticket), "finished ticket timer should be removed from timers dictionary")
	assert_true(finished_timer.is_stopped(), "finished ticket timer should be stopped")
	assert_eq(tm.active_ticket, next_ticket, "next visible ticket should become active")

## Test that finish_ticket clears active_ticket and leaves visible_queue empty when the last ticket is finished.
func test_finish_ticket_clears_active_ticket_when_queue_becomes_empty():
	var ticket := ticket_dummy()
	ticket.status = Ticket.TicketStatus.REACHED_GOAL
	tm.active_ticket = ticket
	tm.visible_queue = [ticket]
	add_running_timer_for(ticket)

	tm.finish_ticket()

	assert_null(tm.active_ticket, "active_ticket should be cleared when no visible tickets remain")
	assert_eq(tm.visible_queue.size(), 0, "visible_queue should be empty after finishing the last ticket")
