class_name KooehConstant

const dayVarName: String = "Day"
const timeVarName: String = "Time"
const targetVarName: String = "Target"
const stateVarName: String = "State"
const campaignVarName: String = "Campaign"
const visitedCustomerVarName: String = "VisitedCustomer"
const servedCustomerVarName: String = "ServedCustomer"
const unlockedRecipeVarName: String = "UnlockedRecipe"
const learnedRecipeVarName: String = "LearnedRecipe"
const moneyVarName: String = "Money"
const wishVarName: String = "Wishes"
const restaurantLayoutVarName: String = "Layout"
const restaurantLevelVarName: String = "RestaurantLevel"
const cookedFoodVarName: String = "CookedFood"


const learnedDateVarName: String = "LearnedDate"
const learnedRatingVarName: String = "LearnedRating"

const Prologue: String = "Prologue"
const FirstEverCustomerVisit: String = "FirstEverCustomerVisit"
const FirstEverS1Customer: String = "FirstEverS-1Customer"

const AllDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

static func get_default_gameplay_variables():
    var defaultUnlockedRecipes: = PackedStringArray([
        FoodLibrary.KuihLapis, 
        FoodLibrary.OndehOndeh, 
        FoodLibrary.SirapLimau, 
    ])

    return {
        dayVarName: KooehConstant.Day.MONDAY, 
        timeVarName: 0, 
        campaignVarName: Dictionary(), 
        visitedCustomerVarName: Dictionary(), 
        servedCustomerVarName: Dictionary(), 
        unlockedRecipeVarName: defaultUnlockedRecipes, 
        learnedRecipeVarName: Dictionary(), 
        moneyVarName: 0.0, 
        wishVarName: 0, 
        restaurantLayoutVarName: Dictionary(), 
        restaurantLevelVarName: 0, 
        cookedFoodVarName: Dictionary()
    }

enum Day{
    MONDAY = 2 ** 0, 
    TUESDAY = 2 ** 1, 
    WEDNESDAY = 2 ** 2, 
    THURSDAY = 2 ** 3, 
    FRIDAY = 2 ** 4, 
    SATURDAY = 2 ** 5, 
    SUNDAY = 2 ** 6
}

enum ERebindAllowance{
    ALLOW, 
    KEYINVALID, 
    CONTROLTYPEINVALID
}

enum InputType{
    KEYBOARD_MOUSE, 
    CONTROLLER, 
    INVALID
}

enum FoodType{
    FOOD = 2 ** 0, 
    DRINK = 2 ** 1
}

enum Rarity{
    Common, 
    Uncommon, 
    Rare, 
    Special
}

enum Difficulty{
    Easy, 
    Normal, 
    Hard
}

enum CampaignStatus{
    PENDING = 2 ** 0, 
    INPROGRESS = 2 ** 1, 
    SUCCESS = 2 ** 2, 
    FAILED = 2 ** 3, 
}

