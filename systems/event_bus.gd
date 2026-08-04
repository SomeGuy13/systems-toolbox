# This event bus contains only signals which is how all other
# systems talk to each other. This event bus should have no
# other logic than signals.

extends Node

# InputSystem Signals
signal input_action_pressed(action: String)
signal input_action_released(action: String)

# AudioSystem Signals
