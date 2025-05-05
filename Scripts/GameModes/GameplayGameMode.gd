extends Node
class_name GameplayGameMode

@export var _restaurantUpgradeBundle: UpgradeBundle
@export var customerSpawner: CustomerSpawner
@export var orderSystem: OrderSystem
@export var cookSystem: CookSystem
@export var serveSystem: ServeSystem
@export var timeSystem: TimeSystem
@export var phase3CookSystem: Phase3CookSystem
@export var interactionSystem: InteractionSystem
@export var _audioPhase2: AudioStream
@export var _buildableSystem: BuildableSystem
@export var _selectedSprite: Sprite2D

@export_group("Points of Interest")
@export var orderCounter: StaticBody2D
@export var queue: QueueSystem
@export var leaveArea: Area2D

@export_group("PackedScene")
@export var _gamePlayUI: PackedScene
@export var _essentialsUI: PackedScene
@export var _countdownUI: PackedScene
@export var _phase3SelectorUI: PackedScene
@export var _phase3CookbookUI: PackedScene
@export var _playerScene: PackedScene
@export var _customizationUI: PackedScene
@export var _endDayUI: PackedScene

var tutorial: WeakRef = weakref(null)
var _essentialsUIInstance: UI_Widget
var _upgradeUIInstance: UI_BuildableProcess_Upgrade
var _gameplayUIInstance: UI_GamePlay
var _moveTween: Tween
var _selectedUpgradable: Buildable
var _todayPerformance: Dictionary = {
    KooehConstant.moneyVarName: 0, 
    KooehConstant.cookedFoodVarName: {}, 
    KooehConstant.servedCustomerVarName: {}, 
    KooehConstant.visitedCustomerVarName: {}, 
    "ServedFoods": {}
}

signal onSelectedUpgradable(upgradable: Buildable)
signal onDayStart
signal onDayEnd


func get_buildable_system() -> BuildableSystem:
    return _buildableSystem

func _ready():
    GameInstance.gameWorld = self
    GameplayVariables.onEconomyUpdate.connect(
        func(_money: float, delta: float):
            _todayPerformance[KooehConstant.moneyVarName] += delta
    )

    GameplayVariables.onServedCustomerChanged.connect(
        func(identifier: String, _amount: int, delta: int):
            var amount: int = _todayPerformance[KooehConstant.servedCustomerVarName].get_or_add(identifier, 0)
            _todayPerformance[KooehConstant.servedCustomerVarName][identifier] = amount + delta
    )

    GameplayVariables.onVisitedCustomerChanged.connect(
        func(identifier: String, _amount: int, delta: int):
            var amount: int = _todayPerformance[KooehConstant.visitedCustomerVarName].get_or_add(identifier, 0)
            _todayPerformance[KooehConstant.visitedCustomerVarName][identifier] = amount + delta
    )

    GameplayVariables.onCookedFoodAdded.connect(
        func(identifier: String):
            var amount: int = _todayPerformance[KooehConstant.cookedFoodVarName].get_or_add(identifier, 0)
            _todayPerformance[KooehConstant.cookedFoodVarName][identifier] = amount + 1
    )

    orderSystem.broadcastOrderFulfilled.connect(
        func(_orderID: int, orderData: OrderData):
            var servedFoods: Dictionary = _todayPerformance["ServedFoods"]
            for i in orderData.order:
                var amount: int = servedFoods.get_or_add(i, 0)
                servedFoods[i] = amount + orderData.order[i]
    )
    _essentialsUIInstance = UITree.PushWidgetToLayer(_essentialsUI, UITree.layerPermanent1)

    onDayStart.connect(_on_day_start)
    onDayEnd.connect(_on_day_end)
    timeSystem.onEnd.connect(_on_time_end)

    var layout: Dictionary = GameplayVariables.get_var(KooehConstant.restaurantLayoutVarName)
    if layout.is_empty():
        var upgradeData: UpgradeData = _restaurantUpgradeBundle.data[0]
        layout = upgradeData.data["Config"].data
    _buildableSystem.build(layout)

    await get_tree().process_frame
    var player: Node2D = _playerScene.instantiate()
    _buildableSystem.get_buildable_layer(BuildableTypes.EBuildableLayer.Asset).add_child(player)
    player.global_position = _buildableSystem.get_meta(BuildableTypes.Meta_SpawnPoint)
    get_viewport().get_camera_2d().global_position = player.global_position

    call_deferred("deferred_start")
    pass

