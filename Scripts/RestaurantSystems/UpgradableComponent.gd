extends Node
class_name UpgradableComponent

@export_flags_2d_physics var _upgradeFlag: int = 1 << 8

var _upgradeData: Dictionary

func _notification(what: int) -> void :
    match what:
        NOTIFICATION_PARENTED:
            get_parent().set_meta("Upgradable", self)
        NOTIFICATION_UNPARENTED:
            get_parent().remove_meta("Upgradable")
    pass

func _ready() -> void :
    owner = get_parent()

    if owner.get_is_preview():
        return

    assert (is_instance_of(owner, Buildable), "owner must be of class Buildable")
    assert (owner.has_method("upgrade"), "%s doesn't have method 'upgrade'" % owner)
    assert (owner.has_method("get_level"), "%s doesn't have method 'get_level'" % owner)
    assert (owner.has_method("on_enter_edit"), "%s doesn't have method 'on_enter_edit'" % owner)
    assert (owner.has_method("on_exit_edit"), "%s doesn't have method 'on_exit_edit'" % owner)

    owner.add_to_group("Upgradable")
    var bData: BuildableData = owner.get_buildable_data().get_ref()
    assert (bData.customData.has("Upgrade"), "%s's customData doesn't have 'Upgrade'" % bData.id)

    _upgradeData = bData.customData["Upgrade"]
    assert ( not _upgradeData.is_empty(), "%s's upgrade data is invalid")

    var buildableSystem: BuildableSystem = owner.get_buildable_system()
    buildableSystem.onEnterEdit.connect(owner.on_enter_edit)
    buildableSystem.onExitEdit.connect(owner.on_exit_edit)
    owner.collision_layer = owner.collision_layer | _upgradeFlag
    pass

func get_level() -> int:
    return owner.get_level()

func can_upgrade() -> BuildableTypes.EBuildableError:
    var ret: BuildableTypes.EBuildableError = BuildableTypes.EBuildableError.OK

    var level = get_level()
    ret |= BuildableTypes.EBuildableError.MaxLevel if level + 1 > _upgradeData.keys().back() else 0

    if not ret:
        var data: Dictionary = _upgradeData[level + 1]
        for i in data:
            match i:
                "Price":
                    ret |= BuildableTypes.EBuildableError.NoMoney if EconomySystem.get_currency() < data[i] else 0

    if owner.has_method("can_upgrade"):
        ret |= owner.can_upgrade()
    return ret

func get_upgrade_bundle() -> Dictionary:
    return _upgradeData

func upgrade() -> void :
    var level: int = get_level()
    var data: Dictionary = _upgradeData[level + 1]
    for i in data:
        match i:
            "Price": GameplayVariables.add_money( - data[i])
    owner.upgrade()
    pass
