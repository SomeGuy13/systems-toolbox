# Systems Toolbox Dcumentation v1.0.0
Think of the systems toolbox as a collection of lego bricks you can then
use to quickly build a game by adding your own systems on top of the
ones provided. These systems can operate mostly on their own and are
designed to be modular and decoupled. This documentation covers the 
general  architecture of the systems as well as each individual system
and how to use the system.

## Architecture
Every system talks through the EventBus, which contains all the signals
the different systems emit and respond to. Systems can pass data to each
other through signals and use it accordingly.

However, in some cases systems or game components may have to request 
data directly from other systems, which is why each system provides a
public API where data or changes to data can be requested. This is to
keep the data in one place where only copies are sent out. Public methods
have no underscore infront, but private ones do.

All systems are autoloads such that they are accessible anywhere in the
project for game components to quickly access and interact with.

Some systems may depend on other systems (i.e. all systems need the 
EventBus to communicate or the Audio system needs the Settings system to
know if the volume has been adjusted by the player) in which case this
documentation as well as the system itself must note of the dependencies.
Systems will throw errors if they cannot find the system that they are
dependent on.

## Systems
Each system is listed in alphabetical order, with the current version of
that system. The Systems Toolbox version is incremented per revision or
addition to the systems. Each system also tracks its own versions.

### EventBus v1.0.0
Dependencies: None

The EventBus is the communication center for all systems. It contains
purely signals that systems can emit and connect to. Signals within the
EventBus begin with a name or word for the system that emits them the
most.

To emit an EventBus signal:
```
EventBus.{signal}.emit({Data: data})
```

Example:
```
EventBus.player_took_damage.emit(amount: 34)
EventBus.player_died.emit()
```

To listen to an EventBus signal:
```
EventBus.{signal}.connect(_response_callback_function)
```

Example:
```
func _ready():
	EventBus.item_collected.connect(_on_item_collected)

func _on_item_collected(item: Item):
	# Handle logic here
```

#### List of EventBus Signals
Organized alphabetically with a short description of what each signal
is for.

##### `game_state_changed(new_state: GameManager.GameState)`
Emits when the game state changes with the `new_state`.

##### `input_action_pressed(action: String)`
Emits when an action is pressed within the InputSystem. The parameter is
the action that was pressed.

##### `input_action_released(action: String)`
Emits when an action is released within the InputSystem. The parameter
is the action that was released.

##### `setting_changed(key: String, value)`
Emits when a setting is changed with the key and value of that setting.

### GameManager v1.0.0
Dependencies: SignalBus, InputSystem
Tracks the state of the game and freezes physics and input accordingly.

GameState enum: MENU, LOADING, PLAYING, PAUSED, GAME_OVER, CUTSCENE

#### Public Methods

##### `get_current_game_state()`
Returns the current state of the game.

##### `set_game_state(new_state: GameState)`
Sets the game state to a new state defined in the GameState enum.
Some states will disable or enable physics and input.

**GameState.CUTSCENE**: Disables input, but not physics
**GameState.PAUSED**: Disables input and physics
**GameState.PLAYING**: Enables input and physics

### AudioSystem v1.0.0
Dependencies: EventBus (SettingsSystem when added)

#### Public Methods

##### `get_music_volume()`
Returns the current decible volume the music is set at.

##### `get_sfx_volume()`
Returns the current decible volume the sfx are set at.

##### `play_sound(sound_key: String, volume_db: float = _sfx_volume_db)`
Plays a sound specified by the `sound_key` in the file path at 
`"res://assets/sounds/" + sound_key + ".wav"` at the specified volume,
otherwise it defaults to the internal _sfx_volume_db which can be
changed through SettingsSystem (when implemented). Alos updates audio
settings automatically when the setting is changed in the SettingsSystem.

Example:
```
AudioSystem.play_sound("sfx_hit_1") # Plays at default volume

AudioSystem.play_sound("sfx_hit_2", -7.0) # Plays at -7.0db
```

If the sound file cannot be found, an error is thrown and the sound 
is not played.

Example:
```
AudioSystem.play_sound("sfx_belly_brumble") # Does not exist
# Pushes error
```

##### `play_music(music_key: String, fade_in: float, fade_out: float = 0.0)`
Plays music loaded from the path at 
`"res://assets/sounds/" + sound_key + ".wav"` and if the file does not
exist, an error is pushed and the music is not played. When music starts
to play, it is faded in over the seconds specified by `fade_in`. When
new music is played over old music, it is faded out over `fade_out` and
then faded in through `fade_in` again.

Example:
```
AudioSystem.play_music("sound_track_01", 3.0)

# Later on mid track

AudioSystem.play_music("sound_track_02", 3.0, 1.0)
```

##### `set_music_volume(volume_db: float)`
Sets the music volume to `volume_db`.

##### `set_sfx_volume(volume_db: float)`
Sets the default sfx volume to `volume_db`.

#### Private Methods

##### `_get_available_sfx_player()`
Returns an available sfx player that can be used. Returns the first player
if all players in the pool are used.

##### `_populate_sfx_pool(players: int)`
Populates the internal `_sfx_pool` with a specified amount of
AudioStreamPlayers that the AudioSystem can use.

### InputSystem v1.0.0
Dependencies: EventBus
The InputSystem serves as a wraper around Godot's InputMap to allow for
system control of input. It also uses signals through the EventBus to
communicate with other systems and game components.

NOTE: Actions must be added to the internal InputSystem before they can
be used.

#### Public Methods

##### `add_action(action: String)`
Adds an action to the internal list of actions within the input system
so they can be used for signals in the EventBus.

Example:
```
# Add an action to the InputSystem
InputSystem.add_action("jump")
```

##### `get_enabled_state()`
Returns the state of the input system and whether it is enabled and emitting
signals in the EventBus or if it is disabled and not emitting signals.

Example:
```
# Get the state of the InputSystem
InputSystem.get_enabled_state() # Returns either true or false
```

##### `set_enabled_state(enabled: bool)`
Sets the state of the input system with the parameter. Does not emit a
signal.

Example:
```
set_enabled_state(false) # Input is now disabled
```

#### Private Methods

##### `_input(event: InputEvent)`
Emits signals in the EventBus when the InputSystem is enabled.

### SettingsSystem v1.0.0

#### Public Methods

##### `get_setting(key: String, default = null)`
Returns the value of the setting found by the key, if there is no
key found than the default setting is used. If the default setting
cannot be found than the default is used.

##### `load_settings_from_file(path: String)`
Loads the settings from the file specified at `path` into the internal
`_settings` which can be accessed by `get_setting(key: String, default)`.
Rreturns true if successful, otherwise returns false.

##### `save_settings_to_file(path: String)`
Saves settings to file specified at `path` from internal `_settings`
which can be changed through `set_setting(key: String, value)`. Returns
true if successful, otherwise returns false,

##### `set_setting(key: String, value)`
Sets a setting within the internal `_settings`. If setting does not
exist, it will create a new setting within the dictionary.
