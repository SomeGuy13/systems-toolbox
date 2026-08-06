extends Node
class_name Saveable

@export var save_id: String = "" # Must be uniqe

func get_save_data() -> Dictionary:
	return {}

func load_save_data(data: Dictionary) -> void:
	pass
