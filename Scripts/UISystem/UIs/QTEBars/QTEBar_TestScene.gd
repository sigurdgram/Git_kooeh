extends Control

@export var radialQTEBar_OneShot: QTEBar_Radial_TapInRange
@export var radialQTEBar_PingPong: QTEBar_Radial_TapInRange
@export var radialQTEData_OneShot: QTEData_Radial
@export var radialQTEData_PingPong: QTEData_Radial

@export var horiQTEBar_OneShot: QTEBar_Hori_TapInRange
@export var horiQTEBar_PingPong: QTEBar_Hori_TapInRange
@export var horiQTEData_OneShot: QTEData_Hori
@export var horiQTEData_PingPong: QTEData_Hori

@export var dragQTEData_StraightVertical: QTEData_Drag
@export var dragQTEBar_StraightVertical: QTEBar_Drag
@export var dragQTEData_StraightHorizontal: QTEData_Drag
@export var dragQTEBar_StraightHorizontal: QTEBar_Drag

@export var dragQTEData_C: QTEData_Drag
@export var dragQTEBar_C: QTEBar_Drag

@export var dragQTEData_SemicircleC: QTEData_Drag
@export var dragQTEBar_SemicircleC: QTEBar_Drag

@export var dragQTEData_CircleClockwise: QTEData_Drag
@export var dragQTEBar_CircleClockwise: QTEBar_Drag

@export var dragQTEData_CircleAnticlockwise: QTEData_Drag
@export var dragQTEBar_CircleAnticlockwise: QTEBar_Drag

@export var dragQTEData_StraightForwardSlash: QTEData_Drag
@export var dragQTEBar_StraightForwardSlash: QTEBar_Drag

@export var dragQTEData_StraightBackSlash: QTEData_Drag
@export var dragQTEBar_StraightBackSlash: QTEBar_Drag


func _ready():
    radialQTEBar_OneShot.onTimeOut.connect(_on_radial_oneshot_timeout)
    radialQTEBar_PingPong.setup(radialQTEData_PingPong, true)
    radialQTEBar_OneShot.setup(radialQTEData_OneShot, true)

    horiQTEBar_OneShot.onTimeOut.connect(_on_hori_oneshot_timeout)
    horiQTEBar_OneShot.setup(horiQTEData_OneShot, true)
    horiQTEBar_PingPong.setup(horiQTEData_PingPong, true)

    dragQTEBar_StraightVertical.onBroadcastResult.connect(_on_drag_straight_vertical_broadcast)
    dragQTEBar_StraightVertical.setup(dragQTEData_StraightVertical, true)

    dragQTEBar_StraightHorizontal.onBroadcastResult.connect(_on_drag_straight_horizontal_broadcast)
    dragQTEBar_StraightHorizontal.setup(dragQTEData_StraightHorizontal, true)

    dragQTEBar_C.onBroadcastResult.connect(_on_drag_C_broadcast)
    dragQTEBar_C.setup(dragQTEData_C, true)

    dragQTEBar_SemicircleC.onBroadcastResult.connect(_on_drag_SemicircleC_broadcast)
    dragQTEBar_SemicircleC.setup(dragQTEData_SemicircleC, true)

    dragQTEBar_CircleClockwise.onBroadcastResult.connect(_on_drag_CircleClockwise_broadcast)
    dragQTEBar_CircleClockwise.setup(dragQTEData_CircleClockwise, true)

    dragQTEBar_CircleAnticlockwise.onBroadcastResult.connect(_on_drag_CircleAnticlockwise_broadcast)
    dragQTEBar_CircleAnticlockwise.setup(dragQTEData_CircleAnticlockwise, true)

    dragQTEBar_StraightForwardSlash.onBroadcastResult.connect(_on_drag_straight_forward_slash_broadcast)
    dragQTEBar_StraightForwardSlash.setup(dragQTEData_StraightForwardSlash, true)

    dragQTEBar_StraightBackSlash.onBroadcastResult.connect(_on_drag_straight_back_slash_broadcast)
    dragQTEBar_StraightBackSlash.setup(dragQTEData_StraightBackSlash, true)
    pass

func _on_radial_oneshot_timeout():
    await get_tree().process_frame
    radialQTEBar_OneShot.setup(radialQTEData_OneShot, true)
    pass

func _on_hori_oneshot_timeout():
    await get_tree().process_frame
    horiQTEBar_OneShot.setup(horiQTEData_OneShot, true)
    pass

func _on_drag_straight_vertical_broadcast(_success: bool):
    await get_tree().process_frame
    dragQTEBar_StraightVertical.setup(dragQTEData_StraightVertical, true)
    pass

func _on_drag_straight_horizontal_broadcast(_success: bool):
    await get_tree().process_frame
    dragQTEBar_StraightHorizontal.setup(dragQTEData_StraightHorizontal, true)
    pass

func _on_drag_C_broadcast(_success: bool):
    await get_tree().process_frame
    dragQTEBar_C.setup(dragQTEData_C, true)
    pass

func _on_drag_SemicircleC_broadcast(_success: bool):
    await get_tree().process_frame
    dragQTEBar_SemicircleC.setup(dragQTEData_SemicircleC, true)
    pass

func _on_drag_CircleClockwise_broadcast(_success: bool):
    await get_tree().process_frame
    dragQTEBar_CircleClockwise.setup(dragQTEData_CircleClockwise, true)
    pass

func _on_drag_CircleAnticlockwise_broadcast(_success: bool):
    await get_tree().process_frame
    dragQTEBar_CircleAnticlockwise.setup(dragQTEData_CircleAnticlockwise, true)
    pass

func _on_drag_straight_forward_slash_broadcast(_success: bool):
    await get_tree().process_frame
    dragQTEBar_StraightForwardSlash.setup(dragQTEData_StraightForwardSlash, true)
    pass

func _on_drag_straight_back_slash_broadcast(_success: bool):
    await get_tree().process_frame
    dragQTEBar_StraightBackSlash.setup(dragQTEData_StraightBackSlash, true)
    pass
