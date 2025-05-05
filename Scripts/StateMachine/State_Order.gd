extends State
class_name State_Order

var _order: Dictionary
var _owningCustomer: Customer


func enter():
    _owningCustomer = _owner as Customer


    var shouldWaitingForCampaignEnded: bool = false
    if CampaignSystem.is_campaign_enabled():
        var visitedCustomers: Dictionary = GameplayVariables.get_var(KooehConstant.visitedCustomerVarName)
        if visitedCustomers.is_empty():
            shouldWaitingForCampaignEnded = CampaignSystem.set_event_active(KooehConstant.FirstEverCustomerVisit)

    if shouldWaitingForCampaignEnded:
        var event: CampaignEvent = CampaignSystem.get_event(KooehConstant.FirstEverCustomerVisit)
        await event.onEventEnded


    _generate_order()
    pass

func _generate_order():
    var customerData: CustomerData = _owningCustomer.get_customer_data()
    var possibleOrders: Dictionary = customerData.foodOrderRate
    var learnedRecipes: PackedStringArray = GameplayVariables.get_learned_recipes()

    var possibleLearnedRecipes: Array = possibleOrders.keys().filter(
        func learned_recipes(x):
            return learnedRecipes.has(x))

    var key: String = possibleLearnedRecipes.pick_random()
    _order = {key: possibleOrders[key]}

    _blackboard["OrderID"] = _owningCustomer.request_order(_order)
    _runner.move_to(self, "State_WaitForOrderFulfill")
    pass
