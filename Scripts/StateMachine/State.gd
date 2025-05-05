extends Node
class_name State

var _owner: Node
var _runner: StateMachineRunner
var _blackboard: Dictionary


func setup(inOwner: Node, inRunner: StateMachineRunner, blackboard: Dictionary):
    _owner = inOwner
    _runner = inRunner
    _blackboard = blackboard
    pass

func enter():
    pass

func exit():
    pass

func update(_delta: float):
    pass

func physics_update(_delta: float):
    pass
