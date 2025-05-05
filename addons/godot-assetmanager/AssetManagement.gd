@tool
extends EditorPlugin
class_name AssetManagement

var _assetManagerPanel: EditorAssetManager
var _config: AssetConfig



func _exit_tree():
    if is_instance_valid(_assetManagerPanel) and not _assetManagerPanel.is_queued_for_deletion():
        _assetManagerPanel.queue_free()
    pass

func _has_main_screen():
    return true

func _make_visible(visible):
    if visible: _setup_page()
    else: _destroy_page()

    pass

func _get_plugin_name():
    return "Asset Management"

func _setup_page():
    _config = AssetConfig.new()
    if FileAccess.file_exists(AssetManager.assetConfigPath):
        var error: Error = _config.load(AssetManager.assetConfigPath)
        if error:
            push_error("Failed to load AssetConfig. Error: %s" % error)
    else:
        var error: Error = _config.save(AssetManager.assetConfigPath)
        if error:
            push_error("Failed to create AssetConfig. Error: %s" % error)

    print("AssetConfig loaded")

    var editorScene = load("res://addons/godot-assetmanager/Scenes/EditorAssetManager.tscn")
    _assetManagerPanel = editorScene.instantiate()
    _assetManagerPanel.setup(weakref(_config))
    EditorInterface.get_editor_main_screen().add_child(_assetManagerPanel)
    pass

func _destroy_page():
    if not is_instance_valid(_config):
        return

    match _config.save(AssetManager.assetConfigPath):
        OK:
            print("AssetConfig.cfg saved.")
        var e:
            push_error("Cannot save AssetConfig.cfg. Error: %s" % e)

    if is_instance_valid(_assetManagerPanel) and not _assetManagerPanel.is_queued_for_deletion():
        _assetManagerPanel.queue_free()
    pass
