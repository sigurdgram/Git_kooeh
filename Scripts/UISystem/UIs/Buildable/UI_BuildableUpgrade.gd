extends Control
class_name UI_BuildableUpgrade

@export var _upgradeIndicator: TextureRect
@export var _upgradeStateTexture: Array[Texture2D]

var _camera2D: Camera2D
var _spaceState: PhysicsDirectSpaceState2D
var _upgradableBuildable: Node2D:
    set(value):
        if _upgradableBuildable == value:
            return

        _upgradableBuildable = value

        var state: int = 0 if value != null else 1
        _upgradeIndicator.texture = _upgradeStateTexture[state]
        pass



func _ready():
    _camera2D = GameInstance.gameViewport.get_camera_2d()
    _spaceState = GameInstance.gameViewport.get_world_2d().direct_space_state
    pass

func _process(_delta):
    _hide_indicator_when_mouse_out_of_bound()
    var mousePos: Vector2 = _camera2D.get_global_mouse_position()
    position = mousePos

    if not UI_BuildMenu.is_mouse_in_playing_field():
        return

    _raycast()
    pass

func _hide_indicator_when_mouse_out_of_bound():
    if _upgradeIndicator.is_visible_in_tree() != UI_BuildMenu.is_mouse_in_playing_field():
        _upgradeIndicator.visible = UI_BuildMenu.is_mouse_in_playing_field()
    pass

func _input(event: InputEvent):
    if event.is_action_pressed("lmb")\
&& _upgradableBuildable != null\
&& _upgradableBuildable.is_upgradable():

        var pos: Vector2 = _upgradableBuildable.position
        var upgradeResource: Resource = _upgradableBuildable.resources.upgradeResource
        _upgradableBuildable.queue_free()
        var newObj = upgradeResource.tscn.instantiate()
        GameInstance.gameWorld.tileMap.add_child(newObj)
        newObj.setup(upgradeResource)
        newObj.build(pos)
        await get_tree().create_timer(0.1, false).timeout
        GameInstance.gameWorld.navigationRegion2D.refresh_navigation_mesh()
        accept_event()
    pass

func _raycast():
    var query: = PhysicsPointQueryParameters2D.new()
    query.position = get_global_mouse_position()
    var results: Array[Dictionary] = _spaceState.intersect_point(query, 1)
    if results.is_empty():
        _upgradableBuildable = null
    else:
        var entry: Node2D = results[0].collider
        _upgradableBuildable = entry if entry.is_in_group("furniture") else null
    pass
