extends UI_BuildableProcess

@export_category("PackedScenes")
@export var _buyFramePackedScene: PackedScene

@export_category("Reference")
@export var _hboxFrames: HBoxContainer

func setup(buildableSystem: BuildableSystem) -> void :
    super .setup(buildableSystem)

    for asset in AssetManager.load_assets_of_type("BuildableData"):
        var buyFrame: UI_BuildableProcess_Build_Entry = _buyFramePackedScene.instantiate()
        buyFrame.setup(asset, _on_click_frame.bind(asset))
        _hboxFrames.add_child(buyFrame)
    pass

func _gui_input(event: InputEvent) -> void :
    if event.is_action("zoom_in") or event.is_action("zoom_out"):
        accept_event()
    pass

func _on_click_frame(item: WeakRef) -> void :
    _buildableSystem.select_buildable(item.get_ref())
    pass