func _get_performance_metrics() -> Dictionary:
    return {
        KooehConstant.moneyVarName: GameplayVariables.get_var(KooehConstant.moneyVarName), 
        KooehConstant.visitedCustomerVarName: GameplayVariables.get_var(KooehConstant.visitedCustomerVarName), 
        KooehConstant.servedCustomerVarName: GameplayVariables.get_var(KooehConstant.servedCustomerVarName), 
        KooehConstant.cookedFoodVarName: GameplayVariables.get_var(KooehConstant.cookedFoodVarName)
    }

func _exit_tree():
    if is_instance_valid(_essentialsUIInstance):
        UITree.PopWidgetFromLayer(_essentialsUIInstance, _essentialsUIInstance.get_owning_layer_name())
    pass

func deferred_start():
    if GameInstance.modulate == Color.BLACK:
        await UITree.fade_to_clear()

    if not is_instance_valid(tutorial.get_ref()):
        AudioSystem.play_music(_audioPhase2, AudioSystem.AudioPlayMode.SOLO)
        onDayStart.emit()
    pass

func _on_day_start():
    var countdown: = UITree.PushWidgetToLayer(_countdownUI, UITree.layerPrompt) as UI_Countdown
    countdown.setup(["Buka!"], true)
    InputManager.set_game_input_enabled(false)
    await countdown.onEnd
    InputManager.set_game_input_enabled(true)
    UITree.PopWidgetFromLayer(countdown, UITree.layerPrompt)

    _gameplayUIInstance = UITree.PushWidgetToLayer(_gamePlayUI, UITree.layerGame)
    timeSystem.start()
    customerSpawner.start_spawning()
    pass

func _on_day_end():
    if not is_instance_valid(_countdownUI):
        return
    var countdown: = UITree.PushWidgetToLayer(_countdownUI, UITree.layerPrompt) as UI_Countdown
    countdown.setup(["Tutup!"], true)
    await countdown.onEnd

    UITree.PopWidgetFromLayer(countdown, UITree.layerPrompt)
    UITree.PopWidgetFromLayer(_essentialsUIInstance, _essentialsUIInstance.get_owning_layer_name())
    UITree.PopWidgetFromLayer(_gameplayUIInstance, _gameplayUIInstance.get_owning_layer_name())
    push_day_end_ui()
    pass

func push_day_end_ui():
    var endDayUI: UI_Phase2_EndDayReport = UITree.PushWidgetToLayer(_endDayUI, UITree.layerGame)
    endDayUI.setup(_todayPerformance)
    await endDayUI.onDeactivated

    var selector: UI_Phase2_Phase3Selector = UITree.PushWidgetToLayer(_phase3SelectorUI, UITree.layerGame)
    selector.setup(self)
    pass

func _on_time_end():
    customerSpawner.stop_spawning()
    if customerSpawner.get_customer_count() == 0:
        onDayEnd.emit()
    else:
        customerSpawner.onCustomerDestroyed.connect(_overtime_end)
    pass

func _overtime_end():
    if customerSpawner.get_customer_count() > 0:
        return

    customerSpawner.onCustomerDestroyed.disconnect(_overtime_end)
    onDayEnd.emit()
    pass

func start_phase3():
    UITree.PushWidgetToLayer(_phase3CookbookUI, UITree.layerGameUI)
    pass

func on_click_customization() -> void :
    _upgradeUIInstance = UITree.PushWidgetToLayer(_customizationUI, UITree.layerGame)
    _upgradeUIInstance.setup(self)
    pass

func set_selected_upgradable(buildable: Buildable) -> void :
    if _selectedUpgradable != buildable:
        _selectedUpgradable = buildable
        if _moveTween:
            _moveTween.kill()

        if not is_instance_valid(buildable):
            return

        var camera: Camera2D = buildable.get_viewport().get_camera_2d()
        _moveTween = create_tween()
        _moveTween.tween_property(camera, "global_position", buildable.global_position, 0.3).set_ease(Tween.EASE_OUT)
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
        _selectedUpgradable = null
        onSelectedUpgradable.emit(null)
        pass
    pass
