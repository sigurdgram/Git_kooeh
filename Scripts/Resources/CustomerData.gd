extends Resource
class_name CustomerData

enum Rarity{
    COMMON, 
    UNCOMMON, 
    RARE, 
    SPECIAL, 
    ALL
}

@export var identifier: String
@export var name: String
@export var scene: PackedScene
@export var customerRarity: Rarity
@export var weight: float = 1.0
@export var foodOrderRate: Dictionary
@export var patience: float = 30.0
@export var spawnTrigger: Array[Condition_Base]
@export var paymentBonus: Array[ConditionalRandomizer]
@export var customerSize: float = 150.0

func is_spawn_trigger_valid() -> bool:
    var retVal: int = true

    for trigger in spawnTrigger:
        retVal &= trigger.query(GameplayVariables.get_all_vars())

    return retVal
