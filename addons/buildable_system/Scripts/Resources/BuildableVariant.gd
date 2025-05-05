extends Resource
class_name BuildableVariant

@export var buildable: PackedScene
@export var buildReqs: Array[BuildableRequirement]
@export var variantData: Dictionary

@export_group("Navigation")
@export var blockedNav: PackedVector2Array
