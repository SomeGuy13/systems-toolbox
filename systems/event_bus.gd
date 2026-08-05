# This event bus contains only signals which is how all other
# systems talk to each other. This event bus should have no
# other logic than signals.

extends Node

# GameManager Signals
signal game_state_changed(new_state: GameManager.GameState)

# InputSystem Signals
signal input_action_pressed(action: String)
signal input_action_released(action: String)

# SceneManager Signals
signal scene_load_started(scene_name: String)
signal scene_load_finished(scene_name: String)

# SettingsSystem Signals
signal setting_changed(key: String, value)
