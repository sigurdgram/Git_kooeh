extends UI_Widget
class_name UI_Layer

@export var _removeWidgetsWhenChangeScene: bool = true

var displayedWidget: UI_Widget
signal onDisplayedWidgetChanged(displayedWidget: UI_Widget)



func _ready():
    if _removeWidgetsWhenChangeScene:
        GameInstance.onSceneChange.connect(func(_path): ClearWidgets())
    pass

func SwitchToWidget(widget: UI_Widget):
    if (is_instance_valid(displayedWidget) && displayedWidget.is_visible_in_tree()):
        displayedWidget.hide()
        displayedWidget.DeactivateWidgetInternal()

    displayedWidget = widget
    displayedWidget.show()
    displayedWidget.ActivateWidgetInternal(self)

    onDisplayedWidgetChanged.emit(widget)

func AddWidget(packedScene: PackedScene) -> UI_Widget:
    var node: Node = packedScene.instantiate()
    add_child(node, true)

    var widget: UI_Widget = node as UI_Widget
    assert (widget, "PackedScene instantiated by UI_Layer must be a UI_Widget")
    SwitchToWidget(widget)
    return widget

func AdditiveAddWidget(packedScene: PackedScene) -> UI_Widget:
    var widget: Node = packedScene.instantiate() as UI_Widget
    assert (widget, "PackedScene instantiated by UI_Layer must be a UI_Widget")
    add_child(widget)

    widget.show()
    displayedWidget = widget
    widget.ActivateWidgetInternal(self)
    return widget

func RemoveWidget(widget: UI_Widget):
    var indexInTree: int = widget.get_index()
    if (widget == displayedWidget && indexInTree > 0):
        var previousWidget: UI_Widget = get_child(indexInTree - 1) as UI_Widget
        if is_instance_valid(previousWidget):
            SwitchToWidget(previousWidget)

    widget.DeactivateWidgetInternal()
    widget.queue_free()
    pass

func GetWidgetCount():
    return get_child_count()

func ClearWidgets():
    for child in get_children():
        var widget: UI_Widget = child as UI_Widget
        if widget.is_visible_in_tree():
            widget.DeactivateWidgetInternal()
        child.queue_free()
    pass
