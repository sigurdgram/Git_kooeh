extends Node
class_name InteractableComponent

@export var _parentArea: Area2D
@export var _sprite: Sprite2D
@export_flags_2d_physics var interactFlag: int = 1 << 7

var _mat: ShaderMaterial
var _interactionSystem: InteractionSystem

signal onHighlighted()
signal onUnhightlighted()
signal onInteract(interactor: Node2D)
signal onUninteract(interactor: Node2D)

func _notification(what: int) -> void :
    match what:
        NOTIFICATION_PARENTED:
            get_parent().set_meta("Interactable", self)
        NOTIFICATION_UNPARENTED:
            get_parent().remove_meta("Interactable")
    pass

func _ready() -> void :
    owner = get_parent()

    assert (_parentArea.input_pickable, self.name + ": Buildable must be pickable")
    assert (_sprite.material, "%s must be Shad_Outline")
    assert (_sprite.material.resource_local_to_scene, self.name + ": Material must be local to scene.")
    _mat = _sprite.material

    _interactionSystem = get_tree().get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
    pass

func get_sprite() -> Sprite2D:
    return _sprite

func can_interact(interactor: Node2D) -> bool:
    return owner.can_interact(interactor)

func highlight() -> void :
    _mat.set_shader_parameter("enabled", true)
    onHighlighted.emit()
    pass

func unhighlight() -> void :
    _mat.set_shader_parameter("enabled", false)
    onUnhightlighted.emit()
    pass

func interact(interactor: Node2D):
    onInteract.emit(interactor)
    pass

func uninteract(interactor: Node2D):
    onUninteract.emit(interactor)
    unhighlight()
    pass

func grab_focus():
    pass
