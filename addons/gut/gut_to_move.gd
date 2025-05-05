

extends Node
var _utils = load("res://addons/gut/utils.gd").get_instance()




func directory_delete_files(path):
    var d = DirAccess.open(path)


    if (d == null):
        return




    d.list_dir_begin()
    var thing = d.get_next()
    var full_path = ""
    while (thing != ""):
        full_path = path + "/" + thing

        if (d.file_exists(full_path)):
            d.remove(full_path)
        thing = d.get_next()

    d.list_dir_end()




func file_delete(path):
    var d = DirAccess.open(path.get_base_dir())
    if (d != null):
        d.remove(path)




func is_file_empty(path):
    var f = FileAccess.open(path, FileAccess.READ)
    var result = FileAccess.get_open_error()
    var empty = true
    if (result == OK):
        empty = f.get_length() == 0
    f = null
    return empty



func get_file_as_text(path):
    return _utils.get_file_as_text(path)




func file_touch(path):
    FileAccess.open(path, FileAccess.WRITE)












func simulate(obj, times, delta, check_is_processing: bool = false):
    for _i in range(times):
        if (
            obj.has_method("_process")
            and (
                not check_is_processing
                or obj.is_processing()
            )
        ):
            obj._process(delta)
        if (
            obj.has_method("_physics_process")
            and (
                not check_is_processing
                or obj.is_physics_processing()
            )
        ):
            obj._physics_process(delta)

        for kid in obj.get_children():
            simulate(kid, 1, delta, check_is_processing)