const InputEventKeys: Dictionary = {
    KEY_ESCAPE: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_escape.png", 
    KEY_F1: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f1.png", 
    KEY_F2: "res://Art/Kenney Input Prompts//Keyboard & Mouse/Default/keyboard_f2.png", 
    KEY_F3: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f3.png", 
    KEY_F4: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f4.png", 
    KEY_F5: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f5.png", 
    KEY_F6: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f6.png", 
    KEY_F7: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f7.png", 
    KEY_F8: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f8.png", 
    KEY_F9: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f9.png", 
    KEY_F10: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f10.png", 
    KEY_F11: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f11.png", 
    KEY_F12: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f12.png", 

    KEY_1: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_1.png", 
    KEY_2: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_2.png", 
    KEY_3: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_3.png", 
    KEY_4: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_4.png", 
    KEY_5: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_5.png", 
    KEY_6: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_6.png", 
    KEY_7: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_7.png", 
    KEY_8: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_8.png", 
    KEY_9: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_9.png", 
    KEY_0: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_0.png", 
    KEY_MINUS: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_minus.png", 
    KEY_EQUAL: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_equals.png", 

    KEY_A: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_a.png", 
    KEY_B: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_b.png", 
    KEY_C: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_c.png", 
    KEY_D: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_d.png", 
    KEY_E: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_e.png", 
    KEY_F: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_f.png", 
    KEY_G: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_g.png", 
    KEY_H: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_h.png", 
    KEY_I: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_i.png", 
    KEY_J: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_j.png", 
    KEY_K: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_k.png", 
    KEY_L: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_l.png", 
    KEY_M: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_m.png", 
    KEY_N: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_n.png", 
    KEY_O: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_o.png", 
    KEY_P: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_p.png", 
    KEY_Q: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_q.png", 
    KEY_R: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_r.png", 
    KEY_S: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_s.png", 
    KEY_T: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_t.png", 
    KEY_U: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_u.png", 
    KEY_V: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_v.png", 
    KEY_W: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_w.png", 
    KEY_X: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_x.png", 
    KEY_Y: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_y.png", 
    KEY_Z: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_z.png", 

    KEY_TAB: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_tab_icon.png", 
    KEY_BRACKETLEFT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_bracket_open.png", 
    KEY_BRACKETRIGHT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_bracket_close.png", 
    KEY_BACKSLASH: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_slash_back.png", 
    KEY_CAPSLOCK: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_capslock_icon.png", 
    KEY_SEMICOLON: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_semicolon.png", 
    KEY_APOSTROPHE: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_apostrophe.png", 
    KEY_ENTER: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_enter.png", 
    KEY_SHIFT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_shift_icon.png", 
    KEY_COMMA: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_comma.png", 
    KEY_PERIOD: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_period.png", 
    KEY_SLASH: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_slash_forward.png", 
    KEY_CTRL: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_ctrl.png", 
    KEY_ALT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_alt.png", 
    KEY_SPACE: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_space_icon.png", 

    KEY_INSERT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_insert.png", 
    KEY_HOME: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_home.png", 
    KEY_PAGEUP: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_page_up.png", 
    KEY_DELETE: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_delete.png", 
    KEY_END: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_end.png", 
    KEY_PAGEDOWN: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_page_down.png", 

    KEY_UP: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_arrow_up.png", 
    KEY_DOWN: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_arrow_down.png", 
    KEY_LEFT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_arrow_left.png", 
    KEY_RIGHT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_arrow_right.png", 
}

const MouseButtonKeys: Dictionary = {
    MOUSE_BUTTON_LEFT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/mouse_left.png", 
    MOUSE_BUTTON_RIGHT: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/mouse_right.png", 
    MOUSE_BUTTON_MIDDLE: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/mouse_scroll.png", 
    MOUSE_BUTTON_WHEEL_UP: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/mouse_scroll_up.png", 
    MOUSE_BUTTON_WHEEL_DOWN: "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/mouse_scroll_down.png", 
}

const JoypadKeys: Dictionary = {
    JOY_BUTTON_A: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_button_a.png", 
    JOY_BUTTON_B: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_button_b.png", 
    JOY_BUTTON_X: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_button_x.png", 
    JOY_BUTTON_Y: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_button_y.png", 
    JOY_BUTTON_LEFT_SHOULDER: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_lb.png", 
    JOY_BUTTON_RIGHT_SHOULDER: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_rb.png", 
    JOY_BUTTON_LEFT_STICK: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_l_press.png", 
    JOY_BUTTON_RIGHT_STICK: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_r_press.png", 
    JOY_BUTTON_BACK: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_button_view.png", 
    JOY_BUTTON_START: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_button_menu.png", 
    JOY_BUTTON_DPAD_UP: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_dpad_up.png", 
    JOY_BUTTON_DPAD_DOWN: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_dpad_down.png", 
    JOY_BUTTON_DPAD_LEFT: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_dpad_left.png", 
    JOY_BUTTON_DPAD_RIGHT: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_dpad_right.png", 
}

