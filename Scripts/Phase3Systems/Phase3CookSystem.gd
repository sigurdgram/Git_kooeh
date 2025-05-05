extends Node
class_name Phase3CookSystem

@export var _audioQTEComplete: AudioStream
@export var assetTypeToLoad: String = "FoodData"

@export_category("PackedScenes")
@export var qteBar_Drag: PackedScene
@export var qteBar_Hori_TapInRange: PackedScene
@export var qteBar_Radial_TapInRange: PackedScene
@export var qteBar_Shake: PackedScene
@export var qteBar_HoldToRange: PackedScene
@export var qteBar_Stir: PackedScene
@export var qteBar_Steam: PackedScene
@export var qteBar_Pour: PackedScene
@export var _phase3CookingUI: PackedScene
@export var _learnedRecipePrompt: PackedScene
@export var _countdownUI: PackedScene

var _currentCookQTE: CookQTE

signal onEnterCookQTE(cookInstruction: CookInstruction, qteBar: Control)
signal onExitCookQTE(interrupted: bool)
signal onCookQTEComplete(score: float)
signal onCookSequenceStarted()
signal onCookSequenceCompleted(cookedFood: WeakRef, successRate: float)
signal onSessionTimeLimitUpdated(time: float)

var _foodData: WeakRef
var cookSequence: Array[CookQTE]
var _phase3CookingUIInstance: WeakRef
var _isStarted: bool = true
var _points: Array[float]


func get_cookingUI() -> WeakRef:
    return _phase3CookingUIInstance

func _ready():
    onExitCookQTE.connect(try_advance_to_next_qte)
    onCookSequenceCompleted.connect(_on_cook_sequence_completed)
    onCookQTEComplete.connect(_on_cook_qte_complete)
    pass

func setup(foodData: WeakRef):
    _foodData = foodData

    for child in get_children():
        child.queue_free()

    _phase3CookingUIInstance = weakref(UITree.PushWidgetToLayer(_phase3CookingUI, UITree.layerGameUI))
    _phase3CookingUIInstance.get_ref().setup(_foodData, self)

    _points.clear()

    for i in _foodData.get_ref().cookInstructions:
        var qteData = i.qteData

        var cookQTE: CookQTE = null
        if qteData is QTEData_Radial:
            cookQTE = CookQTE_Circular.new(i, self)
        elif qteData is QTEData_Hori:
            cookQTE = CookQTE_Hori.new(i, self)
        elif qteData is QTEData_Shake:
            cookQTE = CookQTE_Shake.new(i, self)
        elif qteData is QTEData_HoldToRange:
            cookQTE = CookQTE_HoldToRange.new(i, self)
        elif qteData is QTEData_Stir:
            cookQTE = CookQTE_Stir.new(i, self)
        elif qteData is QTEData_Steam:
            cookQTE = CookQTE_Steam.new(i, self)
        elif qteData is QTEData_Pour:
            cookQTE = CookQTE_Pour.new(i, self)
        else:
            assert (false)

        if is_instance_valid(cookQTE):
            add_child(cookQTE)
            cookSequence.push_back(cookQTE)
    pass

func set_can_start(canStart: bool):
    _isStarted = canStart
    pass

func start_cook():
    if not _isStarted:
        return

    await get_tree().create_timer(0.5, false).timeout
    var countdown: = UITree.AdditivePushWidgetToLayer(_countdownUI, UITree.layerGameUI) as UI_Countdown
    countdown.setup(["Ready", "GO!"], true)
    await countdown.onEnd
    UITree.PopWidgetFromLayer(countdown, UITree.layerPrompt)

    _currentCookQTE = get_child(0)
    cookSequence.pop_front()
    onCookSequenceStarted.emit()
    _currentCookQTE.ready()
    pass

func stop():
    for i in get_children():
        i.exit(true)

    _currentCookQTE = null
    pass

func _process(delta):
    if is_instance_valid(_currentCookQTE):
        _currentCookQTE.process(delta)
    pass

func interact():
    if not is_instance_valid(_currentCookQTE):
        return

    if _currentCookQTE.has_method("interact"):
        _currentCookQTE.interact()
    pass

func _use_ingredient():
    var ingredients: Dictionary = _foodData.get_ref().ingredients
    for i in ingredients:
        var currentAmount: int = InventorySystem.get_ingredient_count(i)
        InventorySystem.set_ingredient_count(i, currentAmount - ingredients[i])
    pass

