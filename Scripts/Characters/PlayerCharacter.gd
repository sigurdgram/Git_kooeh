extends PlayerBase
class_name PlayerCharacter

@export var spacing: float = 42.0
@export var texture: Texture


@export var interactRayCastsContainer: Node2D
var rayCastObject: StaticBody2D
var prevRayCastObject: StaticBody2D
var rayCastDirection: Vector2
@export var rayCastLength: float

static  var player: PlayerCharacter
var _currentInteractable: InteractableComponent:
    set(v):
        if _currentInteractable == v:
            return

        if is_instance_valid(_currentInteractable):
            _currentInteractable.unhighlight()

        if is_instance_valid(v) and v.can_interact(self):
            v.highlight()
            _currentInteractable = v
        else:
            _currentInteractable = null
        pass

var _interactionToggle: bool = true:
    set(value):
        if not value and is_instance_valid(interactedObject):
            interactedObject.uninteract()

        set_process(value)
        _interactionToggle = value
        pass

var isManualMovement: bool = true
var interactedObject: Node:
    set(value):
        if is_instance_valid(interactedObject):
            interactedObject.uninteract()

        interactedObject = value
        if is_instance_valid(interactedObject):
            interactedObject.interact()
        pass

signal onInteractBuildable()



func _ready():
    player = self
    _on_game_input_enabled()
    pass

func _on_game_input_enabled():
    set_process(InputManager.get_game_input_enabled())
    set_physics_process(InputManager.get_game_input_enabled())
    InputManager.on_input_activation_changed.connect(set_process)
    InputManager.on_input_activation_changed.connect(set_physics_process)
    InputManager.on_input_activation_changed.connect(_stop_movement)

func set_interaction_toggle(state: bool):
    _interactionToggle = state
    pass

func _process(_delta):
    var interactable: InteractableComponent = null

    for rayCast in interactRayCastsContainer.get_children():

        rayCast.target_position = Vector2(1, 0) * rayCastLength
        interactRayCastsContainer.rotation = rayCastDirection.angle()

        if not rayCastObject == null:
            prevRayCastObject.uninteract(self)

        if rayCast.is_colliding() and not rayCastDirection == Vector2.ZERO:
            var colObj: CollisionObject2D = rayCast.get_collider()
            if colObj.has_meta("Interactable"):
                interactable = colObj.get_meta("Interactable", null)













            break


    _currentInteractable = interactable
    pass

func _physics_process(_delta):
    if isManualMovement:
        _manual_movement(_delta)
    else:
        velocity = Vector2.ZERO
    _update_animation()
    pass

func _input(event: InputEvent):
    if _is_manual_movement(event):
        isManualMovement = true

    if event.is_action_pressed("act_interact") and _currentInteractable:
        _currentInteractable.interact(self)
        _currentInteractable = null
        onInteractBuildable.emit()
    pass

func _is_manual_movement(_event: InputEvent) -> bool:
    return _event.is_action_pressed("act_down")\
or _event.is_action_pressed("act_left")\
or _event.is_action_pressed("act_right")\
or _event.is_action_pressed("act_up")

func _manual_movement(_delta):
    navigate_to(position)
    var direction = Vector2()
    if InputManager.get_input_type() == KooehConstant.InputType.KEYBOARD_MOUSE:
        direction.y = Input.get_action_strength("act_down") - Input.get_action_strength("act_up")
        direction.x = Input.get_action_strength("act_right") - Input.get_action_strength("act_left")
    else:
        var y: float = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
        var x: float = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
        var deadzone: float = InputManager.get_gamepad_deadzone()
        direction.y = 0.0 if abs(y) < deadzone else y
        direction.x = 0.0 if abs(x) < deadzone else x

    direction = direction.normalized()
    var motion = direction * movementSpeed * _delta
    velocity = motion
    if velocity.length() > 0.0:
        forwardVector = velocity.normalized()

    var clampX = movementSpeed * _delta * 0.5
    var clampY = movementSpeed * _delta * 0.5
    var collision = move_and_collide(velocity, false, 1, true)
    if collision:
        velocity = velocity.slide(collision.get_normal())
        velocity = Vector2(clampf(velocity.x, - clampX, clampX), clampf(velocity.y, - clampY, clampY))
        move_and_collide(velocity, false, 1, true)

    if direction != Vector2.ZERO:
        rayCastDirection = direction
    pass

func _stop_movement(_movementEnabled: bool):
    if not _movementEnabled:
        velocity = Vector2.ZERO

        for rayCast in interactRayCastsContainer.get_children():
            rayCast.target_position = Vector2.ZERO
        _update_animation()

func release_food() -> Dictionary:
    if foodPosition.get_child_count() == 0:
        return {}

    var temp = _holdFoods.duplicate()
    _holdFoods.clear()

    for i in foodPosition.get_children():
        i.queue_free()

    interactionContext.emit("ReleaseFood")
    return temp
