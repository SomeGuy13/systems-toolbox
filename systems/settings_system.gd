extends Node

var dependencies = ["EventBus"]

var _settings: Dictionary = {}
var _default_settings: Dictionary = {
	"audio/sfx_volume": 0.0,
	"audio/music_volume": 0.0,
}

func _check_dependencies(dependencies: Array[String]):
	for dependance in dependencies:
		if get_node_or_null("/root/%s" % dependance) == null:
			push_error("Autoload %s does not exist" % dependance)

func _ready() -> void:
	_check_dependencies(dependencies)
	
	_settings = _default_settings.duplicate()
	load_settings_from_file("user://settings.json")

func get_setting(key: String, default = null):
	return _settings.get(key, default if default != null else _default_settings.get(key))

func set_setting(key: String, value) -> void:
	_settings[key] = value
	EventBus.setting_changed.emit(key, value)

func save_settings_to_file(path: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	
	file.store_var(_settings)
	file.close()
	return true

func load_settings_from_file(path: String) -> bool:
	var data: FileAccess = FileAccess.open(path, FileAccess.READ)
	if data == null:
			return false
	
	var loaded_settings = data.get_var()
	data.close()
	
	if typeof(loaded_settings) != TYPE_DICTIONARY:
		return false
	
	_settings = loaded_settings
	return true
