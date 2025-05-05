extends UI_Widget
class_name UI_BuildableRestrictions

@export var container: VBoxContainer
@export var textLabelScene: PackedScene

func clear_list():
    if not container.get_child_count() == 0:
        for child in container.get_children():
            child.queue_free()
    pass

func add_restriction(restrictMsg: String):
    var newRestriction: RichTextLabel = textLabelScene.instantiate()

    container.add_child(newRestriction)
    newRestriction.add_text(restrictMsg)
    pass
