extends GutTest

func test_condition_time_in_between():

    var mockCurrentTime = Time.get_unix_time_from_datetime_string("10:00:00")
    var variables = {
        KooehConstant.timeVarName: mockCurrentTime
    }

    var timeCond: = Condition_Time.new()
    timeCond.fromTime = "09:00:00"
    timeCond.toTime = "11:00:00"

    assert_eq(timeCond.query(variables), 1, "10AM should pass in between 9AM - 11AM")
    pass

func test_condition_time_specific_time():

    var mockCurrentTime = Time.get_unix_time_from_datetime_string("12:15:00")
    var variables = {
        KooehConstant.timeVarName: mockCurrentTime
    }

    var timeCond: = Condition_Time.new()
    timeCond.fromTime = "12:15:00"
    timeCond.toTime = "12:15:00"

    assert_eq(timeCond.query(variables), 1, "12:15PM should pass")
    pass
