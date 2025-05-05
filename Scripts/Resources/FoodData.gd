extends Resource
class_name FoodData

@export var name: String
@export var type: KooehConstant.FoodType
@export var difficulty: KooehConstant.Difficulty
@export_multiline var description: String
@export var sprite: Texture2D
@export var journalSprite: Texture2D
@export var platelessSprite: Texture2D
@export var eatingSprites: Array[Texture2D]
@export var cookTime: float
@export var price: float
@export var batchCookAmount: int = 1
@export var ingredients: Dictionary
@export var cookInstructions: Array[CookInstruction]
