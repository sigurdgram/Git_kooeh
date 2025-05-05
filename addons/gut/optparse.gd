











































class CmdLineParser:
    var _used_options = []




    var _opts = []

    func _init():
        for i in range(OS.get_cmdline_args().size()):
            var opt_val = OS.get_cmdline_args()[i].split("=")
            _opts.append(opt_val)




    func _parse_array_value(full_option):
        var value = _parse_option_value(full_option)
        var split = value.split(",")
        return split



    func _parse_option_value(full_option):
        if (full_option.size() > 1):
            return full_option[1]
        else:
            return null



    func find_option(name):
        var found = false
        var idx = 0

        while (idx < _opts.size() and !found):
            if (_opts[idx][0] == name):
                found = true
            else:
                idx += 1

        if (found):
            return idx
        else:
            return -1

    func get_array_value(option):
        _used_options.append(option)
        var to_return = []
        var opt_loc = find_option(option)
        if (opt_loc != -1):
            to_return = _parse_array_value(_opts[opt_loc])
            _opts.remove_at(opt_loc)

        return to_return




    func get_value(option):
        _used_options.append(option)
        var to_return = null
        var opt_loc = find_option(option)
        if (opt_loc != -1):
            to_return = _parse_option_value(_opts[opt_loc])
            _opts.remove_at(opt_loc)

        return to_return


    func was_specified(option):
        _used_options.append(option)
        return find_option(option) != -1






    func get_unused_options():
        var to_return = []
        for i in range(_opts.size()):
            to_return.append(_opts[i][0])

        var script_option = to_return.find("-s")
        if script_option == -1:
            script_option = to_return.find("--script")
        if script_option != -1:
            to_return.remove_at(script_option + 1)
            to_return.remove_at(script_option)

        while (_used_options.size() > 0):
            var index = to_return.find(_used_options[0].split("=")[0])
            if (index != -1):
                to_return.remove_at(index)
            _used_options.remove_at(0)

        return to_return




class Option:
    var value = null
    var option_name = ""
    var default = null
    var description = ""

    func _init(name, default_value, desc = ""):
        option_name = name
        default = default_value
        description = desc
        value = null

    func pad(to_pad, size, pad_with = " "):
        var to_return = to_pad
        for _i in range(to_pad.length(), size):
            to_return += pad_with

        return to_return

    func to_s(min_space = 0):
        var subbed_desc = description
        if (subbed_desc.find("[default]") != -1):
            subbed_desc = subbed_desc.replace("[default]", str(default))
        return pad(option_name, min_space) + subbed_desc






var options = []
var _opts = []
var _banner = ""

func add(name, default, desc):
    options.append(Option.new(name, default, desc))

func get_value(name):
    var found = false
    var idx = 0

    while (idx < options.size() and !found):
        if (options[idx].option_name == name):
            found = true
        else:
            idx += 1

    if (found):
        return options[idx].value
    else:
        print("COULD NOT FIND OPTION " + name)
        return null

func set_banner(banner):
    _banner = banner

func print_help():
    var longest = 0
    for i in range(options.size()):
        if (options[i].option_name.length() > longest):
            longest = options[i].option_name.length()

    print("---------------------------------------------------------")
    print(_banner)

    print("\nOptions\n-------")
    for i in range(options.size()):
        print("  " + options[i].to_s(longest + 2))
    print("---------------------------------------------------------")

func print_options():
    for i in range(options.size()):
        print(options[i].option_name + "=" + str(options[i].value))

func parse():
    var parser = CmdLineParser.new()

    for i in range(options.size()):
        var t = typeof(options[i].default)





        if (parser.was_specified(options[i].option_name)):
            if (t == TYPE_INT):
                options[i].value = int(parser.get_value(options[i].option_name))
            elif (t == TYPE_STRING):
                options[i].value = parser.get_value(options[i].option_name)
            elif (t == TYPE_ARRAY):
                options[i].value = parser.get_array_value(options[i].option_name)
            elif (t == TYPE_BOOL):
                options[i].value = parser.was_specified(options[i].option_name)
            elif (t == TYPE_FLOAT):
                options[i].value = parser.get_value(options[i].option_name)
            elif (t == TYPE_NIL):
                print(options[i].option_name + " cannot be processed, it has a nil datatype")
            else:
                print(options[i].option_name + " cannot be processed, it has unknown datatype:" + str(t))

    var unused = parser.get_unused_options()
    if (unused.size() > 0):
        print("Unrecognized options:  ", unused)
        return false

    return true
