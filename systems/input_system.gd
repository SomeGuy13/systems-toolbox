# This input system works as a wrapper around Godot's input system.
# It is designed to allow for signals to comunicate with other systems
# and game components with signals for further decoupling.

extends Node

var _dependencies: Array[String] = ["EventBus"]
var _enabled: bool = true
var _actions: Array[String] = []

func _ready():
	_check_dependencies(_dependencies)
	_check_input_actions(_actions)

func _check_dependencies(dependencies: Array[String]):
	for dependance in dependencies:
		if get_node_or_null("/root/%s" % dependance) == null:
			push_error("Autoload $'%s' does not exist" % dependance)

func _check_input_actions(actions: Array[String]):
	for action in actions:
		if not InputMap.has_action(action):
			push_error("Missing input action" + action)

func _input(event: InputEvent):
	if not _enabled:
		return
	
	for action in _actions:
		if event.is_action_pressed(action):
			EventBus.input_action_pressed.emit(action)
			# get_tree().root.set_input_as_handled()
		elif event.is_action_released(action):
			EventBus.input_action_released.emit(action)

func get_enabled_state() -> bool:
	return _enabled

func set_enabled(enabled: bool):
	_enabled = enabled

func is_action_pressed(action: String):
	return Input.is_action_pressed(action) if _enabled else false

func get_action_strength(action: String):
	return Input.get_action_strength(action) if _enabled else 0.0

func add_action(action: String):
	_actions.append(action)
	
	_check_input_actions(_actions)
