extends Node

signal onRecipeLearned(learnedFoodId: String)
signal onRecipeUnlocked(unlockedFood: String)

static  var _variables: Dictionary

signal onVisitedCustomerChanged(identifier: String, amount: int, delta: int)
signal onServedCustomerChanged(identifier: String, amount: int, delta: int)
signal onCampaignStatusChanged(identifier: String, status: KooehConstant.CampaignStatus)
signal onEconomyUpdate(money: float, delta: float)
signal onCookedFoodAdded(identifier: String)



static func _static_init():
    _variables = KooehConstant.get_default_gameplay_variables()
    pass

func reset():
    _variables = KooehConstant.get_default_gameplay_variables()
    pass

func _init():
    _on_game_load()
    SaveLoadManager.onGameLoad.connect(_on_game_load)
    SaveLoadManager.collectSaveData.connect(_collect_save_data)
    pass

func _on_game_load():
    var save: SaveGame = SaveLoadManager.get_current_save().get_ref()
    _variables.merge(save.gameplayVariables, true)
    pass

func _collect_save_data(save: SaveGame):
    save.gameplayVariables = _variables
    pass

func get_all_vars():
    return _variables

func get_var(varName: String):
    return _variables[varName]

func set_var(varName: String, value) -> bool:
    var currentVal = _variables[varName]

    if currentVal == value:
        return false

    _variables[varName] = value
    return true

func add_served_customer(customerID: String):
    var temp: Dictionary = _variables[KooehConstant.servedCustomerVarName]
    var amount: int = temp.get_or_add(customerID, 0) + 1
    temp[customerID] = amount

    if Engine.has_singleton(OnlineSubsystem.OnlineSubsystem):
        var oss: OnlineSubsystem = Engine.get_singleton(OnlineSubsystem.OnlineSubsystem)
        oss.set_stat_int(KooehConstant.STAT_CUSTOMER_SERVED, amount)

    onServedCustomerChanged.emit(customerID, amount, 1)
    pass

func add_visited_customer(identifier: String, amount: int) -> void :
    var temp: Dictionary = _variables[KooehConstant.visitedCustomerVarName]
    var newAmount: int = temp.get_or_add(identifier, 0) + amount
    temp[identifier] = newAmount

    onVisitedCustomerChanged.emit(identifier, newAmount, amount)
    pass

func set_campaign_status(identifier: String, status: KooehConstant.CampaignStatus):
    var s = KooehConstant.campaignVarName
    var temp = _variables[s]
    temp[identifier] = status
    onCampaignStatusChanged.emit(identifier, status)
    pass

func get_campaign_status(identifier: String) -> KooehConstant.CampaignStatus:
    var s = KooehConstant.campaignVarName
    var temp = _variables[s]
    if temp.has(identifier):
        return temp[identifier]
    else:
        return KooehConstant.CampaignStatus.PENDING

func get_learned_recipes() -> PackedStringArray:
    var ret: PackedStringArray = PackedStringArray()
    for i in _variables[KooehConstant.learnedRecipeVarName]:
        ret.push_back(i)
    return ret

func get_learned_date(assetId: String) -> String:
    var temp = _variables[KooehConstant.learnedRecipeVarName]
    var error = "The assetId not found"
    if temp.has(assetId):
        var dic = temp[assetId]
        var unixTime = dic[KooehConstant.learnedDateVarName]
        var dateStr = str(unixTime)
        return dateStr
    else:
        return error

func get_learned_rate(assetId: String) -> String:
    var temp = _variables[KooehConstant.learnedRecipeVarName]
    var error = "The assetId not found"
    if temp.has(assetId):
        var dic = temp[assetId]
        var rating = dic[KooehConstant.learnedRatingVarName]
        var rateStr = str(rating)
        return rateStr
    else:
        return error

func get_unlocked_recipes() -> PackedStringArray:
    return _variables[KooehConstant.unlockedRecipeVarName]

func add_learned_recipe(assetId: String, unixTime: String, rating: int):
    var temp: Dictionary = _variables[KooehConstant.learnedRecipeVarName]
    var dic: Dictionary = {
        KooehConstant.learnedDateVarName: unixTime, 
        KooehConstant.learnedRatingVarName: rating
    }

    var newEntry: bool = not temp.has(assetId)
    temp[assetId] = dic

    if newEntry:
        if Engine.has_singleton(OnlineSubsystem.OnlineSubsystem):
            var oss: OnlineSubsystem = Engine.get_singleton(OnlineSubsystem.OnlineSubsystem)
            var star3Food: int = temp.values().reduce(func(accum: int, d: Dictionary): return accum + 1 if d[KooehConstant.learnedRatingVarName] == 3 else accum, 0)
            oss.set_stat_int(KooehConstant.STAT_FOOD_3_STAR, star3Food)

        onRecipeLearned.emit(assetId)
    SaveLoadManager.save_game()
    pass

func add_unlocked_recipe(assetId: String):
    var temp = _variables[KooehConstant.unlockedRecipeVarName]
    if temp.has(assetId):
        return

    temp.append(assetId)

    if Engine.has_singleton(OnlineSubsystem.OnlineSubsystem):
        var oss: OnlineSubsystem = Engine.get_singleton(OnlineSubsystem.OnlineSubsystem)
        oss.set_stat_int(KooehConstant.STAT_RECIPE_UNLOCKED, temp.size())

    onRecipeUnlocked.emit(assetId)
    SaveLoadManager.save_game()
    pass

func add_money(delta: float) -> void :
    var temp: float = _variables[KooehConstant.moneyVarName] + delta
    _variables[KooehConstant.moneyVarName] = temp
    onEconomyUpdate.emit(temp, delta)
    pass

func add_wish() -> void :
    var temp: int = _variables[KooehConstant.wishVarName] + 1
    _variables[KooehConstant.wishVarName] = temp

    if Engine.has_singleton(OnlineSubsystem.OnlineSubsystem):
        var oss: OnlineSubsystem = Engine.get_singleton(OnlineSubsystem.OnlineSubsystem)
        oss.set_stat_int(KooehConstant.STAT_WISHES, temp)
    pass

func add_cooked_food(identifier: String) -> void :
    var cookedFood: Dictionary = _variables[KooehConstant.cookedFoodVarName]
    var num: int = cookedFood.get_or_add(identifier, 0)
    cookedFood[identifier] = num + 1

    if Engine.has_singleton(OnlineSubsystem.OnlineSubsystem):
        var oss: OnlineSubsystem = Engine.get_singleton(OnlineSubsystem.OnlineSubsystem)
        var values: Array = cookedFood.values()
        var foodTypeCookedOnce: int = values.reduce(func(accum: int, n: int): return accum + 1 if n > 0 else accum, 0)
        oss.set_stat_int(KooehConstant.STAT_FOOD_TYPE_COOKED, foodTypeCookedOnce)

        var totalFoodCooked: int = values.reduce(func(accum: int, n: int): return accum + n, 0)
        oss.set_stat_int(KooehConstant.STAT_FOOD_COOKED, totalFoodCooked)

    onCookedFoodAdded.emit(identifier)
    pass

func set_restaurant_level(level: int) -> void :
    _variables[KooehConstant.restaurantLevelVarName] = level

    if Engine.has_singleton(OnlineSubsystem.OnlineSubsystem):
        var oss: OnlineSubsystem = Engine.get_singleton(OnlineSubsystem.OnlineSubsystem)
        oss.set_stat_int(KooehConstant.STAT_RESTAURANT_LEVEL, level)
    pass
