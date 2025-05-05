extends Control
class_name UI_Widget

signal onActivated
signal onDeactivated

var _parentLayer: UI_Layer


func get_owning_layer_name() -> String:
    return _parentLayer.name

func _exit_tree():
    DeactivateWidgetInternal()
    pass

func ActivateWidgetInternal(parentLayer: UI_Layer):
    _parentLayer = parentLayer
    ActivateWidget()
    onActivated.emit()
    pass

func ActivateWidget():
    pass

func DeactivateWidget():
    pass

func DeactivateWidgetInternal():
    DeactivateWidget()
    if not onDeactivated.is_null():
        onDeactivated.emit()
