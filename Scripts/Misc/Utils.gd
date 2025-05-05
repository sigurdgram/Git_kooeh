class_name Utils

enum QTEProcessMode
{
    ONESHOT, 
    PINGPONG
}

const INT_MAX = 9223372036854775807
const REMAP = ".remap"

static func is_flag_enabled(bitmask, flag) -> Variant:
    return bitmask & flag != 0

static func set_flag(bitmask, flag) -> Variant:
    bitmask = bitmask | flag
    return bitmask

static func unset_flag(bitmask, flag) -> Variant:
    bitmask = bitmask & ~ flag
    return bitmask

static func toggle_flag(bitmask, flag) -> Variant:
    bitmask = bitmask ^ flag
    return bitmask

static func get_default_master_volume() -> float:
    return ProjectSettings.get_setting("Kooeh/DefaultSettings/Audio/MasterVolume", 0.75)

static func get_default_music_volume() -> float:
    return ProjectSettings.get_setting("Kooeh/DefaultSettings/Audio/MusicVolume", 0.75)

static func get_default_sfx_volume() -> float:
    return ProjectSettings.get_setting("Kooeh/DefaultSettings/Audio/SFXVolume", 0.75)

static func get_supported_resolutions() -> Array:
    return ProjectSettings.get_setting("Kooeh/DefaultSettings/Video/SupportedResolutions")

static func get_supported_window_modes() -> Dictionary:
    return ProjectSettings.get_setting("Kooeh/DefaultSettings/Video/SupportedWindowModes")

static func get_fallback_language() -> String:
    return ProjectSettings.get_setting("internationalization/locale/fallback")

static func is_testing_locale() -> bool:
    var locale: String = ProjectSettings.get_setting("internationalization/locale/test")
    return not locale.is_empty()

static func get_default_input_bindings():
    var inputBindings: Array[Array] = []
    for action in InputMap.get_actions():
        if action.begins_with("ui_"):
            continue

        var events: Array[InputEvent] = InputMap.action_get_events(action)
        var event: String = var_to_str(events[0]) if events.size() > 0 else ""
        inputBindings.push_back([action, event])
    return inputBindings

static func get_default_camera_speed() -> float:
    return ProjectSettings.get_setting("Kooeh/DefaultSettings/General/CameraSpeed")

static func get_invert_zoom() -> bool:
    return GameInstance.settingsManager.invertZoom

static func get_ingredients_folder_path() -> String:
    return ProjectSettings.get_setting("Kooeh/ProjectSettings/IngredientsFolderPath")

static func get_buildables_folder_path() -> String:
    return ProjectSettings.get_setting("Kooeh/ProjectSettings/BuildablesFolderPath")

static func get_dialogue_set_folder_path() -> String:
    return ProjectSettings.get_setting("Kooeh/ProjectSettings/DialogueSetFolderPath")

static func get_customer_data_folder_path() -> String:
    return ProjectSettings.get_setting("Kooeh/ProjectSettings/CustomerSpawner/CustomerDataFolderPath")

static func get_all_child_path_in_folder(folderPath: String, exceptions: Array = []) -> Array[String]:
    var filePaths: Array[String] = []
    var dir: DirAccess = DirAccess.open(folderPath)
    dir.list_dir_begin()
    var file: String = dir.get_next()
    while not file.is_empty():
        if file.ends_with(REMAP):
            file = file.trim_suffix(REMAP)

        if not exceptions.has(file):
            filePaths.push_back(folderPath + file)

        file = dir.get_next()

    return filePaths

static func load_resources_in_folder(folderPath: String, exceptions: Array = []) -> Array[Resource]:
    var filePaths: Array[String] = get_all_child_path_in_folder(folderPath, exceptions)
    var resources: Array[Resource] = []
    for filePath in filePaths:
        var resource: Resource = load(filePath)
        resources.push_back(resource)

    return resources

static func get_all_children(node: Node) -> Array[Node]:
    var retVal: Array[Node] = []
    for child in node.get_children():
        retVal.push_back(child)
        if child.get_child_count() > 0:
            retVal.append_array(get_all_children(child))
    return retVal

static func get_rarity_color(rarity: KooehConstant.Rarity) -> Color:
    var colorString: String = ""
    match rarity:
        KooehConstant.Rarity.Common: colorString = "Kooeh/ProjectSettings/Rarity/Common"
        KooehConstant.Rarity.Uncommon: colorString = "Kooeh/ProjectSettings/Rarity/Uncommon"
        KooehConstant.Rarity.Rare: colorString = "Kooeh/ProjectSettings/Rarity/Rare"

    return ProjectSettings.get_setting(colorString)

static func get_rarity_texture(rarity: KooehConstant.Rarity) -> Texture:
    var texture_path: String = ""
    match rarity:
        KooehConstant.Rarity.Common: texture_path = "Kooeh/ProjectSettings/Rarity/CommonTexture"
        KooehConstant.Rarity.Uncommon: texture_path = "Kooeh/ProjectSettings/Rarity/UncommonTexture"
        KooehConstant.Rarity.Rare: texture_path = "Kooeh/ProjectSettings/Rarity/RareTexture"

    var texture_path_string = ProjectSettings.get_setting(texture_path) as String
    return load(texture_path_string) if texture_path_string else null

class InputStatics:
    static func get_input_event_text_safe(event: InputEvent) -> String:
        return event.as_text() if event != null else ""

class PhysicsCast:
    static func circle_cast(world: PhysicsDirectSpaceState2D, transform: Transform2D, radius: float, 
        excludes: Array[RID] = [], maxResults: int = 32) -> Array[Dictionary]:
        var circle_rid: RID = PhysicsServer2D.circle_shape_create()
        var query: = PhysicsShapeQueryParameters2D.new()
        PhysicsServer2D.shape_set_data(circle_rid, radius)
        query.shape_rid = circle_rid
        query.exclude = excludes
        query.transform = transform


        var results = world.intersect_shape(query, maxResults)
        PhysicsServer2D.free_rid(circle_rid)
        return results

    static func point_cast(world: PhysicsDirectSpaceState2D, point: Vector2, maxResults: int = 32, 
        mask: int = 4294967295, excludes: Array[RID] = []) -> Array[Dictionary]:
        var query: = PhysicsPointQueryParameters2D.new()
        query.exclude = excludes
        query.position = point
        query.collision_mask = mask

        var results = world.intersect_point(query, maxResults)
        return results
