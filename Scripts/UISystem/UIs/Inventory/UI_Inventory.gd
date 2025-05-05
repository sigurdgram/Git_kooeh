extends UI_Widget
class_name UI_Inventory

@export var slot: PackedScene
@export var itemGird: GridContainer

var inventoryData: Dictionary
var clickItem: IngredientData



func _ready():
    inventoryData = InventorySystem.get_ingredient_inventory()
    populate_item_grid(inventoryData)

func _input(event):
    if event.is_action_pressed("inventory"):
        back()
        accept_event()

func populate_item_grid(newinventoryData: Dictionary) -> void :
    for child in itemGird.get_children():
        child.queue_free()

    for itemData in newinventoryData:
        var slotNode = slot.instantiate()
        itemGird.add_child(slotNode)

        slotNode.connect("slotClicked", on_slot_clicked)

        if itemData:
            slotNode.set_slot_data(itemData, newinventoryData[itemData])

func on_slot_clicked(ingredientData: IngredientData, button: int):
    match button:
        MOUSE_BUTTON_LEFT:
            clickItem = ingredientData

    print(clickItem)

func back():
    queue_free()

func _on_back_button_pressed():
    back()
