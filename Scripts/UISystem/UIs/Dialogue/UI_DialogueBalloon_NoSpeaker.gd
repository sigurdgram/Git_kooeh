extends UI_Widget
class_name UI_DialogueBalloon_NoSpeaker

@export var balloon: Control
@export var dialogue_label: Node
@export var responses_menu: VBoxContainer
@export var response_template: RichTextLabel
@export var _dialogueFinishedHBox: HBoxContainer

signal finished_typing()


var _dialogueSet: DialogueSet


var temporary_game_states: Array = []


var is_waiting_for_input: bool = false


var will_hide_balloon: bool = false

var _enable_user_input: bool = true


var dialogue_line: DialogueLine:
    set(next_dialogue_line):
        is_waiting_for_input = false
        _dialogueFinishedHBox.hide()

        if not next_dialogue_line:
            return


        for child in responses_menu.get_children():
            responses_menu.remove_child(child)
            child.queue_free()

        dialogue_line = next_dialogue_line

        dialogue_label.modulate.a = 0

        dialogue_label.dialogue_line = dialogue_line


        responses_menu.modulate.a = 0
        if dialogue_line.responses.size() > 0:
            for response in dialogue_line.responses:

                var item: RichTextLabel = response_template.duplicate(0)
                item.name = "Response%d" % responses_menu.get_child_count()
                if not response.is_allowed:
                    item.name = String(item.name) + "Disallowed"
                    item.modulate.a = 0.4
                item.text = response.text
                item.show()
                responses_menu.add_child(item)


        balloon.show()
        will_hide_balloon = false

        dialogue_label.modulate.a = 1
        if not dialogue_line.text.is_empty():
            dialogue_label.type_out()
            await dialogue_label.finished_typing
            finished_typing.emit()
            _dialogueFinishedHBox.show()


        if dialogue_line.responses.size() > 0:
            responses_menu.modulate.a = 1
            configure_menu()
        elif dialogue_line.time != null and DialogueSystem._isAutoplayOn:
            var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
            await get_tree().create_timer(time, false).timeout
            next(dialogue_line.next_id)
        else:
            is_waiting_for_input = true


    get:
        return dialogue_line


func _ready() -> void :
    response_template.hide()
    Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)
    _dialogueFinishedHBox.hide()
    pass

func set_enable_user_input(state: bool = true):
    _enable_user_input = state
    mouse_filter = MOUSE_FILTER_STOP if state else MOUSE_FILTER_IGNORE
    pass

func _input(event: InputEvent) -> void :
    if not _enable_user_input: return
    if not is_waiting_for_input: return
    if dialogue_line.responses.size() > 0: return


    if event.is_action_pressed("act_interact") and get_viewport().gui_get_focus_owner() == balloon:
        next(dialogue_line.next_id)
    pass


func start(dialogueSet: DialogueSet, title: String, extra_game_states: Array = []) -> void :
    temporary_game_states = extra_game_states
    is_waiting_for_input = false
    _dialogueSet = dialogueSet
    balloon.grab_focus()
    self.dialogue_line = await _dialogueSet.dialogueResource.get_next_dialogue_line(title, temporary_game_states)
    pass


func next(next_id: String) -> void :
    self.dialogue_line = await _dialogueSet.dialogueResource.get_next_dialogue_line(next_id, temporary_game_states)
    pass





func configure_menu() -> void :
    balloon.focus_mode = Control.FOCUS_NONE

    var items = get_responses()
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
        item.gui_input.connect(_on_response_gui_input.bind(item))

    items[0].grab_focus()



func get_responses() -> Array:
    var items: Array = []
    for child in responses_menu.get_children():
        if "Disallowed" in child.name: continue
        items.append(child)

    return items




func _on_mutated(_mutation: Dictionary) -> void :
    is_waiting_for_input = false
    will_hide_balloon = true
    get_tree().create_timer(0.1, false).timeout.connect(func():
        if will_hide_balloon:
            will_hide_balloon = false
            balloon.hide()
    )

func _on_response_mouse_entered(item: Control) -> void :
    if "Disallowed" in item.name: return

    item.grab_focus()


func _on_response_gui_input(event: InputEvent, item: Control) -> void :
    if "Disallowed" in item.name: return

    get_viewport().set_input_as_handled()

    if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
        next(dialogue_line.responses[item.get_index()].next_id)
    elif event.is_action_pressed("act_interact") and item in get_responses():
        next(dialogue_line.responses[item.get_index()].next_id)
