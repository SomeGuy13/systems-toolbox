extends Node

var dependencies = ["EventBus", "InputSystem"]
enum GameState { MENU, LOADING, PLAYING, PAUSED, GAME_OVER, CUTSCENE }

var _current_state: GameState = GameState.MENU

func _check_dependencies(dependencies: Array[String]):
	for dependance in dependencies:
		if get_node_or_null("/root/%s" % dependance) == null:
			push_error("Autoload %s does not exist" % dependance)

func _ready() -> void:
	_check_dependencies(dependencies)

func set_game_state(new_state: GameState) -> void:
	if new_state == _current_state:
		return
	
	_current_state = new_state
	
	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
			InputSystem.set_enabled(false)
		GameState.PLAYING:
			get_tree().paused = false
			InputSystem.set_enabled(true)
		GameState.CUTSCENE:
			InputSystem.set_enabled(false)
		_:
			pass
	
	EventBus.game_state_changed.emit(new_state)

func get_current_game_state() -> GameState:
	return _current_state
