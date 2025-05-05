extends CampaignEvent
class_name CampaignEvent_Prologue

var _prologueOrc: PrologueOrchestrator


func is_event_executable() -> bool:
    return CampaignSystem.get_event_status(identifier) <= KooehConstant.CampaignStatus.INPROGRESS

func _init():
    identifier = KooehConstant.Prologue
    retriggerable = true
    pass

func exit():
    super .exit()
    _prologueOrc.queue_free()
    pass

func ready():
    super .ready()

    _prologueOrc = PrologueOrchestrator.new(self)
    CampaignSystem.add_child(_prologueOrc)
    pass

class PrologueOrchestrator extends Node:
    var _videoPlayerUI: PackedScene = preload("res://Scenes/UIs/Misc/UI_VideoPlayer.tscn")
    var _prologueVideo: VideoStream = preload("res://Art/Media/Vid_Prologue.ogv")
    var _prologueDialogueSet: DialogueSet = preload("res://Resources/DialogueSet/Prologue/DialogueSet_Prologue.tres")
    var prologuePhase1Level: PackedScene = preload("res://Scenes/Levels/Prologue/LV_Prologue_Phase1.tscn")
    var prologuePhase2Level: PackedScene = preload("res://Scenes/Levels/Prologue/LV_Prologue_Phase2.tscn")
    var _phase2Level: PackedScene = preload("res://Scenes/Levels/Submission_1_Scene.tscn")
    var _owningCampaign: CampaignEvent_Prologue


    func _init(owningCampaign: CampaignEvent_Prologue):
        _owningCampaign = owningCampaign
        pass

    func _disable_at_main_menu(scenePath: String):
        if scenePath.get_file() == "LV_MainMenu.tscn":
            _owningCampaign.status = KooehConstant.CampaignStatus.PENDING
            CampaignSystem.set_event_inactive(_owningCampaign.identifier)
        pass

    func _ready():
        GameInstance.onSceneChange.connect(_disable_at_main_menu)


        InputManager.set_game_input_enabled(false)
        var videoPlayer = UITree.PushWidgetToLayer(_videoPlayerUI, UITree.layerGame) as UI_VideoPlayer
        GameInstance.modulate = Color.BLACK
        videoPlayer.play_video(_prologueVideo)
        await videoPlayer.finished()


        GameInstance.change_scene_packed(prologuePhase1Level)
        var world = await GameInstance.onGameWorldSet
        var tutorialHandler = Phase1TutorialHandler.new(self)
        world.set("tutorial", tutorialHandler)
        world.add_child(tutorialHandler)
        tutorialHandler.add_to_group("tutorial_prologue")
        await tutorialHandler.start()


        GameInstance.change_scene_packed(prologuePhase2Level)
        await GameInstance.onSceneChange
        await UITree.fade_to_clear()
        DialogueSystem.spawn_dialogue_additive(_prologueDialogueSet, "Prologue3")
        await DialogueSystem.onDialogueEnded
        await UITree.fade_to_black()


        GameInstance.change_scene_packed(_phase2Level)
        world = await GameInstance.onGameWorldSet
        tutorialHandler = Phase2TutorialHandler.new(self)
        world.tutorial = weakref(tutorialHandler)
        world.add_child(tutorialHandler)
        await world.deferred_start()
        await tutorialHandler.start()


        GameInstance.change_scene_packed(prologuePhase1Level)
        world = await GameInstance.onGameWorldSet
        var phase1TutorialHandler = Phase1TutorialHandler_2.new(self)
        world.tutorial = weakref(phase1TutorialHandler)
        world.add_child(phase1TutorialHandler)
        phase1TutorialHandler.add_to_group("tutorial_prologue")
        await phase1TutorialHandler.start()


        world = await GameInstance.onGameWorldSet
        var phase2Part2Tutorial = Phase2TutorialHandler_2.new(self)
        world.tutorial = weakref(phase2Part2Tutorial)
        world.add_child(phase2Part2Tutorial)
        await UITree.fade_to_clear()
        await phase2Part2Tutorial.start()

        _prologue_complete()
        pass

    func _prologue_complete():
        GameInstance.onSceneChange.disconnect(_disable_at_main_menu)
        _owningCampaign.status = KooehConstant.CampaignStatus.SUCCESS

        var gm = GameInstance.gameWorld as GameplayGameMode
        gm.tutorial = weakref(null)
        gm.onDayEnd.connect(_unlock_new_recipes)
        gm.onDayStart.emit()

        pass

    func _unlock_new_recipes():
        var completionReward: PackedStringArray = [
            FoodLibrary.KopiO, 
            FoodLibrary.TehTarik, 
            FoodLibrary.PatPoh, 
            FoodLibrary.KuihBahulu, 
            FoodLibrary.KuihSaguMerah, 
            FoodLibrary.Vadai, 
            FoodLibrary.AmbraJuice, 
        ]
        for i in completionReward:
            GameplayVariables.add_unlocked_recipe(i)

        CampaignSystem.set_event_inactive(_owningCampaign.identifier)
        pass
    pass

