extends Node

var dependencies = ["EventBus"]

var _hud: Control
var _panels: Dictionary = {}
var _notification_label: Label

func _check_dependencies(dependencies: Array[String]):
	for dependance in dependencies:
		if get_node_or_null("/root/%s" % dependance) == null:
			push_error("Autoload $'%s' does not exist" % dependance)

func _ready() -> void:
	_check_dependencies(dependencies)
	
	_hud = Control.new()
	add_child(_hud)
	
	# Listen to signals to respond to here

func show_hud() -> void:
	_hud.visible = true

func hide_hud() -> void:
	_hud.visible = false

func _show_pannel(panel_name: String) -> void:
	if panel_name in _panels:
		_panels[panel_name].visible = true

func _hide_panel(panel_name: String) -> void:
	if panel_name in _panels:
		_panels[panel_name].visible = false

func _show_notification(text: String, duration: float = 2.0) -> void:
	if _notification_label:
		_notification_label.text = text
		_notification_label.visible = true
		await get_tree().create_timer(duration).timeout
		_notification_label.visible = false
