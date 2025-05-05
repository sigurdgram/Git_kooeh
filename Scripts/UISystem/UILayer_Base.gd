extends UI_Layer
class_name UILayer_Base



func SwitchToWidget(widget: UI_Widget):
    widget.show()
    widget.ActivateWidgetInternal(self)
    onDisplayedWidgetChanged.emit(widget)
    pass

func AddWidget(packedScene: PackedScene) -> UI_Widget:
    var node: Node = packedScene.instantiate()
    add_child(node, true)

    var widget: UI_Widget = node as UI_Widget
    assert (widget, "PackedScene instantiated by UI_Layer must be a UI_Widget")
    SwitchToWidget(widget)
    return widget
