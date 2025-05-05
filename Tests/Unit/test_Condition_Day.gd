extends GutTest

func test_customer_spawn_condition_day_on_specific_day():
    var mockVars: Dictionary = {}
    mockVars[KooehConstant.dayVarName] = KooehConstant.Day.MONDAY
    var dayTrigger: = Condition_Day.new()
    dayTrigger.fromDay = KooehConstant.Day.MONDAY
    dayTrigger.toDay = KooehConstant.Day.MONDAY

    assert_true(dayTrigger.query(mockVars) as bool, "Monday match Monday should pass")


    dayTrigger.fromDay = KooehConstant.Day.TUESDAY
    dayTrigger.toDay = KooehConstant.Day.TUESDAY
    assert_false(dayTrigger.query(mockVars) as bool, "Monday match Tuesday shouldn't pass")
    pass

func test_customer_spawn_condition_day_day_range():
    var mockVars: Dictionary = {}
    mockVars[KooehConstant.dayVarName] = KooehConstant.Day.MONDAY
    var dayTrigger: = Condition_Day.new()
    dayTrigger.fromDay = KooehConstant.Day.MONDAY
    dayTrigger.toDay = KooehConstant.Day.FRIDAY

    assert_true(dayTrigger.query(mockVars) as bool, "Monday should match within Monday-Friday range.")


    mockVars[KooehConstant.dayVarName] = KooehConstant.Day.SUNDAY
    assert_false(dayTrigger.query(mockVars) as bool, "Sunday shouldn't match within Monday-Friday range.")
    pass
