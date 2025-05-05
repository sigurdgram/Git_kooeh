extends Buildable_Base
class_name Buildable_OrderCounter

@export var queue: QueueSystem

var _assetsTileMap: TileMap
var _orderSystem: OrderSystem



func _ready():
    super ._ready()
    call_deferred("_setup")
    pass

func _setup():
    _orderSystem = GameInstance.gameWorld.orderSystem
    _assetsTileMap = get_tree().get_first_node_in_group("TileMapAssets")

    await get_tree().create_timer(0.01, false).timeout

    _setupQueue()
    pass

func _setupQueue():
    if scale == Vector2(-1, 1):
        tileExtensions = load("res://Resources/Buildable/BuildableData_Asset_OrderCounter.tres").flippedTileExtensions
    else:
        tileExtensions = load("res://Resources/Buildable/BuildableData_Asset_OrderCounter.tres").tileExtensions

    var occupiedTiles: Array[Vector2i] = []
    if not tileExtensions.is_empty():
        var tilePos = _assetsTileMap.local_to_map(self.global_position)
        for tile in tileExtensions:
            for n in range(tile.length):
                var dir: int = tile.direction
                var extraTilePos: Vector2i = _assetsTileMap.get_neighbor_cell(tilePos, dir)
                occupiedTiles.append(extraTilePos)
                tilePos = extraTilePos

    queue.global_position = _assetsTileMap.map_to_local(occupiedTiles[-1])
    var closestPoint = to_local(_assetsTileMap.map_to_local(occupiedTiles[0])) - queue.position

    if queue.curve.point_count <= 0:
        queue.curve.add_point(Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, 0)
        queue.curve.add_point(closestPoint, Vector2.ZERO, Vector2.ZERO, 1)
        queue.curve.set_point_out(0, closestPoint)
        queue.curve.set_point_in(1, Vector2.ZERO)

    await get_tree().process_frame


func interact(_interactor: Node2D):
    _orderSystem = GameInstance.gameWorld.orderSystem
    if not _orderSystem._orderList.is_empty():
        var customerList = tree.get_nodes_in_group("Customer") as Array[Customer]

        for customer in customerList:
            if queue.node_index_in_queue(customer.get_parent()) == 0:
                if not customer._orderBTN.disabled:
                    customer.fulfill_order()
                return
    pass

func highlight():
    _orderSystem = GameInstance.gameWorld.orderSystem
    if not _orderSystem._orderList.is_empty():
        super .highlight()
    pass
