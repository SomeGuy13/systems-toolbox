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
EventBus.player_took_damage(amount: 34)
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

##### `input_action_pressed("action")`
Emits when an action is pressed within the InputSystem. The parameter is
the action that was pressed.

##### `input_action_released("action")`
Emits when an action is released within the InputSystem. The parameter
is the action that was released.

### InputSystem v1.0.0
Dependencies: EventBus
The InputSystem serves as a wraper around Godot's InputMap to allow for
system control of input. It also uses signals through the EventBus to
communicate with other systems and game components.

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
