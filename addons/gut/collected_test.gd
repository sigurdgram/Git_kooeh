



var name = ""


var has_printed_name = false


var arg_count = 0




var assert_count = 0:
    get: return pass_texts.size() + fail_texts.size()
    set(val): pass



var pending = false:
    get: return is_pending()
    set(val): pass


var line_number = -1



var should_skip = false

var pass_texts = []
var fail_texts = []
var pending_texts = []
var orphans = 0

var was_run = false


func did_pass():
    return is_passing()


func add_fail(fail_text):
    fail_texts.append(fail_text)


func add_pending(pending_text):
    pending_texts.append(pending_text)


func add_pass(passing_text):
    pass_texts.append(passing_text)



func is_passing():
    return pass_texts.size() > 0 and fail_texts.size() == 0 and pending_texts.size() == 0




func is_failing():
    return fail_texts.size() > 0



func is_pending():
    return pending_texts.size() > 0 and fail_texts.size() == 0


func is_risky():
    return should_skip or (was_run and !did_something())


func did_something():
    return is_passing() or is_failing() or is_pending()


func get_status_text():
    var to_return = GutUtils.TEST_STATUSES.NO_ASSERTS

    if (should_skip):
        to_return = GutUtils.TEST_STATUSES.SKIPPED
    elif ( !was_run):
        to_return = GutUtils.TEST_STATUSES.NOT_RUN
    elif (pending_texts.size() > 0):
        to_return = GutUtils.TEST_STATUSES.PENDING
    elif (fail_texts.size() > 0):
        to_return = GutUtils.TEST_STATUSES.FAILED
    elif (pass_texts.size() > 0):
        to_return = GutUtils.TEST_STATUSES.PASSED

    return to_return



func get_status():
    return get_status_text()


func to_s():
    var pad = "     "
    var to_return = str(name, "[", get_status_text(), "]\n")

    for i in range(fail_texts.size()):
        to_return += str(pad, "Fail:  ", fail_texts[i])
    for i in range(pending_texts.size()):
        to_return += str(pad, "Pending:  ", pending_texts[i], "\n")
    for i in range(pass_texts.size()):
        to_return += str(pad, "Pass:  ", pass_texts[i], "\n")
    return to_return
