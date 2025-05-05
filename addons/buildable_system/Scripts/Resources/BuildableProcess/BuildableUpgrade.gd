extends BuildableProcess
class_name BuildableUpgrade

@export_flags_2d_physics var _upgradableLayer: int
@export var _disableCost: bool

var _cacheMask: int
var _selectedBuildable: UpgradableComponent

func get_process_name() -> String:
    return "Upgrade"

func enter() -> void :
    print("enter Upgrade")
    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    _cacheMask = cursorInstance.collision_mask
    cursorInstance.collision_mask = _upgradableLayer
    pass

func input(event: InputEvent) -> void :
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
            _select_item_to_upgrade()

    if event is InputEventKey:
        if event.keycode == KEY_U and event.is_pressed() and is_instance_valid(_selectedBuildable):
            upgrade(_selectedBuildable, _disableCost)
        if event.keycode == KEY_BACKSLASH and event.is_pressed():
            upgrade_restaurant(_buildableSystem)
    pass

func _select_item_to_upgrade() -> void :
    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    cursorInstance.force_shapecast_update()

    var arr = cursorInstance.collision_result
    if not arr.is_empty():
        arr.sort_custom(func(i, j): return i["collider"].priority > j["collider"].priority)
        var n: Node = arr[0].collider
        if n.has_meta("Upgradable"):
            _selectedBuildable = n.get_meta("Upgradable")
    pass

static func upgrade(upgradable: UpgradableComponent, disableCost: bool = false) -> void :
    if disableCost:
        if upgradable.can_upgrade() == BuildableTypes.EBuildableError.OK | BuildableTypes.EBuildableError.NoMoney:
            upgradable.upgrade()
        return

    if upgradable.can_upgrade() == BuildableTypes.EBuildableError.OK:
        upgradable.upgrade()

    await upgradable.get_tree().process_frame

    var error: = BuildableTypes.EBuildableError.OK
    var uArr: Array = upgradable.get_tree().get_nodes_in_group("Upgradable")
    for i in uArr:
        var u: UpgradableComponent = i.get_meta("Upgradable")
        error |= u.can_upgrade()

    var restaurantLevel: int = GameplayVariables.get_var(KooehConstant.restaurantLevelVarName)
    if restaurantLevel >= 2 and error == BuildableTypes.EBuildableError.MaxLevel:
        print("Fully upgraded")
        if Engine.has_singleton(OnlineSubsystem.OnlineSubsystem):
            var oss: OnlineSubsystem = Engine.get_singleton(OnlineSubsystem.OnlineSubsystem)
            oss.set_achievement(KooehConstant.ACH_SHOP_UPGRADE_ALL)
        return
    pass

static func upgrade_restaurant(system: BuildableSystem) -> void :
    var nextLevel: int = GameplayVariables.get_var(KooehConstant.restaurantLevelVarName) + 1
    var upgradeData: Array[UpgradeData] = system.upgradeBundle.data

    if nextLevel >= upgradeData.size():
        return

    GameplayVariables.set_restaurant_level(nextLevel)
    var json: JSON = upgradeData[nextLevel].data["Config"]
    var copyJson: Dictionary = json.data.duplicate()
    var currentConfig: Dictionary = system.generate_save_config_dict()

    var reconciledLayer: Array = _reconcile_layer(json.data.Layers.Asset, currentConfig.Layers.Asset)
    copyJson.Layers.Asset = reconciledLayer
    system.build(copyJson)
    pass

static func _reconcile_layer(from: Array, to: Array) -> Array:
    var reconciledDict: Dictionary
    for i in from:
        var key: String = "%s%s %s" % [i.id, i.mapPos, i.direction]
        reconciledDict[key] = i

    for i in to:
        var key: String = "%s%s %s" % [i.id, i.mapPos, i.direction]
        if reconciledDict[key].hash() != i.hash():
            reconciledDict[key] = i

    return reconciledDict.values()

func exit() -> void :
    print("exit Upgrade")
    var cursorInstance: BuildableCursor = _buildableSystem.get_cursor()
    cursorInstance.collision_mask = _cacheMask
    pass
