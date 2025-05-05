extends Resource
class_name BuildableData

@export var name: String
@export var buildableScene: PackedScene
@export var texture: Texture
@export var category: Category
@export var price: int = 100
@export var layer: Layer
@export var customData: Dictionary
@export var tileSetID: int
@export var tileExtensions: Array[TileExtensions] = []
@export var flippedTileExtensions: Array[TileExtensions] = []
@export var restrictions: Array[BuildableRestrictions_Base] = []

var restrictList: Array[String] = []

enum Category{
    None = 0, 
    Table, 
    Chair, 
    WorkStation, 
    Stove, 
    DisplayCounter, 
    Cashier, 
    All, 
}

enum Layer{
    Floor = 0, 
    Tabletop = 2 ** 0, 
}

func check_restrictions() -> bool:
    var valid: bool = true
    restrictList.clear()

    if not restrictions.is_empty():
        for res in restrictions:
            if not res == null:
                if not res.check(self):
                    valid = false
                    restrictList.append(res.restrictionMessage)

    return valid

func get_restrictions_list() -> Array[String]:
    return restrictList

@export_category("New")
@export var id: String
@export var displayName: String
@export var layer2: BuildableTypes.EBuildableLayer = BuildableTypes.EBuildableLayer.Terrain

@export_category("Collision")
@export var collisionPriority: int = 0
@export_flags_2d_physics var collisionLayer: int

@export_category("Variants")
@export var defaultDirection: BuildableTypes.EDirection = BuildableTypes.EDirection.North
@export var directionalVariants: Dictionary = {
    BuildableTypes.EDirection.North: null, 
    BuildableTypes.EDirection.NorthEast: null, 
    BuildableTypes.EDirection.East: null, 
    BuildableTypes.EDirection.SouthEast: null, 
    BuildableTypes.EDirection.South: null, 
    BuildableTypes.EDirection.SouthWest: null, 
    BuildableTypes.EDirection.West: null, 
    BuildableTypes.EDirection.NorthWest: null
}

func get_valid_variants() -> Dictionary:
    var validVariants: Dictionary
    for i in directionalVariants:
        if not is_instance_of(directionalVariants[i], BuildableVariant):
            continue
        validVariants[i] = directionalVariants[i]

    return validVariants
