class_name CampaignEvent

var identifier: String
var status: KooehConstant.CampaignStatus = KooehConstant.CampaignStatus.PENDING:
    set(value):
        status = value
        GameplayVariables.set_campaign_status(identifier, status)
        pass

var isProcessEnabled: bool = false
var retriggerable: bool = false

signal onEventEnded(endStatus: KooehConstant.CampaignStatus)

func is_event_executable() -> bool:
    return false

func is_process_enabled() -> bool:
    return isProcessEnabled && status == KooehConstant.CampaignStatus.INPROGRESS

func init():
    assert ( not identifier.is_empty())
    pass

func ready():
    status = KooehConstant.CampaignStatus.INPROGRESS
    pass

func process(_delta: float):
    pass

func exit():
    onEventEnded.emit(status)
    pass