class Phase1TutorialHandler extends Node:
    var _owner: PrologueOrchestrator
    var _dialogueSetPrologue: DialogueSet = preload("res://Resources/DialogueSet/Prologue/DialogueSet_Prologue.tres")
    var _dialogueNoSpeaker: PackedScene = preload("res://Scenes/UIs/Dialogue/UI_DialogueBalloon_NoSpeaker.tscn")
    var _tana: PackedScene = preload("res://Character/Character_Tanah.tscn")

    var _canMove: bool = false
    signal player_moved()


    func _init(orc: PrologueOrchestrator):
        _owner = orc
        _canMove = false
        pass

    func _process(_delta):
        if not _canMove:
            return

        if not PlayerCharacter.player.velocity.is_zero_approx():
            set_process(false)
            player_moved.emit()
        pass

    func start():
        var tanaSpawnpoint = get_tree().get_first_node_in_group("Tana")
        var tana = _tana.instantiate()
        tanaSpawnpoint.add_child(tana)
        await UITree.fade_to_clear()
        DialogueSystem.spawn_dialogue(_dialogueSetPrologue, "Prologue2")
        await DialogueSystem.onDialogueEnded
        var noSpeakerBalloon: = UITree.PushWidgetToLayer(_dialogueNoSpeaker, UITree.layerGame) as UI_DialogueBalloon_NoSpeaker
        noSpeakerBalloon.start(_dialogueSetPrologue, "Prologue2_1")
        await noSpeakerBalloon.finished_typing
        InputManager.set_game_input_enabled(true)
        PlayerCharacter.player.set_interaction_toggle(true)
        _canMove = true
        await player_moved
        noSpeakerBalloon.queue_free()
        DialogueSystem.spawn_dialogue(_dialogueSetPrologue, "Prologue2_2")
        PlayerCharacter.player.set_interaction_toggle(false)
        await DialogueSystem.onDialogueEnded
        PlayerCharacter.player.set_interaction_toggle(true)
        InputManager.set_game_input_enabled(false)
        await UITree.fade_to_black()
        pass
    pass