func try_advance_to_next_qte(interrupted: bool):
    if interrupted:
        _currentCookQTE.exit(true)
        return

    var nextQTE: CookQTE
    if get_child_count() > 1:
        nextQTE = get_child(1) as CookQTE

    if nextQTE:
        _currentCookQTE = nextQTE
        _currentCookQTE.ready()
    else:
        var totalPoints: float = 0.0
        for i in _points:
            totalPoints += i

        var rating: float = totalPoints / _points.size()
        onCookSequenceCompleted.emit(_foodData, rating)
        AudioSystem.play_sfx(_audioQTEComplete)
    pass

func _on_cook_qte_complete(score: float) -> void :
    _points.push_back(score)
    pass

func _on_cook_sequence_completed(cookedFoodWeakRef: WeakRef, successRate: float):
    _use_ingredient()

    var cookedFood: FoodData = cookedFoodWeakRef.get_ref()
    var current_unix_time = Time.get_unix_time_from_system()
    var completion_date = Time.get_datetime_string_from_unix_time(current_unix_time, true)
    var stars: int = ceili(successRate * 3.0)
    if stars > 0:
        GameplayVariables.add_learned_recipe(cookedFood.resource_name, completion_date, stars)

    await get_tree().create_timer(0.5, false).timeout
    if _phase3CookingUIInstance.get_ref():
        await _phase3CookingUIInstance.get_ref().play_cook_animation()
        pass

    var prompt = UITree.PushWidgetToLayer(_learnedRecipePrompt, UITree.layerPrompt) as UI_RatingPrompt
    prompt.onDeactivated.connect(
        func remove_cooking_UI():
            if not _phase3CookingUIInstance.get_ref():
                return

            var cookingUI = _phase3CookingUIInstance.get_ref() as UI_Phase3_CookingUI
            if not cookingUI.get_is_interrupted():
                UITree.PopWidgetFromLayer(cookingUI, UITree.layerGameUI))
    prompt.setup_rating_prompt(cookedFoodWeakRef, stars, Callable())
    pass

class CookQTE extends Node:
    var _phase3CookSystem: Phase3CookSystem
    var _cookInstruction: CookInstruction
    var _sessionTimeLimit: float
    var _executionLimit: int
    var _qteBar: Control
    var _timer: Timer


    func _init(cookInstruction: CookInstruction, phase3CookSystem: Phase3CookSystem):
        _sessionTimeLimit = cookInstruction.qteTimeLimit
        _executionLimit = cookInstruction.qteData.get_execution_limit()

        _cookInstruction = cookInstruction
        _phase3CookSystem = phase3CookSystem
        _timer = Timer.new()
        _timer.timeout.connect(_update_session_time)
        add_child(_timer)
        pass

    func ready():
        if _sessionTimeLimit > 0.0:
            _timer.start(1.0)
        pass

    func _update_session_time():
        _sessionTimeLimit -= 1.0
        _phase3CookSystem.onSessionTimeLimitUpdated.emit(_sessionTimeLimit)
        if _sessionTimeLimit <= 0.0:
            _timer.stop()
            _phase3CookSystem.onCookQTEComplete.emit(0.0)
            exit()
        pass

    func process(_delta: float):
        pass

    func exit(interrupted: bool = false):
        set_process_input(false)

        if is_instance_valid(_qteBar):
            _qteBar.set_process(false)

        _phase3CookSystem.cookSequence.pop_front()

        if interrupted:
            queue_free()
            return

        await get_tree().create_timer(1.0, false).timeout
        _phase3CookSystem.onExitCookQTE.emit(interrupted)
        queue_free()
        pass
    pass

class CookQTE_Circular extends CookQTE:
    var _isPassed: bool = true


    func ready():
        _qteBar = _phase3CookSystem.qteBar_Radial_TapInRange.instantiate() as QTEBar_Radial_TapInRange
        _qteBar.onBroadcastResult.connect(_update_execution_limit)
        _qteBar.setup(_cookInstruction.qteData, false)
        _phase3CookSystem.onEnterCookQTE.emit(_cookInstruction, _qteBar)
        _qteBar.start_QTE()
        super .ready()
        pass

    func interact():
        _qteBar.tap()

    func _update_execution_limit(passed: bool):
        if not passed:
            _isPassed = false
        elif passed:
            _executionLimit = max(_executionLimit - 1, 0)
            _phase3CookSystem.onCookQTEComplete.emit(1.0 if _isPassed else 0.0)
            exit()
        pass
    pass

