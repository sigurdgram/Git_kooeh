@tool
extends Control

var _configWeakRef: WeakRef
var _sectionName: String
var _editor: WeakRef



func setup(sectionName: String, configWeakRef: WeakRef, editor: WeakRef):
    _sectionName = sectionName
    _configWeakRef = configWeakRef
    _editor = editor
    name = _sectionName

    var assetNameVBox = % VBOX_AssetName
    var assetUIDVBox = % VBOX_AssetUID
    var assetConfig: AssetConfig = _configWeakRef.get_ref()
    for i in assetConfig.get_section_keys(_sectionName):

        var uidPath: Array = assetConfig.get_value(_sectionName, i)
        var uidText: String = uidPath[0]
        var path: String = uidPath[1]
        var id: int = ResourceUID.text_to_id(uidText)
        var vBoxAssetUID: = VBox_AssetUID.new(uidText, path)

        match _validate_asset_data(id, uidText, path):
            1: uidText = "INVALID"
            2: path = "INVALID"


        var hboxAssetName: = HBox_AssetName.new(i, 
            _on_delete.bindv([_sectionName, i]), 
            _on_edit.bindv([_sectionName, i, uidText]))

        assetNameVBox.add_child(hboxAssetName)
        assetUIDVBox.add_child(vBoxAssetUID)
    pass

func _validate_asset_data(id: int, uidText: String, path: String) -> int:
    if !ResourceUID.has_id(id):
        push_error("UID Invalid: %s : %s" % [uidText, path])
        return 1

    if ResourceUID.get_id_path(id) != path:
        push_error("Path Invalid: %s : %s" % [uidText, path])
        return 2

    return 0

func _on_delete(sectionName: String, sectionKey: String):
    _editor.get_ref().delete_confirmation(
        "Are you sure you want to delete %s.%s?" % [sectionName, sectionKey], 
        func yes():
            var assetConfig: AssetConfig = _configWeakRef.get_ref()
            assetConfig.erase_section_key_(sectionName, sectionKey), 
        func no(): pass)
    pass

func _on_edit(sectionName: String, sectionKey: String, value: String):
    _editor.get_ref().begin_edit(sectionName, sectionKey, value)
    pass


class HBox_AssetName extends HBoxContainer:
    var _editBtn: Button
    var _deleteBtn: Button
    var _assetNameLE: LineEdit



    func _init(assetName: String, deleteCallback: Callable, editCallback: Callable):
        var editorControl: = EditorInterface.get_base_control()
        _deleteBtn = Button.new()
        _deleteBtn.icon = editorControl.get_theme_icon("Close", "EditorIcons")
        _deleteBtn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        _deleteBtn.pressed.connect(deleteCallback)
        add_child(_deleteBtn)

        _editBtn = Button.new()
        _editBtn.icon = editorControl.get_theme_icon("Edit", "EditorIcons")
        _editBtn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        _editBtn.pressed.connect(editCallback)
        add_child(_editBtn)

        _assetNameLE = LineEdit.new()
        _assetNameLE.editable = false
        _assetNameLE.text = assetName
        _assetNameLE.custom_minimum_size = Vector2(0.0, 64.0)
        _assetNameLE.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        add_child(_assetNameLE)
        pass

    pass

class VBox_AssetUID extends VBoxContainer:

    var _uidLE: LineEdit
    var _pathLE: LineEdit



    func _init(uid: String, assetPath: String = ""):
        _uidLE = LineEdit.new()
        _uidLE.editable = false
        _uidLE.custom_minimum_size = Vector2(0.0, 30.0)
        _uidLE.text = uid

        add_child(_uidLE)

        _pathLE = LineEdit.new()
        _pathLE.editable = false
        _pathLE.custom_minimum_size = Vector2(0.0, 30.0)
        _pathLE.placeholder_text = "INVALID"

        if !assetPath.is_empty():
            _pathLE.text = assetPath

        add_child(_pathLE)
    pass
