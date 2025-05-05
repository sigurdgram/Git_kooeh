extends UI_Widget
class_name UI_Phase2_EndDayReport

@export var _tree: Tree
@export var _finalTree: Tree
@export var _continueBtn: Button

@export var _fontSize1: int = 20
@export var _fontSize2: int = 25

func _ready() -> void :
    _continueBtn.pressed.connect(func(): UITree.PopWidgetFromLayer(self, get_owning_layer_name()))
    _continueBtn.grab_focus()
    pass

func setup(performance: Dictionary) -> void :
    var titles: PackedStringArray = ["Item", "Amount", "Price"]
    var index: int = 0
    for i in titles:
        _tree.set_column_title(index, i)
        index += 1

    _populate_served_food_section(performance["ServedFoods"])
    _tree.create_item()

    var cookedFood: Dictionary = performance[KooehConstant.cookedFoodVarName]
    for i in cookedFood:
        if performance["ServedFoods"].has(i):
            var amount: int = performance["ServedFoods"][i]
            cookedFood[i] -= amount

    _populate_wasted_food_section(cookedFood)
    _tree.create_item()
    _populate_customer_section(performance[KooehConstant.visitedCustomerVarName], performance[KooehConstant.servedCustomerVarName])

    var result: TreeItem = _finalTree.create_item()
    result.set_text(0, "Total Earnings")
    result.set_text(2, var_to_str(performance[KooehConstant.moneyVarName]))
    result.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
    pass

func _populate_wasted_food_section(data: Dictionary) -> void :
    var cookedFoodRow: TreeItem = _tree.create_item()
    cookedFoodRow.set_text(0, "Wasted")
    cookedFoodRow.set_custom_font_size(0, _fontSize2)

    var totalWastedFood: int = 0
    var totalWastedProfit: float = 0
    for i in data:
        var amount: int = data[i]
        if amount == 0:
            continue

        var foodData = AssetManager.load_asset(i).get_ref() as FoodData
        var row: TreeItem = _tree.create_item()
        row.set_text(0, foodData.name)
        row.set_text(1, "x %s" % amount)
        row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)

        var price: float = foodData.price * amount
        totalWastedProfit -= price
        totalWastedFood += amount
        row.set_text(2, var_to_str( - price))
        row.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)

    var expense: TreeItem = _tree.create_item()
    expense.set_text(1, var_to_str(totalWastedFood))
    expense.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
    expense.set_custom_font_size(1, _fontSize1)

    expense.set_text(2, var_to_str(totalWastedProfit))
    expense.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
    expense.set_custom_font_size(2, _fontSize1)
    pass

func _populate_served_food_section(data: Dictionary):
    var servedFoodRow: TreeItem = _tree.create_item()
    servedFoodRow.set_text(0, "Sold")
    servedFoodRow.set_custom_font_size(0, _fontSize2)

    var totalProfit: float = 0
    var totalItem: int = 0

    for i in data:
        var amount: int = data[i]
        var foodData = AssetManager.load_asset(i).get_ref() as FoodData
        var row: TreeItem = _tree.create_item()
        row.set_text(0, foodData.name)
        row.set_text(1, "x %s" % amount)
        row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)

        var price: float = foodData.price * amount
        totalItem += amount
        totalProfit += price
        row.set_text(2, var_to_str(price))
        row.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)

    var earnings: TreeItem = _tree.create_item()
    earnings.set_text(1, var_to_str(totalItem))
    earnings.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
    earnings.set_custom_font_size(1, _fontSize1)

    earnings.set_text(2, var_to_str(totalProfit))
    earnings.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
    earnings.set_custom_font_size(2, _fontSize1)
    pass

func _populate_customer_section(visitors: Dictionary, served: Dictionary):
    var customerRow: TreeItem = _tree.create_item()
    customerRow.set_text(0, "Customer")
    customerRow.set_custom_font_size(0, _fontSize2)

    var visited: int = visitors.values().reduce(
        func(accum: int, number: int): return accum + number, 0)

    var visitedRow: TreeItem = _tree.create_item()
    visitedRow.set_text(0, "Visited")
    visitedRow.set_text(1, var_to_str(visited))
    visitedRow.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)

    var servedNum: int = served.values().reduce(
        func(accum: int, number: int): return accum + number, 0)

    var servedRow: TreeItem = _tree.create_item()
    servedRow.set_text(0, "Served")
    servedRow.set_text(1, var_to_str(servedNum))
    servedRow.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)

    var lost: TreeItem = _tree.create_item()
    lost.set_text(0, "Lost")
    lost.set_custom_font_size(0, _fontSize1)

    lost.set_text(1, var_to_str(visited - servedNum))
    lost.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
    lost.set_custom_font_size(1, _fontSize1)
    pass
