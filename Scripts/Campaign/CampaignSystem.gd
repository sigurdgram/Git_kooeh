extends Node

@export var debugCampaignEnabled: bool = true

var _campaignEvents: Dictionary = {}
var _activeEvents: Dictionary = {}
var contextString: String = ""


func is_campaign_enabled():
    return debugCampaignEnabled if OS.is_debug_build() else true

func init():
    if not is_campaign_enabled():
        return

    var found: Array[WeakRef] = AssetManager.load_assets_of_type("CampaignEvent")
    for i in found:
        var event = i.get_ref().new()
        var status = GameplayVariables.get_campaign_status(event.identifier)
        if status > KooehConstant.CampaignStatus.INPROGRESS:
            continue
        _campaignEvents[event.identifier] = event
        event.init()
    pass

func _ready():
    init()
    pass

func _process(delta):
    if not is_campaign_enabled():
        set_process(false)
        return

    var events: Array = _activeEvents.values()
    for i in events:
        if not is_instance_valid(i):
            continue

        if i.is_process_enabled():
            i.process(delta)
    pass

func get_event(identifier: String) -> CampaignEvent:
    return _campaignEvents[identifier] if _campaignEvents.has(identifier) else null

func get_event_status(identifier: String) -> KooehConstant.CampaignStatus:
    return GameplayVariables.get_campaign_status(identifier)

func is_event_executable(identifier: String) -> bool:
    var event: CampaignEvent = get_event(identifier)
    return event.is_event_executable() if is_instance_valid(event) else false

func set_event_active(identifier: String) -> bool:
    if not _campaignEvents.has(identifier):
        return false

    var event: CampaignEvent = _campaignEvents[identifier]
    if event.status == KooehConstant.CampaignStatus.PENDING:
        event.ready()
        _activeEvents[identifier] = event
        return true

    return false

func set_event_inactive(identifier: String) -> bool:
    if not _activeEvents.has(identifier):
        return false

    var activeEvent: CampaignEvent = _activeEvents[identifier]
    activeEvent.exit()

    _activeEvents.erase(activeEvent)
    if not activeEvent.retriggerable:
        _campaignEvents.erase(activeEvent.identifier)
    return true

func campaign_customer_spawn_override():
    for event in _campaignEvents.values():
        if not event is CampaignEvent_OverrideCustomerSpawn:
            continue

        var override: = event as CampaignEvent_OverrideCustomerSpawn
        if override.is_event_executable():
            return override.get_customer_to_spawn()
    return null
