@static_unload

extends Object
class_name AssetManager

const assetConfigPath: String = "res://AssetConfig.cfg"
static  var _loadedAssets: Dictionary
static  var _database: AssetConfig


static func _static_init():
    _database = AssetConfig.new()
    var error: Error = _database.load(assetConfigPath)
    if error:
        print(error)
    pass

static func unload_all_assets():
    _loadedAssets.clear()
    pass

func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        AssetManager.unload_all_assets()
    pass

static func load_asset(assetId: StringName) -> WeakRef:
    if (_loadedAssets.has(assetId)):
        return weakref(get_loaded_asset(assetId))

    var path = get_asset_path(assetId)
    var loaded = ResourceLoader.load(path)

    if !_loadedAssets.has(loaded):
        _loadedAssets[assetId] = loaded

    return weakref(loaded)

static func load_assets_of_type(assetType: StringName, excludes: PackedStringArray = []) -> Array[WeakRef]:
    var assets: PackedStringArray = get_asset_ids_of_type(assetType, excludes)

    var ret: Array[WeakRef] = []
    for i in assets:
        var loaded: WeakRef = load_asset(i)

        ret.append(loaded)

    return ret

static func load_asset_of_ids(assetIds: Array) -> Array[WeakRef]:
    var ret: Array[WeakRef] = []
    for i in assetIds:
        ret.append(load_asset(i))

    return ret

static func unload_asset(assetId: StringName):
    _loadedAssets[assetId] = null
    _loadedAssets.erase(assetId)
    pass

static func unload_assets(assetIds: PackedStringArray):
    for i in assetIds:
        _loadedAssets[i] = null
        _loadedAssets.erase(i)
    pass

static func unload_assets_of_type(assetType: String, excludes: PackedStringArray = []):
    var assetIds = get_asset_ids_of_type(assetType, excludes)

    for i in assetIds:
        _loadedAssets[i] = null
        _loadedAssets.erase(i)
    pass

static func get_asset_path(assetId: String):
    var strings: Array = assetId.split(".")
    assert (_database.has_section_key(strings[0], strings[1]), "AssetId doesn't exist : %s" % assetId)
    var uidPath: Array = _database.get_value(strings[0], strings[1])
    return uidPath[1]

static func get_loaded_asset(assetId: String):
    return _loadedAssets.get(assetId)

static func get_num_loaded_assets() -> int:
    return _loadedAssets.size()

static func get_asset_ids_of_type(assetType: String, excludes: PackedStringArray = []) -> PackedStringArray:
    var ret: PackedStringArray
    var types: PackedStringArray = _database.get_section_keys(assetType)

    for i in types:
        ret.append("%s.%s" % [assetType, i])
    return ret