class Phase1TutorialHandler_2 extends Node:
    var _dialogueNoSpeaker: PackedScene = preload("res://Scenes/UIs/Dialogue/UI_DialogueBalloon_NoSpeaker.tscn")
    var _blackScreenCutout: PackedScene = preload("res://Scenes/UIs/Misc/UI_BlackScreenCutout.tscn")
    var _dialogueSetPrologue: DialogueSet = preload("res://Resources/DialogueSet/Prologue/DialogueSet_Prologue.tres")
    var _tana: PackedScene = preload("res://Character/Character_Tanah.tscn")
    var _owner: PrologueOrchestrator
    var _interactionSystem: InteractionSystem

    signal grabIngredients(nextLineID: String)



    func _init(orc: PrologueOrchestrator):
        _owner = orc
        pass

    func start():
        var tanaSpawnpoint = get_tree().get_first_node_in_group("Tana")
        var tana = _tana.instantiate() as Sprite2D
        tanaSpawnpoint.add_child(tana)


        var tree: SceneTree = get_tree()
        var temple: = tree.get_first_node_in_group("Buildable_Temple") as Buildable_Temple1

        _interactionSystem = tree.get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
        await UITree.fade_to_clear()

        DialogueManager.got_dialogue.connect(
            func highlight_ingredient_box(line: DialogueLine):
                if line.id == "89":
                    grabIngredients.emit(line.next_id)
                    InputManager.set_game_input_enabled(true)
        )

        var vnBalloon: = DialogueSystem.spawn_dialogue_additive(_dialogueSetPrologue, "Prologue11", UITree.layerGameUI) as UI_DialogueBalloon
        var nextLine: String = await grabIngredients
        InputManager.set_game_input_enabled(false)
        vnBalloon.set_enable_user_input(false)

        _interactionSystem.add_limited_interactable_item(temple)
        var cutout = UITree.PushWidgetToLayer(_blackScreenCutout, UITree.layerGame) as UI_BlackScreenCutout
        cutout.emphasize([temple.get_sprite()])
        await InventorySystem.onIngredientInventoryUpdated
        cutout.hide()

        InputManager.set_game_input_enabled(false)
        vnBalloon.next(nextLine)
        vnBalloon.set_enable_user_input(true)
        await DialogueSystem.onDialogueEnded
        await get_tree().process_frame
        tana.flip_h = true
        vnBalloon = DialogueSystem.spawn_dialogue_additive(_dialogueSetPrologue, "Prologue11_2", UITree.layerGameUI) as UI_DialogueBalloon
        await DialogueSystem.onDialogueEnded


        var balloon: = UITree.PushWidgetToLayer(_dialogueNoSpeaker, UITree.layerGameUI) as UI_DialogueBalloon_NoSpeaker
        balloon.set_enable_user_input(false)
        balloon.start(_dialogueSetPrologue, "Prologue12")
        var wishingTree = tree.get_first_node_in_group("Tutorial_WishingTree") as Buildable_WishingTree1
        _interactionSystem.add_limited_interactable_item(wishingTree)
        cutout.emphasize([wishingTree.get_sprite()])
        cutout.show()
        _interactionSystem.clear_limited_interactable_items()

        InputManager.set_game_input_enabled(true)
        await wishingTree.onStartWish
        InputManager.set_game_input_enabled(false)
        cutout.hide()

        await tree.process_frame
        var wishingTreeUI: = wishingTree.get_wishing_tree_ui().get_ref() as UI_Phase1_WishingTree

        var wishingTreeQTE: = wishingTreeUI.get_wishingTree_QTEBar() as QTEBar_WishingTree
        wishingTreeQTE.onBroadcastResult.connect(
            func set_campaign_context(result):
                CampaignSystem.contextString = str(result)
        , CONNECT_ONE_SHOT)
        wishingTreeUI.set_can_start(false)
        await wishingTreeUI.get_wish_button().pressed
        wishingTreeUI.set_block_input(true)
        vnBalloon = DialogueSystem.spawn_dialogue(_dialogueSetPrologue, "Prologue13", UITree.layerGameUI) as UI_DialogueBalloon
        await DialogueSystem.onDialogueEnded
        wishingTreeUI.set_block_input(false)
        wishingTreeUI.set_can_start(true)
        wishingTreeUI.start_wish_qte()

        await wishingTreeUI.onDeactivated
        balloon.hide()
        await get_tree().process_frame
        InputManager.set_game_input_enabled(false)


        vnBalloon = DialogueSystem.spawn_dialogue(_dialogueSetPrologue, "Prologue14", UITree.layerGameUI) as UI_DialogueBalloon
        await DialogueSystem.onDialogueEnded


        balloon.show()
        balloon.start(_dialogueSetPrologue, "Prologue15")
        var signboard = tree.get_first_node_in_group("Tutorial_Signboard") as Buildable_Signboard1
        _interactionSystem.add_limited_interactable_item(signboard)

        var viewportSize: Vector2 = balloon.get_viewport_rect().size
        var targetBalloonSize: Vector2 = Vector2(500.0, 0.0)
        var tween = create_tween()
        tween.tween_property(balloon, "size", viewportSize - targetBalloonSize, 0.2)
        tween.parallel().tween_property(balloon, "position", Vector2(0.0, 0.0), 0.2)

        cutout = UITree.PushWidgetToLayer(_blackScreenCutout, UITree.layerGame) as UI_BlackScreenCutout
        cutout.emphasize([signboard.get_sprite()])

        await balloon.finished_typing
        InputManager.set_game_input_enabled(true)

        await PlayerCharacter.player.onInteractBuildable
        UITree.PopWidgetFromLayer(balloon, UITree.layerGameUI)
        cutout.hide()
        await signboard.onLevelLoaded


        pass

