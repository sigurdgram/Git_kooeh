extends CharacterBody2D
class_name CharacterBase

@export var movementSpeed: float = 160.0

@export var navigationAgent: NavigationAgent2D
@export var sprite: Sprite2D
@export var collisionShape: CollisionShape2D
@export var foodPosition: Node2D
@export var _animTree: AnimationTree

var _buildableSystem: BuildableSystem
var _holdFoods: Dictionary
var _playback: AnimationNodeStateMachinePlayback
var forwardVector: Vector2
var _navigationPaused: bool = false
var path: PackedVector2Array
signal interactionContext(context: String)
signal navigation_finished()


func _ready():
    _playback = _animTree.get("parameters/playback")
    _buildableSystem = get_tree().get_first_node_in_group("BuildableSystem")
    navigationAgent.max_speed = movementSpeed
    pass

func _physics_process(_delta):
    if path.is_empty():
        return

    var nextPoint: Vector2 = path[0]
    var distance: float = global_position.distance_to(nextPoint)
    var dir: Vector2 = global_position.direction_to(nextPoint)

    if distance < 2:
        path.remove_at(0)

        if path.is_empty():
            velocity = Vector2.ZERO
            navigation_finished.emit()
            return

        nextPoint = path[0]
        distance = global_position.distance_to(nextPoint)
        dir = global_position.direction_to(nextPoint)

    velocity = dir
    global_position = global_position + dir * _delta * movementSpeed

    if velocity.x > 0:
        sprite.flip_h = true
    elif velocity.x < 0:
        sprite.flip_h = false

    if velocity.length() > 0.0:
        forwardVector = velocity.normalized()
    pass

func set_movement_target(pos: Vector2):
    var currentTile: Vector2 = Isometric2DNavigation.isoTileMap.local_to_map(global_position)
    var nextTile: Vector2 = Isometric2DNavigation.isoTileMap.local_to_map(pos)

    var currentTilPos: Vector2 = Isometric2DNavigation.isoTileMap.map_to_local(currentTile)
    var nextTilePos: Vector2 = Isometric2DNavigation.isoTileMap.map_to_local(nextTile)

    if currentTilPos != nextTilePos:
        navigationAgent.target_position = nextTilePos

func navigate_to(pos: Vector2, targetTolerance: float = 10.0, pathTolerance: float = 20.0):
    var t: Transform2D = _buildableSystem.global_transform.affine_inverse()
    path = _buildableSystem.pathfind(global_position, pos) * t
    pass

func stop_navigation() -> void :
    path.clear()
    pass

func _calculate_raw_velocity():
    if _navigationPaused:
        velocity = Vector2.ZERO
        return

    if navigationAgent.is_navigation_finished():
        velocity = Vector2.ZERO
        return

    var currentAgentPos: Vector2 = global_position
    var nextPathPos: Vector2 = navigationAgent.get_next_path_position()
    var newVelocity: Vector2 = (nextPathPos - currentAgentPos).normalized() * movementSpeed

    if navigationAgent.avoidance_enabled:
        navigationAgent.velocity = newVelocity
    else:
        velocity = newVelocity
    pass

func set_pause(pause: bool) -> void :
    if pause:
        velocity = Vector2.ZERO
        set_physics_process(false)
    else:
        set_physics_process(true)
    pass

func is_navigation_finished() -> bool:
    return path.is_empty()

func set_navigation_pause(state: bool):
    _navigationPaused = state
    pass

func _move(newVelocity: Vector2):
    if _navigationPaused:
        velocity = Vector2.ZERO
        return

    if navigationAgent.is_navigation_finished():
        velocity = Vector2(0, 0)
        return

    if newVelocity.x > 0:
        sprite.flip_h = true
    elif newVelocity.x < 0:
        sprite.flip_h = false

    velocity = newVelocity
    if velocity.length() > 0.0:
        forwardVector = velocity.normalized()
    move_and_slide()
    pass

func _update_animation():
    if velocity.is_zero_approx():
        foodPosition.z_index = 1

    if velocity.y < 0:
        foodPosition.z_index = 0
    elif velocity.y > 0:
        foodPosition.z_index = 1

    if velocity.x > 1:
        sprite.flip_h = true
    elif velocity.x < -1:
        sprite.flip_h = false

func get_collision_rect() -> Rect2:
    return collisionShape.shape.get_rect()

func is_holding_food() -> bool:
    return foodPosition.get_child_count() > 0

func hold_food(cookedFood: Dictionary) -> bool:
    if foodPosition.get_child_count() > 0:
        return false

    _holdFoods = cookedFood
    for i in cookedFood:
        var amount: int = cookedFood[i]
        for j in amount:
            var food: = Food.new(i)
            foodPosition.add_child(food)

    interactionContext.emit("HoldFood")
    return true

func release_food() -> Dictionary:
    if foodPosition.get_child_count() == 0:
        return {}

    var temp = _holdFoods.duplicate()
    _holdFoods.clear()

    for i in foodPosition.get_children():
        i.queue_free()

    interactionContext.emit("ReleaseFood")
    return temp
