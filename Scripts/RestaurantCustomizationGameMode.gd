extends Node2D
class_name RestaurantCustomizationGameMode

@export var _restaurantUpgradeBundle: UpgradeBundle
@export var _buildableSystem: BuildableSystem
@export var _camera: Camera2D
@export var _upgradeUI: PackedScene
@export var _selectedSprite: Sprite2D

var _upgradeUIInstance: UI_BuildableProcess_Upgrade
var _moveTween: Tween
var _selectedUpgradable: Buildable
signal onSelectedUpgradable(upgradable: Buildable)

func get_buildable_system() -> BuildableSystem:
    return _buildableSystem

func _ready():
    var layout: Dictionary = GameplayVariables.get_var(KooehConstant.restaurantLayoutVarName)
    if layout.is_empty():
        var upgradeData: UpgradeData = _restaurantUpgradeBundle.data[0]
        layout = upgradeData.data["Config"].data
    _buildableSystem.build(layout)

    GameplayVariables.add_money(3000)
    await get_tree().process_frame
    var orderCounter: Buildable_OrderCounter1 = get_tree().get_first_node_in_group("Buildable.OrderCounter")
    _camera.position = orderCounter.global_position






    pass

func set_selected_upgradable(buildable: Buildable) -> void :
    if _selectedUpgradable != buildable:
        _selectedUpgradable = buildable
        if _moveTween:
            _moveTween.kill()

        if not is_instance_valid(buildable):
            return

        _moveTween = create_tween()
        _moveTween.tween_property(_camera, "global_position", buildable.global_position, 0.3).set_ease(Tween.EASE_OUT)
        var sprite: Sprite2D = buildable.get_sprite()
        _selectedSprite.global_transform = sprite.global_transform
        _selectedSprite.offset = sprite.offset
        _selectedSprite.texture = sprite.texture
        onSelectedUpgradable.emit(buildable)
    else:
        var upgradable: = _selectedUpgradable.get_meta("Upgradable") as UpgradableComponent
        upgradable.upgrade()
        _upgradeUIInstance.refresh_requirements_check()
        _selectedSprite.texture = null
        onSelectedUpgradable.emit(null)
        pass
    pass
