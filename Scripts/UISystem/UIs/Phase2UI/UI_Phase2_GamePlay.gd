extends UI_Widget
class_name UI_GamePlay

@export var _btnBuild: Button
@export var _btnInventory: Button

@export var _buildMenuUI: PackedScene
@export var _inventoryMenuUI: PackedScene



func _ready():
    _btnBuild.pressed.connect(_on_pressed_build)
    _btnInventory.pressed.connect(_on_pressed_inventory)
    pass

func _input(_event):
    pass






func _on_pressed_build():
    openBuildingMenu()

func _on_pressed_inventory():
    openInventoryMenu()

func openBuildingMenu():
    push_layer(_buildMenuUI)

func openInventoryMenu():
    push_layer(_inventoryMenuUI)

func push_layer(packedScene: PackedScene):
    hide()
    UITree.PushWidgetToLayer(packedScene, UITree.layerGameUI)

func on_back():
    show()
