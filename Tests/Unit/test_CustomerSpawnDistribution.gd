extends GutTest

var _loadedCustomerResources: Array[WeakRef]

func before_each():
    _loadedCustomerResources = AssetManager.load_assets_of_type("CustomerData")
    pass

func _random_customer() -> CustomerData:
    var spawnTable: Dictionary = _generateSpawnTable()
    var rng: = RandomNumberGenerator.new()
    var index: int = rng.rand_weighted(spawnTable.values())
    var ret: CustomerData = spawnTable.keys()[index]
    return ret

func _generateSpawnTable() -> Dictionary:
    var spawnTable: Dictionary


    for i in _loadedCustomerResources:
        var data: CustomerData = i.get_ref() as CustomerData
        if not is_instance_valid(data):
            continue

        if not data.is_spawn_trigger_valid():
            continue


    for i in _loadedCustomerResources:
        var data: CustomerData = i.get_ref() as CustomerData
        if not is_instance_valid(data):
            continue
        if not data.is_spawn_trigger_valid():
            continue

        spawnTable[data] = data.weight

    return spawnTable

func test_generateSpawnTable():
    var spawnTable: Dictionary = _generateSpawnTable()
    for i in spawnTable:
        gut.p("Customer: %s, weight: %s" % [i, spawnTable[i]])
    pass

func test_spawn_customer():
    var currentDay: String = ""
    match GameplayVariables.get_var(KooehConstant.dayVarName):
        KooehConstant.Day.MONDAY: currentDay = "Monday"
        KooehConstant.Day.TUESDAY: currentDay = "Tuesday"
        KooehConstant.Day.WEDNESDAY: currentDay = "Wednesday"
        KooehConstant.Day.THURSDAY: currentDay = "Thursday"
        KooehConstant.Day.FRIDAY: currentDay = "Friday"
        KooehConstant.Day.SATURDAY: currentDay = "Saturday"
        KooehConstant.Day.SUNDAY: currentDay = "Sunday"

    gut.p("Day: %s" % currentDay)

    for k in 100:
        gut.p("Tries: %s" % k)
        var s: Dictionary

        for i in 100:
            var n: String = _random_customer().name
            var amount: int = s.get_or_add(n, 0)
            s[n] = amount + 1

        gut.p(JSON.stringify(s, "	"))
    pass
