extends Node
class_name StateMachineRunner

@export var _rootState: State
@export var _owner: Node
@export var _autoStart: bool = false

var _currentState: State
var _states: Dictionary = {}
var _blackboard: Dictionary = {}

signal transition(from: State, to: State)



func _ready():
    var allChildren: Array[Node] = Utils.get_all_children(self)
    for i in allChildren:
        var state: State = i as State

        if is_instance_valid(state):
            state.setup(_owner, self, _blackboard)
            _states[state.name.to_lower()] = state

    if _autoStart:
        start()
    pass

func is_running() -> bool:
    return _currentState != null

func _process(delta: float):
    if _currentState:
        _currentState.update(delta)

func _physics_process(delta: float):
    if _currentState:
        _currentState.physics_update(delta)

func start(startState: State = null):
    if _currentState:
        assert (startState != _currentState)

    if startState:
        _rootState = startState

    _currentState = _rootState
    _rootState.enter()
    pass

func stop():
    _currentState.exit()
    _currentState = null

func move_to(from: State, to: String):
    assert (to != from.name)

    var toState: State = _states[to.to_lower()]
    if !toState:
        return

    transition.emit(_currentState, toState)

    if _currentState:
        _currentState.exit()

    _currentState = toState
    toState.enter()
    pass

func get_blackboard() -> Dictionary:
    return _blackboard
