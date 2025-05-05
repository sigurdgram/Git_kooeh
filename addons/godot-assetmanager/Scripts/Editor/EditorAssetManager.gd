@tool
extends Control
class_name EditorAssetManager

var _configWeakRef: WeakRef
var assetTypeContentScene: PackedScene = preload("res://addons/godot-assetmanager/Scenes/UI_AssetTypeContent.tscn")



func setup(configWeakRef: WeakRef):
    _configWeakRef = configWeakRef
    _refresh_UI()
    _configWeakRef.get_ref().onLoaded.connect(_refresh_UI)
    pass

func _on_btn_create_new_asset_id_pressed():
    % PN_CreateNewAssetIdPopUp.popup(_configWeakRef)
    pass

func _on_btn_delete_asset_type_pressed():
    var assetTypeTab: TabContainer = % TABCONT_AssetType
    var currentTab: int = assetTypeTab.current_tab
    var tabTitle: String = assetTypeTab.get_tab_title(currentTab)

    % PN_DeleteConfirmationPopUp.setup("Are you sure you want to delete %s asset type?" % tabTitle, 
    func yes():
        _configWeakRef.get_ref().erase_section_(tabTitle), 
    func no(): pass)

    pass

func begin_edit(sectionName: String, sectionKey: String, value: String):
    % PN_CreateNewAssetIdPopUp.popup(_configWeakRef, sectionName, sectionKey, value)
    pass

func _refresh_UI():
    for i in % TABCONT_AssetType.get_children():
        % TABCONT_AssetType.remove_child(i)
        i.queue_free()

    var assetConfig: AssetConfig = _configWeakRef.get_ref()

    for i in assetConfig.get_sections():
        var newTab: = assetTypeContentScene.instantiate()
        newTab.setup(i, _configWeakRef, weakref(self))
        % TABCONT_AssetType.add_child(newTab)
    pass

func delete_confirmation(description: String, yes: Callable, no: Callable):
    % PN_DeleteConfirmationPopUp.setup(description, yes, no)
    pass
