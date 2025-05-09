class_name DialogueManagerExampleBalloon extends CanvasLayer



@export var next_action: StringName = &"ui_accept"


@export var skip_action: StringName = &"ui_cancel"


var resource: DialogueResource


var temporary_game_states: Array = []


var is_waiting_for_input: bool = false


var will_hide_balloon: bool = false


var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()


var dialogue_line: DialogueLine:
    set(value):
        if value:
            dialogue_line = value
            apply_dialogue_line()
        else:

            queue_free()
    get:
        return dialogue_line


var mutation_cooldown: Timer = Timer.new()


@onready var balloon: Control = % Balloon


@onready var character_label: RichTextLabel = % CharacterLabel


@onready var dialogue_label: DialogueLabel = % DialogueLabel


@onready var responses_menu: DialogueResponsesMenu = % ResponsesMenu


func _ready() -> void :
    balloon.hide()
    Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)


    if responses_menu.next_action.is_empty():
        responses_menu.next_action = next_action

    mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
    add_child(mutation_cooldown)


func _unhandled_input(_event: InputEvent) -> void :

    get_viewport().set_input_as_handled()


func _notification(what: int) -> void :

    if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
        _locale = TranslationServer.get_locale()
        var visible_ratio = dialogue_label.visible_ratio
        self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
        if visible_ratio < 1:
            dialogue_label.skip_typing()



func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void :
    temporary_game_states = [self] + extra_game_states
    is_waiting_for_input = false
    resource = dialogue_resource
    self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)



func apply_dialogue_line() -> void :
    mutation_cooldown.stop()

    is_waiting_for_input = false
    balloon.focus_mode = Control.FOCUS_ALL
    balloon.grab_focus()

    character_label.visible = not dialogue_line.character.is_empty()
    character_label.text = tr(dialogue_line.character, "dialogue")

    dialogue_label.hide()
    dialogue_label.dialogue_line = dialogue_line

    responses_menu.hide()
    responses_menu.responses = dialogue_line.responses


    balloon.show()
    will_hide_balloon = false

    dialogue_label.show()
    if not dialogue_line.text.is_empty():
        dialogue_label.type_out()
        await dialogue_label.finished_typing


    if dialogue_line.responses.size() > 0:
        balloon.focus_mode = Control.FOCUS_NONE
        responses_menu.show()
    elif dialogue_line.time != "":
        var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
        await get_tree().create_timer(time).timeout
        next(dialogue_line.next_id)
    else:
        is_waiting_for_input = true
        balloon.focus_mode = Control.FOCUS_ALL
        balloon.grab_focus()



func next(next_id: String) -> void :
    self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)





func _on_mutation_cooldown_timeout() -> void :
    if will_hide_balloon:
        will_hide_balloon = false
        balloon.hide()


func _on_mutated(_mutation: Dictionary) -> void :
    is_waiting_for_input = false
    will_hide_balloon = true
    mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void :

    if dialogue_label.is_typing:
        var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
        var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
        if mouse_was_clicked or skip_button_was_pressed:
            get_viewport().set_input_as_handled()
            dialogue_label.skip_typing()
            return

    if not is_waiting_for_input: return
    if dialogue_line.responses.size() > 0: return


    get_viewport().set_input_as_handled()

    if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
        next(dialogue_line.next_id)
    elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
        next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void :
    next(response.next_id)