static  var JoypadAxes: Dictionary = {
    "%s%s" % [JOY_AXIS_LEFT_X, 1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_l_right.png", 
    "%s%s" % [JOY_AXIS_LEFT_X, -1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_l_left.png", 
    "%s%s" % [JOY_AXIS_LEFT_Y, 1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_l_down.png", 
    "%s%s" % [JOY_AXIS_LEFT_Y, -1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_l_up.png", 
    "%s%s" % [JOY_AXIS_RIGHT_X, 1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_r_right.png", 
    "%s%s" % [JOY_AXIS_RIGHT_X, -1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_r_left.png", 
    "%s%s" % [JOY_AXIS_RIGHT_Y, 1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_r_down.png", 
    "%s%s" % [JOY_AXIS_RIGHT_Y, -1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_r_up.png", 
    "%s%s" % [JOY_AXIS_TRIGGER_LEFT, 1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_lt.png", 
    "%s%s" % [JOY_AXIS_TRIGGER_RIGHT, 1]: "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_rt.png", 
}

static  var MiscPCKeys: Dictionary = {
    "ui_dialogueAdvance": "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/keyboard_space_icon.png", 
    "ui_shake": "res://Art/Kenney Input Prompts/Keyboard & Mouse/Default/mouse.png", 
}

static  var MiscConsoleKeys: Dictionary = {
    "ui_dialogueAdvance": "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_button_a.png", 
    "ui_shake": "res://Art/Kenney Input Prompts/Xbox Series/Default/xbox_stick_l.png", 
}

static func resolve_input_texture(input) -> Texture:
    if input is Object:
        match input.get_class():
            "InputEventKey":
                return load(InputEventKeys[input.keycode])
            "InputEventMouseButton":
                return load(MouseButtonKeys[input.button_index])
            "InputEventJoypadButton":
                return load(JoypadKeys[input.button_index])
            "InputEventJoypadMotion":
                var key: String = "%s%s" % [input.axis, roundf(input.axis_value)]
                return load(JoypadAxes[key])

    elif input is String:
        if input.is_empty():
            return null

        if InputManager.get_input_type() == KooehConstant.InputType.KEYBOARD_MOUSE:
            return load(MiscPCKeys[input])
        elif InputManager.get_input_type() == KooehConstant.InputType.CONTROLLER:
            return load(MiscConsoleKeys[input])
    return null

const ACH_START_NEW_GAME: StringName = &"ACH_0001"
const ACH_COMPLETE_GAME_ONCE: StringName = &"ACH_0002"
const ACH_FOOD_3STAR_ONCE: StringName = &"ACH_0004"
const ACH_FOOD_3STAR_ALL: StringName = &"ACH_0005"
const ACH_RECIPE_UNLOCK_ALL: StringName = &"ACH_0006"
const ACH_FOOD_TYPE_COOK_ALL: StringName = &"ACH_0007"
const ACH_CUST_SERVE_ONCE: StringName = &"ACH_0008"
const ACH_CUST_SERVE_10: StringName = &"ACH_0009"
const ACH_CUST_SERVE_20: StringName = &"ACH_0010"
const ACH_CUST_SERVE_50: StringName = &"ACH_0011"
const ACH_CUST_SERVE_100: StringName = &"ACH_0012"
const ACH_CUST_TYPE_SERVE_ALL: StringName = &"ACH_0013"
const ACH_FOOD_COOK_ONCE: StringName = &"ACH_0014"
const ACH_FOOD_COOK_10: StringName = &"ACH_0015"
const ACH_FOOD_COOK_50: StringName = &"ACH_0016"
const ACH_FOOD_COOK_100: StringName = &"ACH_0017"
const ACH_FOOD_COOK_200: StringName = &"ACH_0018"
const ACH_WISH_ONCE: StringName = &"ACH_0019"
const ACH_WISH_5: StringName = &"ACH_0020"
const ACH_WISH_10: StringName = &"ACH_0021"
const ACH_WISH_50: StringName = &"ACH_0022"
const ACH_SNPC_MET_ALL: StringName = &"ACH_0023"
const ACH_TIGER_STORY: StringName = &"ACH_0024"
const ACH_SUNBEAR_STORY: StringName = &"ACH_0025"
const ACH_HORNBILL_STORY: StringName = &"ACH_0026"
const ACH_ELEPHANT_STORY: StringName = &"ACH_0027"
const ACH_CROC_STORY: StringName = &"ACH_0028"
const ACH_SHOP_EXP_1: StringName = &"ACH_0029"
const ACH_SHOP_EXP_2: StringName = &"ACH_0030"
const ACH_SHOP_UPGRADE_ALL: StringName = &"ACH_0031"

const STAT_FOOD_3_STAR: StringName = &"STAT_FOOD_3_STAR"
const STAT_RECIPE_UNLOCKED: StringName = &"STAT_RECIPE_UNLOCKED"
const STAT_CUSTOMER_SERVED: StringName = &"STAT_CUSTOMER_SERVED"
const STAT_FOOD_COOKED: StringName = &"STAT_FOOD_COOKED"
const STAT_WISHES: StringName = &"STAT_WISHES"
const STAT_FOOD_TYPE_COOKED: StringName = &"STAT_FOOD_TYPE_COOKED"
const STAT_CUSTOMER_TYPE_SERVED: StringName = &"STAT_CUSTOMER_TYPE_SERVED"
const STAT_SNPC_MET: StringName = &"STAT_SNPC_MET"
const STAT_RESTAURANT_LEVEL: StringName = &"STAT_RESTAURANT_LEVEL"
