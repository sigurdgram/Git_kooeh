



























const ARG_NOT_SET = "_*_argument_*_is_*_not_set_*_"
























var _watched_signals = {}
var _utils = load("res://addons/gut/utils.gd").get_instance()
var _lgr = _utils.get_logger()

func _add_watched_signal(obj, name):

    if (_watched_signals.has(obj) and _watched_signals[obj].has(name)):
        return

    if ( !_watched_signals.has(obj)):
        _watched_signals[obj] = {name: []}
    else:
        _watched_signals[obj][name] = []
    obj.connect(name, Callable(self, "_on_watched_signal").bind(obj, name))










func _on_watched_signal(arg1 = ARG_NOT_SET, arg2 = ARG_NOT_SET, arg3 = ARG_NOT_SET, \
arg4 = ARG_NOT_SET, arg5 = ARG_NOT_SET, arg6 = ARG_NOT_SET, \
arg7 = ARG_NOT_SET, arg8 = ARG_NOT_SET, arg9 = ARG_NOT_SET, \
arg10 = ARG_NOT_SET, arg11 = ARG_NOT_SET):
    var args = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11]


    var idx = args.size() - 1
    while (str(args[idx]) == ARG_NOT_SET):
        args.remove_at(idx)
        idx -= 1



    var signal_name = args[args.size() - 1]
    args.pop_back()
    var object = args[args.size() - 1]
    args.pop_back()

    if (_watched_signals.has(object)):
        _watched_signals[object][signal_name].append(args)
    else:
        _lgr.error(str("signal_watcher._on_watched_signal:  Got signal for unwatched object:  ", object, "::", signal_name))



func _obj_name_pair(obj_or_signal, signal_name = null):
    var to_return = {
        "object": obj_or_signal, 
        "signal_name": signal_name
    }
    if (obj_or_signal is Signal):
        to_return.object = obj_or_signal.get_object()
        to_return.signal_name = obj_or_signal.get_name()

    return to_return


func does_object_have_signal(object, signal_name):
    var signals = object.get_signal_list()
    for i in range(signals.size()):
        if (signals[i]["name"] == signal_name):
            return true
    return false

func watch_signals(object):
    var signals = object.get_signal_list()
    for i in range(signals.size()):
        _add_watched_signal(object, signals[i]["name"])

func watch_signal(object, signal_name):
    var did = false
    if (does_object_have_signal(object, signal_name)):
        _add_watched_signal(object, signal_name)
        did = true
    else:
        _utils.get_logger().warn(str(object, " does not have signal ", signal_name))
    return did

func get_emit_count(object, signal_name):
    var to_return = -1
    if (is_watching(object, signal_name)):
        to_return = _watched_signals[object][signal_name].size()
    return to_return

func did_emit(object, signal_name = null):
    var vals = _obj_name_pair(object, signal_name)
    var did = false
    if (is_watching(vals.object, vals.signal_name)):
        did = get_emit_count(vals.object, vals.signal_name) != 0
    return did

func print_object_signals(object):
    var list = object.get_signal_list()
    for i in range(list.size()):
        print(list[i].name, "\n  ", list[i])

func get_signal_parameters(object, signal_name, index = -1):
    var params = null
    if (is_watching(object, signal_name)):
        var all_params = _watched_signals[object][signal_name]
        if (all_params.size() > 0):
            if (index == -1):
                index = all_params.size() - 1
            params = all_params[index]
    return params

func is_watching_object(object):
    return _watched_signals.has(object)

func is_watching(object, signal_name):
    return _watched_signals.has(object) and _watched_signals[object].has(signal_name)

func clear():
    for obj in _watched_signals:
        if (_utils.is_not_freed(obj)):
            for signal_name in _watched_signals[obj]:
                obj.disconnect(signal_name, Callable(self, "_on_watched_signal"))
    _watched_signals.clear()



func get_signals_emitted(obj):
    var emitted = []
    if (is_watching_object(obj)):
        for signal_name in _watched_signals[obj]:
            if (_watched_signals[obj][signal_name].size() > 0):
                emitted.append(signal_name)

    return emitted
