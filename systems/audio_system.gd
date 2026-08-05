extends Node

var dependencies = ["EventBus", "SettingsSystem"]
const SOUND_PATH = "res://assets/sounds/"

var _sfx_player_pool: Array[AudioStreamPlayer]
var _sfx_volume_db: float = 0.0
var _music_player: AudioStreamPlayer
var _music_volume_db: float = 0.0
var _music_tween: Tween

func _check_dependencies(dependencies: Array[String]):
	for dependance in dependencies:
		if get_node_or_null("/root/%s" % dependance) == null:
			push_error("Autoload %s does not exist" % dependance)

func _ready() -> void:
	_check_dependencies(dependencies)
	_populate_sfx_pool(8)
	
	_music_player = AudioStreamPlayer.new()
	
	EventBus.setting_changed.connect(_handle_audio_settings_changed)

func _populate_sfx_pool(players: int) -> void:
	for i in range(players):
		var player = AudioStreamPlayer.new()
		add_child(player)
		_sfx_player_pool.append(player)

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_player_pool:
		if not player.is_playing():
			return player
	return _sfx_player_pool[0]

func _handle_audio_settings_changed(key, value):
	match key:
		"audio/sfx_volume":
			set_sfx_volume(value)
		"audio/music_volume":
			set_music_volume(value)
		_:
			pass

func play_sound(sound_key: String, volume_db: float = _sfx_volume_db) -> void:
	var player := _get_available_sfx_player()
	var path := SOUND_PATH + sound_key + ".wav"
	var stream := load(path)
	
	if stream == null:
		push_error("Sound not found at: %s" % path)
		return
	
	player.stream = stream
	player.volume_db = volume_db
	player.play()

func set_sfx_volume(volume_db: float) -> void:
	_sfx_volume_db = volume_db

func get_sfx_volume() -> float:
	return _sfx_volume_db

func play_music(music_key: String, fade_in: float, fade_out: float = 0.0) -> void:
	var path := SOUND_PATH + music_key + ".wav"
	var stream := load(path)
	
	if stream == null:
		push_error("Music not found at %s" % path)
		return
	
	var was_playing := _music_player.playing
	
	if _music_tween and _music_tween.is_running():
		_music_tween.kill()
	
	if was_playing:
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", -80.0, fade_out)
		await _music_tween.finished
		_music_player.stop()
	
	_music_player.stream = stream
	_music_player.volume_db = -80.0
	_music_player.play()
	
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", _music_volume_db, fade_in)
	await _music_tween.finished

func set_music_volume(volume_db: float) -> void:
	_music_volume_db = volume_db

func get_music_volume() -> float:
	return _music_volume_db
