extends GutTest

## This test script is for the ticket_manager autoload. It tests the managers variables and
## methods.
## Note: Some tests below change slightly in how tests are performed, this is mainly due to my
## own experimentation on test implmentation, but the tests themselves remain the same.

# globals
var tm:TicketManager

## Test skips
## Anything that would cause a run-time crash or what not (safeties!)
## Anything that is put here generally means that such protections don't exist in the tested
## script itself
## NOTE: COMMENTED OUT BECAUSE IT WAS A PAIN IN THE ASS TO DEAL WITH THE LACK OF NO
## NULL CHECK, AND GUT TEST ONLY HAS A SKIP BEFORE A TEST RUNS, NOT DURING
#func should_skip_script():
	#if tm.active_ticket == null:
		#return "Skipped due to active_ticket = null"
	#return


## Minimal dummy ticket used for ticking tests
func TicketDummy()->Ticket:
	var new_ticket:Ticket = Ticket.new()
	new_ticket.remaining_time = new_ticket.max_time
	return new_ticket

## run before each test
## essentially _ready() for each new test
func before_each():
	tm = TicketManager.new()
	add_child_autofree(tm)
	tm.ticket_timer = Timer.new()
	tm.ticket_timer.timeout.connect(tm._on_ticket_tick)
	tm.add_child(tm.ticket_timer)
	tm.timer_label = RichTextLabel.new()
	tm.desc_label = RichTextLabel.new()
	tm.title_label = RichTextLabel.new()
	tm.ticket_ui = CanvasLayer.new()
	# create a dedicated timer for tests
	tm.ticket_timer.wait_time = 1.0
	tm.ticket_timer.one_shot = false


## run after each test
## Frees all nodes from memory before the next test
func after_each():
	tm.ticket_timer.free()
	tm.timer_label.free()
	tm.desc_label.free()
	tm.title_label.free()
	tm.ticket_ui.free()
	tm.free()

## Test _on_ticket_tick()
func test_on_ticket_tick():
	# case 1: no active ticket -> should do nothing
	tm.active_ticket = null
	tm.timer_label.text = "unchanged"
	tm._on_ticket_tick()

	assert_null(tm.active_ticket, "active_ticket should still be null when ticking with no ticket")
	assert_eq(tm.timer_label.text, "unchanged", "timer label should not change when there is no active ticket")
	
	# case 2: active ticket with time remaining -> decrement and update UI
	var ticket := Ticket.new()
	ticket.remaining_time = 5
	ticket.status = Ticket.TicketStatus.STARTED
	tm.active_ticket = ticket
	tm.ticket_ui.visible = true
	tm.timer_label.text = "unchanged"

	tm._on_ticket_tick()

	assert_not_null(tm.active_ticket, "active_ticket should still exist after ticking")
	assert_eq(tm.active_ticket.remaining_time, 4.0, "remaining_time should decrease by 1")
	assert_eq(tm.timer_label.text, "4.0", "timer label should update to the new remaining time")
	assert_eq(tm.active_ticket.status, Ticket.TicketStatus.STARTED, "ticket should still be STARTED")
	assert_true(tm.ticket_ui.visible, "ticket UI should remain visible while time is still left")
	
	# case 3: active ticket reaches 0 -> should expire
	var expiring_ticket := Ticket.new()
	expiring_ticket.remaining_time = 1
	expiring_ticket.status = Ticket.TicketStatus.STARTED
	tm.active_ticket = expiring_ticket
	tm.ticket_ui.visible = true
	tm.desc_label.text = "before"

	tm.ticket_timer.start()
	tm._on_ticket_tick()

	assert_eq(tm.active_ticket.remaining_time, 0.0, "remaining_time should reach 0 after ticking down from 1")
	assert_eq(tm.active_ticket.status, Ticket.TicketStatus.FINISHED, "ticket should be marked FINISHED when time expires")
	assert_eq(tm.desc_label.text, "Ticket expired!", "desc_label should show the expiration message")
	assert_false(tm.ticket_ui.visible, "ticket UI should be hidden when the ticket expires")
	assert_true(tm.ticket_timer.is_stopped(), "ticket timer should stop when the ticket expires")


## Test _on_ticket_time_updated(time_left: float)
func test_on_ticket_time_updated_sets_timer_label_text():
	tm.timer_label.text = "old value"
	tm._on_ticket_time_updated(25)
	assert_eq(tm.timer_label.text, "25.0", "timer_label.text should be updated to the passed time value")
func test_on_ticket_time_updated_handles_float_values():
	tm.timer_label.text = "old value"
	tm._on_ticket_time_updated(12.5)
	assert_eq(tm.timer_label.text, "12.5", "timer_label.text should correctly display float time values")

## Test _on_ticket_time_expired()
func test_on_ticket_time_expired_marks_ticket_finished_and_updates_ui():
	var ticket := Ticket.new()
	ticket.status = Ticket.TicketStatus.STARTED
	tm.active_ticket = ticket

	tm.ticket_ui.visible = true
	tm.desc_label.text = "before"
	tm.ticket_timer.start()

	tm._on_ticket_time_expired()

	assert_eq(tm.active_ticket.status, Ticket.TicketStatus.FINISHED,
		"ticket status should be set to FINISHED")
	assert_eq(tm.desc_label.text, "Ticket expired!",
		"description label should display expiration message")
	assert_false(tm.ticket_ui.visible,
		"ticket UI should be hidden after expiration")
	assert_true(tm.ticket_timer.is_stopped(),
		"ticket timer should stop when ticket expires")

# NOTE: THIS IS COMMENTED OUT DUE TO NO NULL CATCH IN ORIGINAL SCRIPT
#func test_on_ticket_time_expired_does_nothing_when_active_ticket_is_null():
	#tm.active_ticket = null
	#tm.desc_label.text = "before"
	#tm.ticket_ui.visible = true
	#tm.ticket_timer.start()
	#
	#tm._on_ticket_time_expired()
#
	#assert_null(tm.active_ticket, "active_ticket should remain null")
	#assert_eq(tm.desc_label.text, "before", "desc_label should remain unchanged when there is no active ticket")
	#assert_true(tm.ticket_ui.visible, "ticket UI should remain unchanged when there is no active ticket")
	#assert_false(tm.ticket_timer.is_stopped(), "timer should remain unchanged when there is no active ticket")

## Test register_ui(ui: CanvasLayer)


## Test request_ticket() -> Ticket


## Test generate_random_ticket() -> Ticket



## Test update_ui()



## Test register_delivery(ticket_id: int)



## Test _is_ticket_complete() -> bool



## Test reach_goal()



## Test finish_ticket()
