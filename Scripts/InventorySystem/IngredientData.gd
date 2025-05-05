extends Resource
class_name IngredientData

@export var name: String
@export_multiline var description: String
@export var rarity: KooehConstant.Rarity
@export var stackable: bool
@export var texture: Texture
@export var bundlePrice: int
@export var bundlePurchaseAmount: int = 10
