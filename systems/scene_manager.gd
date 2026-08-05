extends Node

var dependancies = ["EventBus"]
var _fade_overlay: CanvasLayer

func _check_dependencies(dependencies: Array[String]):
	for dependance in dependencies:
		if get_node_or_null("/root/%s" % dependance) == null:
			push_error("Autoload %s does not exist" % dependance)

func _ready() -> void:
	_check_dependencies(dependancies)
	
	_fade_overlay = CanvasLayer.new()
	add_child(_fade_overlay)

func load_scene(scene_path: String, fade_duration: float = 0.5) -> void:
	EventBus.scene_load_started.emit(scene_path)
	GameManager.set_game_state(GameManager.GameState.LOADING)
	
	await _fade_out(fade_duration)
	get_tree().change_scene_to_file(scene_path)
	await _fade_in(fade_duration)
	
	EventBus.scene_load_compete.emit(scene_path)
	GameManager.set_game_state(GameManager.GameState.LOADING)

func reload_current_scene(fade_duration: float = 0.5) -> void:
	var current_path = get_tree().current_scene.scene_file_path
	await load_scene(current_path, fade_duration)

func _fade_out(duration: float) -> void:
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.anchor_left = 0.0
	rect.anchor_top = 0.0
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.color.a = 0.0
	_fade_overlay.add_child(rect)
	
	var tween = create_tween()
	tween.tween_property(rect, "color.a", 1.0, duration)
	await tween.finished

func _fade_in(duration: float) -> void:
	var rect = _fade_overlay.get_child(0)
	var tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, duration)
	await tween.finished
	rect.queue_free()
