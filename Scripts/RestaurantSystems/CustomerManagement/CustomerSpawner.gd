extends Node
class_name CustomerSpawner

const SPAWN_INTERVAL: String = "Kooeh/ProjectSettings/CustomerSpawner/SpawnInterval"

@export var maxCustomerCount: int = 3
@export var customerSpawnLocation: Node2D
@export var _layer: Node2D
var _customerCount: int = 0
var _spawnLimits: Vector2
var _spawnLocation: Vector2
var _spawnModifier: Array[float]
var _isStopped: bool = true
var _loadedCustomers: Array[WeakRef]
var _spawnTimerCounter: float = 0.0

signal onSpawnedCustomer(customer: Customer)
signal onCustomerDestroyed()


func _init():
    _spawnLimits = ProjectSettings.get_setting(SPAWN_INTERVAL)
    _loadedCustomers = AssetManager.load_assets_of_type("CustomerData")
    pass

func _ready():
    var tree: SceneTree = get_tree()
    await tree.process_frame
    var entrance: Node = tree.get_first_node_in_group("Buildable.Entrance")
    _spawnLocation = entrance.global_position

    var buildableSystem: BuildableSystem = tree.get_first_node_in_group("BuildableSystem")
    var upgradeBundle: UpgradeBundle = buildableSystem.get_upgrade_bundle()
    for i in upgradeBundle.data:
        _spawnModifier.push_back(i.data["CustomerSpawnModifier"])
    pass

func start_spawning():
    _isStopped = false
    var randomTime: float = _random_spawn_timings()
    _spawnTimerCounter = randomTime
    pass

func _process(delta: float):
    if _customerCount >= maxCustomerCount || _isStopped:
        return

    _spawnTimerCounter -= delta
    if _spawnTimerCounter <= 0.0:
        random_customer()
        var randomTime: float = _random_spawn_timings()
        _spawnTimerCounter = randomTime
    pass

func get_customer_count() -> int:
    return _customerCount

func _spawn_customer(customerData: CustomerData):
    _customerCount += 1
    var customer: Customer = customerData.scene.instantiate() as Customer

    _layer.add_child(customer)
    customer.global_position = _spawnLocation
    customer.setup(_on_destroy_customer, customerData)

    onSpawnedCustomer.emit(customer)
    GameplayVariables.add_visited_customer(customerData.identifier, 1)

    if _customerCount >= maxCustomerCount:
        set_process(true)
    pass

func _on_destroy_customer():
    _customerCount -= 1
    onCustomerDestroyed.emit()
    pass

func stop_spawning():
    _isStopped = true

func _generateSpawnTable() -> Dictionary:
    var spawnTable: Dictionary


    for i in _loadedCustomers:
        var data: CustomerData = i.get_ref() as CustomerData
        if not is_instance_valid(data):
            continue

        if not data.is_spawn_trigger_valid():
            continue


    for i in _loadedCustomers:
        var data: CustomerData = i.get_ref() as CustomerData
        if not is_instance_valid(data):
            continue
        if not data.is_spawn_trigger_valid():
            continue

        var a = data.foodOrderRate.keys()
        var hasViableOrder: bool = a.any(
            func has_viable_orders(x): return FoodLibrary.is_food_learned(x))

        if hasViableOrder:
            spawnTable[data] = data.weight

    return spawnTable

func random_customer():
    if CampaignSystem.is_campaign_enabled():
        var override = CampaignSystem.campaign_customer_spawn_override()
        if is_instance_valid(override):
            _spawn_customer(override)
            return

    var spawnTable: = _generateSpawnTable()
    var rng: = RandomNumberGenerator.new()
    var index: int = rng.rand_weighted(spawnTable.values())
    var ret: CustomerData = spawnTable.keys()[index]
    _spawn_customer(ret)
    return

func _random_spawn_timings() -> float:
    var rng: = RandomNumberGenerator.new()
    var restaurantLevel: int = GameplayVariables.get_var(KooehConstant.restaurantLevelVarName)
    var modifiedSpawnLimits: Vector2 = _spawnLimits * _spawnModifier[restaurantLevel]
    return rng.randf_range(modifiedSpawnLimits.x, modifiedSpawnLimits.y)
