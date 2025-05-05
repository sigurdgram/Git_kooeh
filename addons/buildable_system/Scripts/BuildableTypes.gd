extends RefCounted
class_name BuildableTypes

enum EBuildableLayer{
    Terrain = 0, 
    Floor = 1, 
    Asset = 2
}

enum EBuildableMask{
    Terrain = 2 ** 5, 
    Floor = 2 ** 6, 
    Asset = 2 ** 7
}

enum ECheckTime{
    OnBuild = 2 ** 0, 
    OnTargetPosChanged = 2 ** 1
}

enum EBuildableNotification{
    RebuildSeats = 20000, 
}


enum EDirection{
    North, 
    NorthEast, 
    East, 
    SouthEast, 
    South, 
    SouthWest, 
    West, 
    NorthWest
}

const Meta_ID: StringName = &"id"
const Meta_Direction: StringName = &"direction"
const Meta_MapPos: StringName = &"mapPos"
const Meta_Info: StringName = &"info"
const Meta_Level: StringName = &"level"
const Meta_Slots: StringName = &"AttachmentSlots"
const Meta_SpawnPoint: StringName = &"Spawnpoint"
const Meta_Entrance: StringName = &"Entrance"

const BuildMode_None: StringName = &""
const BuildMode_Build: StringName = &"Build"
const BuildMode_Move: StringName = &"Move"
const BuildMode_Delete: StringName = &"Delete"

const BuildConfig_GridData: StringName = &"GridData"
const BuildConfig_UpgradeBundle: StringName = &"UpgradeBundle"
const BuildConfig_RestaurantLevel: StringName = &"RestaurantLevel"
const BuildConfig_Upgrade: StringName = &"Upgrade"

const Upgrade_Subject: StringName = &"Subject"
const Upgrade_Change: StringName = &"Change"
const Upgrade_Desc: StringName = &"Desc"

enum EBuildableError{
    OK = 0, 
    NoMoney = 1 << 0, 
    MaxLevel = 1 << 2, 
    TileBlocked = 1 << 3
}

static func direction_to_vec2(direction: EDirection) -> Vector2:
    var ret: = Vector2(1, -1)
    var qRad: float = deg_to_rad(45.0) * direction

    return ret.rotated(qRad).snapped(Vector2.ONE)
