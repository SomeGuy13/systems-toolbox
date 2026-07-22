extends GutTest

func test_get_enabled():
	var input_state = InputSystem.get_enabled_state() # Should be true

	assert_eq(input_state, true)

func test_set_enabled_false():
	InputSystem.set_enabled(false)
	var input_state = InputSystem.get_enabled_state() # Should be false
	assert_eq(input_state, false)
	
	InputSystem.set_enabled(true)
	input_state = InputSystem.get_enabled_state() # Should be true
	assert_eq(input_state, true)

func test_add_input_action():
	InputSystem.add_action("test_action")
	assert_eq(["test_action"], ["test_action"])
	# Input action created here persists through all the other tests

func test_input_pressed_signal_emitted():
	watch_signals(EventBus)
	
	InputSystem.set_enabled(true)
	InputSystem.add_action("test_action_2")
	
	# Event for testing input
	var event = InputEventAction.new()
	event.action = "test_action_2"
	event.pressed = true
	
	InputSystem._input(event)
	
	assert_signal_emitted_with_parameters(EventBus.input_action_pressed, ["test_action_2"])
	
	event.pressed = false
	
	InputSystem._input(event)
	
	assert_signal_emitted_with_parameters(EventBus.input_action_released, ["test_action_2"])

func test_no_input_emit_on_disable():
	watch_signals(EventBus)
	
	InputSystem.set_enabled(false)
	InputSystem.add_action("test_action_3")
	
	# Event for testing input
	var event = InputEventAction.new()
	event.action = "test_action_3"
	event.pressed = true
	
	InputSystem._input(event)
	
	assert_signal_not_emitted(EventBus.input_action_pressed)
	
	event.pressed = false
	
	InputSystem._input(event)
	
	assert_signal_not_emitted(EventBus.input_action_released)
