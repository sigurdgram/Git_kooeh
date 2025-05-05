extends CampaignEvent_OverrideCustomerSpawn

var _customerToSpawn: CustomerData = preload("res://Resources/Customer/CustomerData_T-1.tres")
var _firstVisitDialogueSet: DialogueSet = preload("res://Resources/DialogueSet/DialogueSet_FirstEverCustomerVisit.tres")
var _firstServedDialogueSet: DialogueSet = preload("res://Resources/DialogueSet/DialogueSet_FirstEverCustomerServed.tres")
var _balloon: UI_DialogueBalloon_NoSpeaker
var _dialogueNoSpeaker: PackedScene = preload("res://Scenes/UIs/Dialogue/UI_DialogueBalloon_NoSpeaker.tscn")
var _isCustomerGet: bool = false
var _firstCustomer: QueueNode



func is_event_executable() -> bool:
    var canExecute: int = 1

    canExecute &= int(CampaignSystem.get_event_status(KooehConstant.Prologue) > KooehConstant.CampaignStatus.INPROGRESS)
    canExecute &= int(CampaignSystem.get_event_status(identifier) <= KooehConstant.CampaignStatus.INPROGRESS)
    return canExecute

func _init():
    identifier = KooehConstant.FirstEverCustomerVisit
    GameInstance.onGameWorldSet.connect(_on_game_world_set)
    pass

func _on_game_world_set(node: Node):
    if not node is GameplayGameMode:
        return

    var gm: = node as GameplayGameMode

    gm.onDayStart.connect(
        func check_tutorial_mode():
            if not is_event_executable():
                return

            GameInstance.onGameWorldSet.disconnect(_on_game_world_set)
            CampaignSystem.set_event_active(identifier)
    )
    pass

func ready():
    super .ready()

    var orderCounter = GameInstance.get_tree().get_first_node_in_group("Buildable.OrderCounter")
    var queue: QueueSystem = orderCounter.queue
    queue.onEnterQueue.connect(_on_first_customer_enter_queue, CONNECT_ONE_SHOT)

    var orderSystem: OrderSystem = GameInstance.gameWorld.orderSystem
    orderSystem.broadcastOrderFulfilled.connect(_on_first_ever_customer_served, CONNECT_ONE_SHOT)

    var customerSpawner: CustomerSpawner = GameInstance.gameWorld.customerSpawner
    customerSpawner.onSpawnedCustomer.connect(_on_first_customer_spawned, CONNECT_ONE_SHOT)
    pass

func _on_first_customer_spawned(_customer: Customer):
    var customerSpawner: CustomerSpawner = GameInstance.gameWorld.customerSpawner
    customerSpawner.stop_spawning()
    pass

func get_customer_to_spawn() -> CustomerData:
    if _isCustomerGet:
        return null

    _isCustomerGet = true
    var dup: CustomerData = _customerToSpawn.duplicate(false)
    dup.foodOrderRate = {FoodLibrary.KuihLapis: 1}
    dup.patience = -1
    return dup

func _on_first_customer_enter_queue(node: QueueNode):
    _firstCustomer = node

    node.onStoppedInQueue_OneOff.connect(_play_dialogue_first_visit, CONNECT_ONE_SHOT)
    pass

func _play_dialogue_first_visit():
    var owningCustomer: Customer = _firstCustomer.get_data()
    owningCustomer._stateMachine.set_process(false)

    var orderCounter = owningCustomer.get_tree().get_first_node_in_group("Buildable.OrderCounter")
    var targetPosition: Vector2 = orderCounter.global_position
    var owningPosition: Vector2 = owningCustomer.global_position

    var dir: Vector2 = (targetPosition - owningPosition).normalized()
    owningCustomer.sprite.flip_h = dir.x > 0

    InputManager.set_game_input_enabled(false)
    DialogueSystem.spawn_dialogue(_firstVisitDialogueSet, "cust_convo_openingDay_firstCust")

    await DialogueSystem.onDialogueEnded
    owningCustomer._stateMachine.set_process(true)
    InputManager.set_game_input_enabled(true)


    var blackboard: Dictionary = owningCustomer.get_blackboard()
    blackboard[State_WaitForOrderFulfill.DineInChance] = 0.0

    _balloon = UITree.PushWidgetToLayer(_dialogueNoSpeaker, UITree.layerPrompt)
    _balloon.start(_firstVisitDialogueSet, "ServeInstructions")
    GameInstance.gameWorld.interactionSystem.add_limited_interactable_item(orderCounter)
    pass

func _on_first_ever_customer_served(_orderID: int, _order: OrderData):
    GameInstance.gameWorld.interactionSystem.clear_limited_interactable_items()
    UITree.PopWidgetFromLayer(_balloon, _balloon.get_owning_layer_name())

    var owningCustomer: Customer = _firstCustomer.get_data()
    owningCustomer.set_physics_process(false)
    InputManager.set_game_input_enabled(false)
    DialogueSystem.spawn_dialogue(_firstServedDialogueSet, "cust_convo_openingDay_firstCust_served")


    await DialogueSystem.onDialogueEnded
    owningCustomer.set_physics_process(true)
    InputManager.set_game_input_enabled(true)

    GameInstance.gameWorld.customerSpawner.start_spawning()
    status = KooehConstant.CampaignStatus.SUCCESS
    CampaignSystem.set_event_inactive(identifier)
    pass

func _on_first_served_dialogue_end(dialogue: DialogueResource):
    if dialogue != _firstServedDialogueSet.dialogueResource:
        return

    DialogueSystem.onDialogueEnded.disconnect(_on_first_served_dialogue_end)

    pass
