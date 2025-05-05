@tool
@icon("./assets/icon.svg")


class_name DialogueResource extends Resource


const DialogueLine = preload("./dialogue_line.gd")


@export var using_states: PackedStringArray = []


@export var titles: Dictionary = {}


@export var character_names: PackedStringArray = []


@export var first_title: String = ""


@export var lines: Dictionary = {}


@export var raw_text: String





func get_next_dialogue_line(title: String = "", extra_game_states: Array = [], mutation_behaviour: DMConstants.MutationBehaviour = DMConstants.MutationBehaviour.Wait) -> DialogueLine:
    return await Engine.get_singleton("DialogueManager").get_next_dialogue_line(self, title, extra_game_states, mutation_behaviour)



func get_titles() -> PackedStringArray:
    return titles.keys()


func _to_string() -> String:
    return "<DialogueResource titles=\"%s\">" % [",".join(titles.keys())]
