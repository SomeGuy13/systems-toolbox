extends Node

var dependencies = ["EventBus"]

const SAVE_PATH := "user://savegame.json"
@export var _project_id: String = "save_framework"
@export var _slot_id: int = 0

func _make_path() -> String:
	return SAVE_PATH.replace("savegame.json", "savegame_%d.json" % _slot_id)

func _check_dependencies(dependencies: Array[String]):
	for dependance in dependencies:
		if get_node_or_null("/root/%s" % dependance) == null:
			push_error("Autoload $'%s' does not exist" % dependance)

func _migrate(parsed: Dictionary) -> Dictionary:
	var v :Variant = parsed.get("version", 0)
	if v == 1:
		return parsed
	
	# Handle new version structure changes if needed
	
	return parsed

func _ready() -> void:
	_check_dependencies(dependencies)

func save_game() -> void:
	var root := {
		"version": 1,
		"project_id": _project_id,
		"slot_id": _slot_id,
		"entities": {}
	}
	
	for n in get_tree().get_nodes_in_group("saveables"):
		if not (n.has_method("get_save_data") and ("save_id" in n)):
			continue
		var sid := str(n.save_id)
		if sid == "":
			continue
		root["entities"][sid] = n.get_save_data()
	
	var file := FileAccess.open(_make_path(), FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing.")
		return
	
	file.store_string(JSON.stringify(root))
	file.close()
	
	EventBus.game_save_complete.emit()

func load_game() -> void:
	if not FileAccess.file_exists(_make_path()):
		return
	
	var file := FileAccess.open(_make_path(), FileAccess.READ)
	if file == null:
		return
	
	var text := file.get_as_text()
	file.close()
	
	var parsed : Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	if parsed.get("project_id", "") != _project_id:
		return
	
	var entities: Dictionary = parsed.get("entities", {})
	
	for n in get_tree().get_nodes_in_group("saveables"):
		if not (n.has_method("load_save_data") and ("save_id" in n)):
			continue
		var sid := str(n.save_id)
		if sid == "":
			continue
		
		var nd: Dictionary = entities.get(sid, null)
		if typeof(nd) == TYPE_DICTIONARY:
			n.load_save_data(nd)
	
	EventBus.game_load_complete.emit()
