extends StaticBody2D
class_name Buildable_Base

@export var _sprite: Sprite2D

var _mat: ShaderMaterial
@export var _canInteract: bool = true:
    set = _set_canInteract
@export var _areaNavigation: Area2D
var tileExtensions: Array[TileExtensions] = []
var startScale: Vector2

var tree: SceneTree
var interactionSystem: InteractionSystem


func _ready():
    assert (input_pickable, self.name + ": Buildable must be pickable")
    assert (_sprite.material.resource_local_to_scene, self.name + ": Material must be local to scene.")
    _mat = _sprite.material

    tree = get_tree()
    interactionSystem = tree.get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
    pass

func get_sprite() -> Sprite2D:
    return _sprite

func _set_canInteract(value: Variant):
    _canInteract = value
    pass

func can_interact(_interactor: Node2D) -> bool:
    if not interactionSystem.is_limited_interaction() or interactionSystem.limited_interactables_contains(self):
        _canInteract = true
    else:
        _canInteract = false

    return _canInteract

func highlight():
    if not interactionSystem.is_limited_interaction() or interactionSystem.limited_interactables_contains(self):
        _mat.set_shader_parameter("enabled", true)
    pass

func interact(_interactor: Node2D):
    uninteract(_interactor)
    pass

func uninteract(_interactor: Node2D):
    _mat.set_shader_parameter("enabled", false)
    pass

func grab_focus():
    pass

func get_navigation_target_tolerance() -> float:
    return _areaNavigation.shape.get_rect().size.x
