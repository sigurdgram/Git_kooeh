
































var _counters = {}

func orphan_count():
    return Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)

func add_counter(name):
    _counters[name] = orphan_count()




func get_counter(name):
    return orphan_count() - _counters[name] if _counters.has(name) else -1

func print_orphans(name, lgr):
    var count = get_counter(name)

    if (count > 0):
        var o = "orphan"
        if (count > 1):
            o = "orphans"
        lgr.orphan(str(count, " new ", o, " in ", name, "."))
