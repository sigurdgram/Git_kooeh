extends UI_Widget
class_name UI_BuildableProcess_Upgrade

@export var _buyFrame: PackedScene
@export var _BTNUpgradeRestaurant: Button
@export var _BTNPause: Button
@export var _tabContainer: TabContainer
@export var _templateTab: Node

var _gameMode: GameplayGameMode
var _buildableSystem: BuildableSystem
var _player: Node

signal refresh()

func _ready() -> void :
    _BTNPause.pressed.connect(_on_escape)
    pass

func DeactivateWidget() -> void :
    if is_instance_valid(_buildableSystem):
        _buildableSystem.onExitEdit.emit()

    if is_instance_valid(_player):
        _player.show()
    pass

func _unhandled_input(event: InputEvent) -> void :
    if event.is_action_pressed("act_pause"):
        _BTNPause.pressed.emit()
        accept_event()
    pass

func _on_escape() -> void :
    UITree.Prompt("Are you sure you want to exit? \n Any changes will be automatically saved.", 
    func():
        SaveLoadManager.save_game()
        UITree.PopWidgetFromLayer(self, get_owning_layer_name()), 
    func(): pass)
    pass

func setup(gameMode: GameplayGameMode) -> void :
    _gameMode = gameMode

    rebuild_ui()

    _BTNUpgradeRestaurant.owner = self
    _buildableSystem = _gameMode.get_buildable_system()
    _BTNUpgradeRestaurant.setup(_buildableSystem)

    _player = get_tree().get_first_node_in_group("Player")
    _player.hide()

    InputManager.set_game_input_enabled(true)
    _buildableSystem.onEnterEdit.emit()
    pass

func on_click_buy_frame(buildable: Buildable) -> void :
    _gameMode.set_selected_upgradable(buildable)
    pass

func refresh_requirements_check() -> void :
    refresh.emit()
    pass

func rebuild_ui() -> void :
    var keys: Array = BuildableData.Category.keys()
    var tabsDict: Dictionary

    for i in get_tree().get_nodes_in_group("Upgradable"):
        var assetType: int = i.get_buildable_data().get_ref().category
        var tabName: String = keys[assetType]
        var tab: Node
        if tabsDict.has(tabName):
            tab = tabsDict[tabName]
        else:
            tab = _templateTab.duplicate()
            tabsDict[tabName] = tab
            _tabContainer.add_child(tab)
            tab.name = tabName

        var buyFrame: Node = _buyFrame.instantiate()
        buyFrame.setup(_gameMode, i, on_click_buy_frame.bind(i))
        refresh.connect(buyFrame.evaluate_availability)
        tab.get_node("Box").add_child(buyFrame)
    pass
