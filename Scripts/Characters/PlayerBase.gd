extends CharacterBody2D
class_name PlayerBase

@export var movementSpeed: float = 160.0

@export var navigationAgent: NavigationAgent2D
@export var sprite: Sprite2D
@export var collisionShape: CollisionShape2D
@export var foodPosition: Node2D
@export var _animTree: AnimationTree

var _holdFoods: Dictionary
var _playback: AnimationNodeStateMachinePlayback
var forwardVector: Vector2
var _navigationPaused: bool = false

signal interactionContext(context: String)


func _ready():
    _playback = _animTree.get("parameters/playback")
    navigationAgent.velocity_computed.connect(_move)
    navigationAgent.max_speed = movementSpeed
    pass

func _physics_process(_delta):
    _calculate_raw_velocity()
    _update_animation()

func set_movement_target(pos: Vector2):
    var currentTile: Vector2 = Isometric2DNavigation.isoTileMap.local_to_map(global_position)
    var nextTile: Vector2 = Isometric2DNavigation.isoTileMap.local_to_map(pos)

    var currentTilPos: Vector2 = Isometric2DNavigation.isoTileMap.map_to_local(currentTile)
    var nextTilePos: Vector2 = Isometric2DNavigation.isoTileMap.map_to_local(nextTile)

    if currentTilPos != nextTilePos:
        navigationAgent.target_position = nextTilePos

func navigate_to(pos: Vector2, targetTolerance: float = 10.0, pathTolerance: float = 20.0):
    navigationAgent.path_desired_distance = pathTolerance
    navigationAgent.target_desired_distance = targetTolerance
    navigationAgent.target_position = pos
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

    if velocity.x > 0:
        sprite.flip_h = true
    elif velocity.x < 0:
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
