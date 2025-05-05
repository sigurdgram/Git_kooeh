extends Node2D

var isoTileMap: Isometric2DTilemap

func resolve_ending_point(worldForm: Vector2, worldTo: Vector2) -> Vector2:
    var mapWorldTo = isoTileMap.local_to_map(worldTo)
    var angle: float = atan2(worldTo.y - worldForm.y, worldTo.x - worldForm.x)
    angle = rad_to_deg(angle)
    if angle < 0:
        angle += 360
    var angleStep: float = 360.0 / 8.0
    var index: int = int((angle + angleStep / 2) / angleStep) % 8

    var cellNeighborEnum
    match index:
        0:
            cellNeighborEnum = TileSet.CELL_NEIGHBOR_LEFT_CORNER
        1:
            cellNeighborEnum = TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE
        2:
            cellNeighborEnum = TileSet.CELL_NEIGHBOR_TOP_CORNER
        3:
            cellNeighborEnum = TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE
        4:
            cellNeighborEnum = TileSet.CELL_NEIGHBOR_RIGHT_CORNER
        5:
            cellNeighborEnum = TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE
        6:
            cellNeighborEnum = TileSet.CELL_NEIGHBOR_BOTTOM_CORNER
        7:
            cellNeighborEnum = TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE
        _:
            push_error("CellNeighbor invalid")

    mapWorldTo = isoTileMap.get_neighbor_cell(mapWorldTo, cellNeighborEnum)
    var newWorldTo = isoTileMap.map_to_local(mapWorldTo)
    return newWorldTo

func get_global_position_relative_to_tilemap(pos: Vector2) -> Vector2:
    var tileCoord: Vector2 = isoTileMap.local_to_map(pos)
    var relativeGlobalPosition: Vector2 = isoTileMap.map_to_local(tileCoord)
    return relativeGlobalPosition
