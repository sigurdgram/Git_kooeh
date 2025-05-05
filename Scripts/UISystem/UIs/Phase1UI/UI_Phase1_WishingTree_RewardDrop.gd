extends Control
class_name UI_Phase1_WishingTree_RewardDrop

@export var _textRect: TextureRect
@export var _amountTxt: Label

var _onEnd: Callable


func setup(itemID: String, amount: int, startLoc: Vector2, endLoc: Vector2, slot: UI_Item_Frame, \
onEnd: Callable, dropAudio: AudioStream, flyAudio: AudioStream):
    _onEnd = onEnd
    global_position = startLoc

    var item: IngredientData = AssetManager.load_asset(itemID).get_ref()
    _textRect.texture = item.texture
    _amountTxt.text = "x%s" % amount

    var slotCenter: Vector2 = slot.get_global_rect().get_center()
    var tweener: Tween = create_tween()
    tweener.tween_property(self, "global_position", endLoc, 1.0).set_trans(Tween.TRANS_BOUNCE)
    tweener.parallel().tween_callback(func play_audio(): AudioSystem.play_sfx(dropAudio)).set_delay(0.7)
    tweener.tween_interval(0.5)
    tweener.tween_callback(func play_audio(): AudioSystem.play_sfx(flyAudio))
    tweener.tween_property(self, "global_position", slotCenter, 0.5).set_ease(Tween.EASE_IN)
    tweener.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5)
    tweener.tween_callback(func show_slot(): slot.modulate = Color.WHITE)
    tweener.tween_callback(queue_free)
    pass

func _exit_tree():
    _onEnd.call()
    pass
