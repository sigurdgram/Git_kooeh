extends Control
class_name UI_BuildableEditor

@export var _buildableSystem: BuildableSystem
@export var _gridData: BuildableGridData

@export_category("UIs")
@export var _HBOXBuildableProcesses: HBoxContainer

var _processMenuInstance: UI_BuildableProcess
var _interactionMapping: Dictionary

var _fileDialog: FileDialog

func _ready() -> void :

    var buildConfig: Dictionary = {BuildableTypes.BuildConfig_GridData: _gridData.resource_path}
    _buildableSystem.build(buildConfig)

    _interactionMapping = _buildableSystem.get_interaction_mapping()
    for i in _interactionMapping:
        var iButton: = Button.new()
        iButton.text = i
        iButton.pressed.connect(_on_select_process.bind(i))
        _HBOXBuildableProcesses.add_child(iButton)

    _buildableSystem.isEditing = true
    _buildableSystem.set_build_mode(BuildableTypes.BuildMode_Build)
    _on_select_process(_buildableSystem.mode)
    pass

func _exit_tree() -> void :
    _buildableSystem.isEditing = false
    pass

func _input(event: InputEvent) -> void :
    if event is InputEventKey and event.is_pressed():
        match event.keycode:
            KEY_MINUS:
                if is_instance_valid(_fileDialog):
                    return

                _fileDialog = _create_file_dialog("Load a config")
                _fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
                _fileDialog.file_selected.connect(_load_file_selected)
                _fileDialog.show()

            KEY_0:
                if is_instance_valid(_fileDialog):
                    return

                _fileDialog = _create_file_dialog("Save a config")
                _fileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
                _fileDialog.file_selected.connect(_save_file_selected)
                _fileDialog.show()
    pass

func _create_file_dialog(title: String) -> FileDialog:
    var ret: = FileDialog.new()
    ret.title = title
    ret.visibility_changed.connect(func(): if not ret.visible: ret.queue_free())
    ret.add_filter("*.json", "Json Files")
    var cl: CanvasLayer = get_canvas_layer_node()
    ret.size = Vector2(500, 400)
    ret.position = (Vector2i(get_viewport_rect().size) - ret.size) * 0.5
    cl.add_child(ret)
    return ret

func _load_file_selected(path: String) -> void :
    var jsonString: String = FileAccess.get_file_as_string(path)
    var configDict: Dictionary = JSON.parse_string(jsonString)
    _buildableSystem.build(configDict)
    pass

func _save_file_selected(path: String) -> void :
    var configDict: Dictionary = _buildableSystem.generate_save_config_dict()
    var file: FileAccess = FileAccess.open(path, FileAccess.WRITE_READ)
    var jsonString = JSON.stringify(configDict, "	")
    file.store_string(jsonString)
    file.close()
    pass

func _on_select_process(mode: StringName) -> void :
    _buildableSystem.mode = mode
    if is_instance_valid(_processMenuInstance):
        _processMenuInstance.free()

    var buildableProcess: BuildableProcess = _buildableSystem.get_interaction_mapping()[mode]
    if is_instance_valid(buildableProcess.processMenu):
        _processMenuInstance = buildableProcess.processMenu.instantiate()
        _processMenuInstance.setup(_buildableSystem)
        add_child(_processMenuInstance)
    pass