class CookQTE_Hori extends CookQTE:
    var _isPassed: bool = true


    func ready():
        _qteBar = _phase3CookSystem.qteBar_Hori_TapInRange.instantiate() as QTEBar_Hori_TapInRange
        _qteBar.onBroadcastResult.connect(_update_execution_limit)
        _qteBar.setup(_cookInstruction.qteData, false)
        _phase3CookSystem.onEnterCookQTE.emit(_cookInstruction, _qteBar)
        _qteBar.start_QTE()
        super .ready()
        pass

    func interact():
        _qteBar.tap()
        pass

    func _update_execution_limit(passed: bool):
        if not passed:
            _isPassed = false
        elif passed:
            _phase3CookSystem.onCookQTEComplete.emit(1.0 if _isPassed else 0.0)
            exit()
        pass

class CookQTE_Steam extends CookQTE:
    var _scores: Array[float]


    func ready():
        _qteBar = _phase3CookSystem.qteBar_Steam.instantiate() as QTEBar_Steam
        _qteBar.onBroadcastResult.connect(_update_execution_limit)
        _qteBar.setup(_cookInstruction.qteData, false)
        _phase3CookSystem.onEnterCookQTE.emit(_cookInstruction, _qteBar)
        _qteBar.start_QTE()
        super .ready()
        pass

    func _update_execution_limit(passed: bool):
        _scores.push_back(1.0)

        if _scores.size() == _executionLimit:
            var totalScore: float = 0.0
            for i in _scores:
                totalScore += i

            var average: float = totalScore / _scores.size()
            _phase3CookSystem.onCookQTEComplete.emit(average)

            exit()
        pass
    pass

class CookQTE_Stir extends CookQTE:
    var success: int = 0


    func ready():
        _qteBar = _phase3CookSystem.qteBar_Stir.instantiate() as QTEBar_Stir
        _qteBar.onBroadcastResult.connect(_update_execution_limit)
        _qteBar.setup(_cookInstruction.qteData, false)
        _phase3CookSystem.onEnterCookQTE.emit(_cookInstruction, _qteBar)
        _qteBar.start_QTE()
        super .ready()
        pass

    func _update_execution_limit(passed: bool):
        success += 1
        if success == _executionLimit:
            _phase3CookSystem.onCookQTEComplete.emit(1.0)
            exit()
        pass

class CookQTE_Pour extends CookQTE:
    var _scores: Array[float]


    func ready():
        _qteBar = _phase3CookSystem.qteBar_Pour.instantiate() as QTEBar_Pour
        _qteBar.onBroadcastResult.connect(_update_execution_limit)
        _qteBar.setup(_cookInstruction.qteData, false)
        _phase3CookSystem.onEnterCookQTE.emit(_cookInstruction, _qteBar)

        await get_tree().create_timer(1.0, false).timeout

        _qteBar.start_QTE()
        super .ready()
        pass

    func _update_execution_limit(passed: bool):
        _scores.push_back(1.0 if passed else 0.0)
        if _executionLimit == _scores.size():
            var totalScore: float = 0.0
            for i in _scores:
                totalScore += i

            var average: float = totalScore / _scores.size()
            _phase3CookSystem.onCookQTEComplete.emit(average)
            exit()
    pass

class CookQTE_HoldToRange extends CookQTE:


    func ready():
        _qteBar = _phase3CookSystem.qteBar_HoldToRange.instantiate() as QTEBar_HoldToRange
        _qteBar.onBroadcastResult.connect(_update_execution_limit)
        _qteBar.setup(_cookInstruction.qteData, false)
        _phase3CookSystem.onEnterCookQTE.emit(_cookInstruction, _qteBar)
        _qteBar.start_QTE()
        super .ready()
        pass

    func _update_execution_limit(passed: bool):
        _phase3CookSystem.onCookQTEComplete.emit(1.0 if passed else 0.0)
        exit()
        pass

class CookQTE_Shake extends CookQTE:

    func ready():
        _qteBar = _phase3CookSystem.qteBar_Shake.instantiate() as QTEBar_Shake
        _qteBar.onBroadcastResult.connect(_update_execution_limit)
        _qteBar.setup(_cookInstruction.qteData, false)
        _phase3CookSystem.onEnterCookQTE.emit(_cookInstruction, _qteBar)
        _qteBar.start_QTE()
        super .ready()
        pass

    func _update_execution_limit(passed: bool):
        _phase3CookSystem.onCookQTEComplete.emit(1.0)
        exit()
        pass
    pass