class Phase2TutorialHandler extends Node:
    var _dialogueNoSpeaker: PackedScene = preload("res://Scenes/UIs/Dialogue/UI_DialogueBalloon_NoSpeaker.tscn")
    var _phase3CookbookUI: PackedScene = preload("res://Scenes/UIs/Phase3UI/Cooking/UI_Phase3_Cookbook.tscn")
    var _blackScreenCutout: PackedScene = preload("res://Scenes/UIs/Misc/UI_BlackScreenCutout.tscn")
    var _ratingPrompt: PackedScene = preload("res://Scenes/UIs/Misc/UI_RatingPrompt.tscn")
    var _dialogueSetPrologue: DialogueSet = preload("res://Resources/DialogueSet/Prologue/DialogueSet_Prologue.tres")

    var _owner: PrologueOrchestrator
    var _gameMode: GameplayGameMode
    var _balloon: UI_DialogueBalloon_NoSpeaker
    var _phase3Cookbook: UI_Phase3_Cookbook
    var _phase3CookingUIInstance: WeakRef
    var _ratingPromptInstance: UI_RatingPrompt

    var _availableRecipes: PackedStringArray = PackedStringArray([

            FoodLibrary.OndehOndeh, 
            FoodLibrary.SirapLimau, 

    ])

    signal allAvailableRecipesLearned
    signal onGrabIngredients


    func _init(orc: PrologueOrchestrator):
        _owner = orc
        pass

    func _ready():
        _gameMode = get_parent()
        pass

    func start():
        _gameMode = GameInstance.gameWorld
        UITree.PushWidgetToLayer(_gameMode._essentialsUI, UITree.layerBase)


        InputManager.set_game_input_enabled(false)
        _balloon = UITree.PushWidgetToLayer(_dialogueNoSpeaker, UITree.layerGameUI) as UI_DialogueBalloon_NoSpeaker
        _balloon.start(_dialogueSetPrologue, "Prologue4")
        _balloon.set_enable_user_input(false)


        InventorySystem.set_ingredient_count(IngredientLibrary.Salt, 1)
        InventorySystem.set_ingredient_count(IngredientLibrary.Water, 2)
        InventorySystem.set_ingredient_count(IngredientLibrary.CoconutMilk, 2)

        _phase3Cookbook = UITree.PushWidgetToLayer(_phase3CookbookUI, UITree.layerGame) as UI_Phase3_Cookbook
        var entries: Array[Node] = _phase3Cookbook.get_cookbook_entries()
        var kuihLapisBtn: UI_Phase3_Cookbook_Entry
        for i in entries:
            var btn: = i as UI_Phase3_Cookbook_Entry
            if btn.get_food_data().resource_name == FoodLibrary.KuihLapis:
                kuihLapisBtn = i
            else:
                btn.set_active(false)

        await _phase3Cookbook.get_anim_player().animation_finished
        var viewportRect: Rect2 = _phase3Cookbook.get_viewport_rect()
        var viewportSize: Vector2 = viewportRect.size


        var cutout = UITree.AdditivePushWidgetToLayer(_blackScreenCutout, UITree.layerGame) as UI_BlackScreenCutout
        cutout.emphasize([kuihLapisBtn])
        _balloon.start(_dialogueSetPrologue, "Prologue5")

        kuihLapisBtn.grab_focus()
        await kuihLapisBtn.get_button().pressed


        var cookBtn: UI_BasicButton = _phase3Cookbook.get_cook_button()
        _balloon.start(_dialogueSetPrologue, "Prologue6")
        var halfXSize: Vector2 = viewportRect.size * Vector2(0.5, 1.0)
        _balloon.create_tween().tween_property(_balloon, "size", halfXSize, 0.2)
        var rightPage: Control = _phase3Cookbook.get_right_page()
        cutout.emphasize([rightPage], 0.2)
        cookBtn.grab_focus()

        var p3CookSystem: Phase3CookSystem = GameInstance.gameWorld.phase3CookSystem
        p3CookSystem.set_can_start(false)

        await cookBtn.pressed
        UITree.PopWidgetFromLayer(_balloon, UITree.layerGameUI)
        _balloon = UITree.AdditivePushWidgetToLayer(_dialogueNoSpeaker, UITree.layerGameUI) as UI_DialogueBalloon_NoSpeaker
        _balloon.start(_dialogueSetPrologue, "Prologue7")
        await DialogueSystem.onDialogueEnded
        UITree.PopWidgetFromLayer(_balloon, UITree.layerGameUI)

        p3CookSystem.onCookSequenceStarted.connect(func unfocus():
            _phase3Cookbook.get_viewport().gui_release_focus())
        p3CookSystem.set_can_start(true)
        p3CookSystem.start_cook()
        _phase3CookingUIInstance = p3CookSystem.get_cookingUI()
        var cons: Array = p3CookSystem.onCookSequenceCompleted.get_connections()
        for i in cons:
            p3CookSystem.onCookSequenceCompleted.disconnect(i["callable"])

        var results = await p3CookSystem.onCookSequenceCompleted
        await _on_tutorial_QTE_completed(results[0], results[1])


        await get_tree().create_timer(1.0, false).timeout
        DialogueSystem.spawn_dialogue_additive(_dialogueSetPrologue, "Prologue8", UITree.layerPrompt)
        await DialogueSystem.onDialogueEnded
        await get_tree().create_timer(0.3, false).timeout
        _ratingPromptInstance.set_process_input(true)
        _ratingPromptInstance.mouse_filter = Control.MOUSE_FILTER_STOP
        await _ratingPromptInstance.onDeactivated



        var foods = AssetManager.load_asset_of_ids(_availableRecipes)
        var allNeededIngredients: Dictionary = {}
        for i in foods:
            var foodData: FoodData = i.get_ref()
            var ingredients: Dictionary = foodData.ingredients
            for j in ingredients:
                var amount: int = ingredients[j]
                if allNeededIngredients.has(j):
                    allNeededIngredients[j] += amount
                else:
                    allNeededIngredients[j] = amount

        InventorySystem.bulk_add_ingredient_count(allNeededIngredients)


        for i in entries:
            var btn: = i as UI_Phase3_Cookbook_Entry
            btn.focus_mode = Control.FOCUS_ALL
            btn.set_active(_availableRecipes.has(btn.get_food_data().resource_name))

        UITree.PopWidgetFromLayer(cutout, UITree.layerGame)

        _balloon = UITree.AdditivePushWidgetToLayer(_dialogueNoSpeaker, UITree.layerGameUI) as UI_DialogueBalloon_NoSpeaker
        await get_tree().process_frame
        halfXSize = viewportSize * Vector2(0.5, 1.0)
        _balloon.size = halfXSize
        _balloon.start(_dialogueSetPrologue, "Prologue9")
        cookBtn.disabled = true
        for entry in entries:
            var notLearned: bool = not FoodLibrary.is_food_learned(entry.get_food_data().resource_name)
            if notLearned:
                entry.grab_focus()
                break
        _balloon.set_enable_user_input(false)

        p3CookSystem.onCookSequenceCompleted.connect(_on_all_available_recipes_QTE_completed)
        await allAvailableRecipesLearned


        UITree.PopWidgetFromLayer(_balloon, UITree.layerGameUI)
        DialogueSystem.spawn_dialogue_additive(_dialogueSetPrologue, "Prologue10")
        await DialogueSystem.onDialogueEnded
        _phase3Cookbook.on_back()
        InputManager.set_game_input_enabled(false)
        await _phase3Cookbook.get_anim_player().animation_finished


        await UITree.fade_to_black()

        pass

    func _on_all_available_recipes_QTE_completed(cookedFoodWeakRef: WeakRef, successRate):
        var cookedFood: FoodData = cookedFoodWeakRef.get_ref()
        var current_unix_time = Time.get_unix_time_from_system()
        var completion_date = Time.get_datetime_string_from_unix_time(current_unix_time, true)
        var stars: int = ceili(successRate * 3.0)
        GameplayVariables.add_learned_recipe(cookedFood.resource_name, completion_date, stars)

        var phase3CookingUI = GameInstance.gameWorld.phase3CookSystem.get_cookingUI()
        await get_tree().create_timer(0.5, false).timeout
        if phase3CookingUI.get_ref():
            await phase3CookingUI.get_ref().play_cook_animation()
            pass

        _ratingPromptInstance = UITree.PushWidgetToLayer(_ratingPrompt, UITree.layerPrompt) as UI_RatingPrompt
        _ratingPromptInstance.onDeactivated.connect(
        func remove_cooking_UI():
            if not phase3CookingUI.get_ref():
                return

            var cookingUI = phase3CookingUI.get_ref() as UI_Phase3_CookingUI
            UITree.PopWidgetFromLayer(cookingUI, UITree.layerGameUI)
        )
        _ratingPromptInstance.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _ratingPromptInstance.set_process_input(false)
        _ratingPromptInstance.setup_rating_prompt(cookedFoodWeakRef, stars, Callable(), true)
        await _ratingPromptInstance.get_anim_player().animation_finished

        _ratingPromptInstance.mouse_filter = Control.MOUSE_FILTER_STOP
        _ratingPromptInstance.set_process_input(true)
        await _ratingPromptInstance.onDeactivated

        _phase3Cookbook.get_cook_button().disabled = true
        var newFocus = null
        for i in _phase3Cookbook.get_cookbook_entries():
            var btn: = i as UI_Phase3_Cookbook_Entry
            var notLearned: bool = not FoodLibrary.is_food_learned(btn.get_food_data().resource_name)
            btn.set_active(notLearned)

            if not is_instance_valid(newFocus) and notLearned:
                newFocus = btn
            pass

        if is_instance_valid(newFocus):
            newFocus.grab_focus()

        if _availableRecipes.has(cookedFood.resource_name):
            var i = _availableRecipes.find(cookedFood.resource_name)
            _availableRecipes.remove_at(i)

        if _availableRecipes.is_empty():
            allAvailableRecipesLearned.emit()
        pass

    func _on_tutorial_QTE_completed(cookedFood: WeakRef, successRate: float):
        var cookedFoodData: FoodData = cookedFood.get_ref()
        var current_unix_time = Time.get_unix_time_from_system()
        var completion_date = Time.get_datetime_string_from_unix_time(current_unix_time, true)
        var stars: int = ceili(successRate * 3.0)
        GameplayVariables.add_learned_recipe(cookedFoodData.resource_name, completion_date, stars)
        CampaignSystem.contextString = str(stars)

        await get_tree().create_timer(0.5, false).timeout
        if _phase3CookingUIInstance.get_ref():
            await _phase3CookingUIInstance.get_ref().play_cook_animation()
            pass

        _ratingPromptInstance = UITree.PushWidgetToLayer(_ratingPrompt, UITree.layerPrompt) as UI_RatingPrompt
        _ratingPromptInstance.onDeactivated.connect(
        func remove_cooking_UI():
            if not _phase3CookingUIInstance.get_ref():
                return

            var cookingUI = _phase3CookingUIInstance.get_ref() as UI_Phase3_CookingUI
            UITree.PopWidgetFromLayer(cookingUI, UITree.layerGameUI))
        _ratingPromptInstance.set_process_input(false)
        _ratingPromptInstance.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _ratingPromptInstance.setup_rating_prompt(cookedFood, stars, Callable(), true)
        await _ratingPromptInstance.get_anim_player().animation_finished
        pass

