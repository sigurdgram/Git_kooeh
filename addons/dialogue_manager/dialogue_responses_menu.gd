@icon("./assets/responses_menu.svg")


class_name DialogueResponsesMenu extends Container



signal response_selected(response)



@export var response_template: Control


@export var next_action: StringName = &""


@export var hide_failed_responses: bool = false


var responses: Array = []:
    get:
        return responses
    set(value):
        responses = value


        for item in get_children():
            if item == response_template: continue

            remove_child(item)
            item.queue_free()


        if responses.size() > 0:
            for response in responses:
                if hide_failed_responses and not response.is_allowed: continue

                var item: Control
                if is_instance_valid(response_template):
                    item = response_template.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
                    item.show()
                else:
                    item = Button.new()
                item.name = "Response%d" % get_child_count()
                if not response.is_allowed:
                    item.name = item.name + &"Disallowed"
                    item.disabled = true


                if "response" in item:
                    item.response = response

                else:
                    item.text = response.text

                item.set_meta("response", response)

                add_child(item)

            _configure_focus()


func _ready() -> void :
    visibility_changed.connect(func():
        if visible and get_menu_items().size() > 0:
            var first_item: Control = get_menu_items()[0]
            if first_item.is_inside_tree():
                first_item.grab_focus()
    )

    if is_instance_valid(response_template):
        response_template.hide()



func get_menu_items() -> Array:
    var items: Array = []
    for child in get_children():
        if not child.visible: continue
        if "Disallowed" in child.name: continue
        items.append(child)

    return items






func _configure_focus() -> void :
    var items = get_menu_items()
    for i in items.size():
        var item: Control = items[i]

        item.focus_mode = Control.FOCUS_ALL

        item.focus_neighbor_left = item.get_path()
        item.focus_neighbor_right = item.get_path()

        if i == 0:
            item.focus_neighbor_top = item.get_path()
            item.focus_previous = item.get_path()
        else:
            item.focus_neighbor_top = items[i - 1].get_path()
            item.focus_previous = items[i - 1].get_path()

        if i == items.size() - 1:
            item.focus_neighbor_bottom = item.get_path()
            item.focus_next = item.get_path()
        else:
            item.focus_neighbor_bottom = items[i + 1].get_path()
            item.focus_next = items[i + 1].get_path()

        item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
        item.gui_input.connect(_on_response_gui_input.bind(item, item.get_meta("response")))

    items[0].grab_focus()







func _on_response_mouse_entered(item: Control) -> void :
    if "Disallowed" in item.name: return

    item.grab_focus()


func _on_response_gui_input(event: InputEvent, item: Control, response) -> void :
    if "Disallowed" in item.name: return

    if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
        get_viewport().set_input_as_handled()
        response_selected.emit(response)
    elif event.is_action_pressed(&"ui_accept" if next_action.is_empty() else next_action) and item in get_menu_items():
        get_viewport().set_input_as_handled()
        response_selected.emit(response)
