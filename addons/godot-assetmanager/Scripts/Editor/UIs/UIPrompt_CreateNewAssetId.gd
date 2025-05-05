@tool
extends Panel
class_name UIPrompt_CreateNewAssetId

var _configWeakRef: WeakRef



func _init():
    hide()
    pass

func popup(configWeakRef: WeakRef, sectionName: String = "", sectionKey: String = "", value: String = ""):
    _configWeakRef = configWeakRef

    if !sectionName.is_empty():
        % LE_AssetId.text = "%s.%s" % [sectionName, sectionKey]
        % LE_AssetUID.text = value

    show()
    pass

func _on_btn_yes_pressed():
    var assetId: String = % LE_AssetId.text
    var assetUID: String = % LE_AssetUID.text
    var assetConfig: AssetConfig = _configWeakRef.get_ref()

    var strings = assetId.split(".")

    var error: String = _validate_inputs(strings, assetUID)
    if error.is_empty():
        var uid: int = ResourceUID.text_to_id(assetUID)
        var path: String = ResourceUID.get_id_path(uid)
        assetConfig.set_value_(strings[0], strings[1], [assetUID, path])

        var item = load(path)
        if is_instance_valid(item):
            item.resource_name = assetId
        hide()
    else:
        push_warning(error)
    pass

func _on_btn_close_pressed():
    hide()
    pass

func _validate_inputs(assetIds: Array[String], assetUID: String):
    var ret: String

    if assetIds.size() != 2:
        ret = "AssetId is not in the format of AssetType.AssetName"
    elif !assetUID.begins_with("uid://"):
        ret = "AssetUID: is invalid"
    return ret