class Phase2TutorialHandler_2 extends Node:
    var _dialogueNoSpeaker: PackedScene = preload("res://Scenes/UIs/Dialogue/UI_DialogueBalloon_NoSpeaker.tscn")
    var _blackScreenCutout: PackedScene = preload("res://Scenes/UIs/Misc/UI_BlackScreenCutout.tscn")
    var _dialogueSetPrologue: DialogueSet = preload("res://Resources/DialogueSet/Prologue/DialogueSet_Prologue.tres")

    var _owner: PrologueOrchestrator
    var _nextLineID: String = ""

    signal on_phase2Cookbook_pushed()


    func _init(orc: PrologueOrchestrator):
        process_mode = Node.PROCESS_MODE_ALWAYS
        _owner = orc
        pass

    func start():
        InputManager.set_game_input_enabled(false)
        DialogueSystem.spawn_dialogue_additive(_dialogueSetPrologue, "Prologue16")
        await DialogueSystem.onDialogueEnded
        InputManager.set_game_input_enabled(true)







        var cookingStation = get_tree().get_first_node_in_group("Buildable.CookingStation")
        var cutout = UITree.AdditivePushWidgetToLayer(_blackScreenCutout, UITree.layerGame) as UI_BlackScreenCutout
        cutout.emphasize([cookingStation.get_sprite()])
        DialogueManager.got_dialogue.connect(_get_next_line_id)
        var balloon = UITree.PushWidgetToLayer(_dialogueNoSpeaker, UITree.layerPrompt) as UI_DialogueBalloon_NoSpeaker
        balloon.set_enable_user_input(false)
        balloon.start(_dialogueSetPrologue, "Prologue17")
        UITree.onWidgetPushed.connect(_phase2Cookbook_push)

        var results = await on_phase2Cookbook_pushed
        balloon.next(_nextLineID)
        var phase2Cookbook: UI_Phase2_Cookbook = results[0] as UI_Phase2_Cookbook
        await get_tree().process_frame
        var viewportRect: Rect2 = phase2Cookbook.get_viewport_rect()
        var viewportSize: Vector2 = viewportRect.size
        var halfXSize: Vector2 = viewportSize * Vector2(0.5, 1.0)
        balloon.create_tween().tween_property(balloon, "size", halfXSize, 0.2)
        var entries = phase2Cookbook.get_cookbook_entries()
        var kuihLapisBtn: UI_Phase2_Cookbook_Entry
        for i in entries:
            var btn: = i as UI_Phase2_Cookbook_Entry
            if btn.get_food_data().resource_name == FoodLibrary.KuihLapis:
                kuihLapisBtn = i
            else:
                btn.get_button().disabled = true
        UITree.PopWidgetFromLayer(cutout, UITree.layerGame)
        await get_tree().process_frame

        cutout = UITree.AdditivePushWidgetToLayer(_blackScreenCutout, UITree.layerGameUI) as UI_BlackScreenCutout
        cutout.emphasize([kuihLapisBtn])
        kuihLapisBtn.get_button().grab_focus()
        await kuihLapisBtn.get_button().pressed
        await get_tree().process_frame

        var tree: SceneTree = get_tree()
        var interactionSystem = tree.get_first_node_in_group("Tutorial_InteractionSystem") as InteractionSystem
        var selectedCookingStation: Buildable_CookingStation1 = phase2Cookbook.cookingStation
        interactionSystem.add_limited_interactable_item(selectedCookingStation)
        var rightPage: Control = phase2Cookbook.get_right_page()
        cutout.emphasize([rightPage])

        await phase2Cookbook.get_cook_button().pressed
        cutout.hide()
        balloon.create_tween().tween_property(balloon, "size", viewportSize, 0.2)
        balloon.next(_nextLineID)

        var mc = PlayerCharacter.player
        var cookTimerRef = await selectedCookingStation.get_cook_timer()
        var cookTimer: = cookTimerRef.get_ref() as CookTimer
        await cookTimer.onCookTimeUp
        InputManager.set_game_input_enabled(false)
        DialogueManager.got_dialogue.disconnect(_get_next_line_id)
        UITree.PopWidgetFromLayer(balloon, UITree.layerPrompt)
        cutout.hide()

        await get_tree().create_timer(0.1, false).timeout
        DialogueSystem.spawn_dialogue_additive(_dialogueSetPrologue, "Prologue18")
        await DialogueSystem.onDialogueEnded
        InputManager.set_game_input_enabled(true)

        DialogueManager.got_dialogue.connect(_get_next_line_id)
        balloon = UITree.PushWidgetToLayer(_dialogueNoSpeaker, UITree.layerPrompt) as UI_DialogueBalloon_NoSpeaker
        balloon.set_enable_user_input(false)
        balloon.start(_dialogueSetPrologue, "Prologue19")

        cutout.emphasize([selectedCookingStation.get_sprite()])
        cutout.show()
        await mc.interactionContext

        balloon.next(_nextLineID)
        var displayCounter = get_tree().get_first_node_in_group("Buildable.DisplayCounter") as Buildable_DisplayCounter1
        interactionSystem.clear_limited_interactable_items()
        interactionSystem.add_limited_interactable_item(displayCounter)
        cutout.emphasize([displayCounter.get_sprite()])






        await mc.interactionContext
        DialogueManager.got_dialogue.disconnect(_get_next_line_id)
        UITree.PopWidgetFromLayer(cutout, UITree.layerPrompt)
        balloon.hide()

        DialogueSystem.spawn_dialogue_additive(_dialogueSetPrologue, "Prologue20")
        InputManager.set_game_input_enabled(false)
        await DialogueSystem.onDialogueEnded
        InputManager.set_game_input_enabled(true)

        balloon.show()
        balloon.create_tween().tween_property(balloon, "size", halfXSize, 0.2)
        balloon.start(_dialogueSetPrologue, "Prologue21")
        interactionSystem.clear_limited_interactable_items()

        await mc.interactionContext
        await mc.interactionContext

        UITree.PopWidgetFromLayer(balloon, balloon.get_owning_layer_name())
        pass

    func _get_next_line_id(line: DialogueLine):
        _nextLineID = line.next_id
    pass

    func _phase2Cookbook_push(widget: UI_Widget, layerName: String):
        if not widget is UI_Phase2_Cookbook:
            return

        UITree.onWidgetPushed.disconnect(_phase2Cookbook_push)
        on_phase2Cookbook_pushed.emit(widget, layerName)
        pass

    func get_screen_rect_from_buildable(i: Node2D, size: float = 1, offset: Vector2 = Vector2(0, 0)) -> Rect2:
        var station: = i.get_sprite() as Sprite2D
        var maskRect: Rect2 = station.get_rect()

        maskRect.size *= size
        maskRect.position = i.get_global_transform_with_canvas().get_origin() - (maskRect.size * 0.5) + offset
        return maskRect
    pass
