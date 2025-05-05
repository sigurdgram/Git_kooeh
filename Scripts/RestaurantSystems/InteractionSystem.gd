extends Node
class_name InteractionSystem

var _limitedInteractableItems: Array
var buttonDownObject: Node



func is_limited_interaction() -> bool:
    return not _limitedInteractableItems.is_empty()

func add_limited_interactable_item(node: Node2D):
    if not _limitedInteractableItems.has(node):
        _limitedInteractableItems.push_back(node)
    pass

func limited_interactables_contains(node: Node2D) -> bool:
    return _limitedInteractableItems.has(node)

func remove_limited_interactable_item(node: Node2D):
    if _limitedInteractableItems.has(node):
        _limitedInteractableItems.erase(node)
    pass

func clear_limited_interactable_items():
    _limitedInteractableItems.clear()
    pass
