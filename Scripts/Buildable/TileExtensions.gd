extends Resource
class_name TileExtensions

@export var direction: Direction
@export var length: int

enum Direction{
    Right = 1, 
    BotRight = 2, 
    Bot = 5, 
    BotLeft = 6, 
    Left = 9, 
    TopLeft = 10, 
    Top = 13, 
    TopRight = 14, 
}
