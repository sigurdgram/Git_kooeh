extends StaticBody2D
class_name UI_BuildableControl

@export var resources: Resource
@export var _sprite2D: Sprite2D
@export var _areaNavigation: Area2D



func build(pos: Vector2):
    _sprite2D.set_modulate(Color(1, 1, 1, 1))
    _areaNavigation.set_monitoring(false)
    position = pos

func setup(newResources: Resource):
    resources = newResources
    _areaNavigation.set_monitoring(true)
    _sprite2D.set_modulate(Color(1, 1, 1, 0.5))

func is_upgradable() -> bool:
    return resources != null && resources.upgradeResource != null
