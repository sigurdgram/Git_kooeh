extends CampaignEvent_OverrideCustomerSpawn

var _customerToSpawn: CustomerData = preload("res://Resources/Customer/CustomerData_S-1.tres")
var _kopiO: FoodData = preload("res://Resources/FoodData/FoodData_KopiO.tres")
var _dialogueSet: DialogueSet = preload("res://Resources/DialogueSet/DialogueSet_FirstEverS1Customer.tres")
var _pineappleTart: FoodData = preload("res://Resources/FoodData/FoodData_PineappleTart.tres")
var _isCustomerGet: bool = false



func is_event_executable() -> bool:
    var timeSystem: TimeSystem = GameInstance.gameWorld.timeSystem
    if timeSystem.get_day() != KooehConstant.Day.SATURDAY:
        return false

    var campaigns: Dictionary = GameplayVariables.get_var(KooehConstant.campaignVarName)

    return campaigns[identifier] == KooehConstant.CampaignStatus.INPROGRESS || KooehConstant.CampaignStatus.PENDING\
if campaigns.has(identifier) else true

func get_customer_to_spawn() -> CustomerData:
    if _isCustomerGet:
        return null

    _isCustomerGet = true
    var dup: CustomerData = _customerToSpawn.duplicate(false)
    dup.foodOrderRate = {_kopiO: 1}
    dup.patience = -1
    return dup

func _init():
    identifier = KooehConstant.FirstEverS1Customer
    GameInstance.onGameWorldSet.connect(_on_game_world_set)
    pass

func _on_game_world_set(node: Node):
    if not node is GameplayGameMode:
        return

    GameInstance.onGameWorldSet.disconnect(_on_game_world_set)
    var timeSystem: TimeSystem = node.timeSystem
    timeSystem.onStart.connect(_on_first_saturday)
    pass

func _on_first_saturday(_day: KooehConstant.Day, _unixTime: int):
    if is_event_executable():
        CampaignSystem.set_event_active(identifier)
    else:
        CampaignSystem.set_event_inactive(identifier)
    pass

func ready():
    super .ready()

    var gameMode = GameInstance.gameWorld
    var orderSystem: OrderSystem = gameMode.orderSystem
    orderSystem.broadcastOrderFulfilled.connect(_on_first_S1_customer_served, CONNECT_ONE_SHOT)
    pass

func _on_first_S1_customer_served(orderID: int, _order: OrderData):
    if orderID != 0:
        return

    DialogueSystem.onDialogueEnded.connect(_on_first_S1_served_dialogue_end)
    DialogueSystem.spawn_dialogue(_dialogueSet, "cust_convo_firstSaturday_pineappleRecipe")
    pass

func _on_first_S1_served_dialogue_end(dialogue: DialogueResource):
    if dialogue != _dialogueSet.dialogueResource:
        return

    GameplayVariables.add_unlocked_recipe(_pineappleTart.resource_name)
    UITree.reward_prompt(_pineappleTart, Callable())
    status = KooehConstant.CampaignStatus.SUCCESS
    CampaignSystem.set_event_inactive(identifier)
    pass
