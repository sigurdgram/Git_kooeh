@tool
class_name DMCodeEdit extends CodeEdit


signal active_title_change(title: String)
signal error_clicked(line_number: int)
signal external_file_requested(path: String, title: String)



var main_view


var theme_overrides: Dictionary:
    set(value):
        theme_overrides = value

        syntax_highlighter = DMSyntaxHighlighter.new()


        add_theme_color_override("font_color", theme_overrides.text_color)
        add_theme_color_override("background_color", theme_overrides.background_color)
        add_theme_color_override("current_line_color", theme_overrides.current_line_color)
        add_theme_font_override("font", get_theme_font("source", "EditorFonts"))
        add_theme_font_size_override("font_size", theme_overrides.font_size * theme_overrides.scale)
        font_size = round(theme_overrides.font_size)
    get:
        return theme_overrides


var errors: Array:
    set(next_errors):
        errors = next_errors
        for i in range(0, get_line_count()):
            var is_error: bool = false
            for error in errors:
                if error.line_number == i:
                    is_error = true
            mark_line_as_error(i, is_error)
        _on_code_edit_caret_changed()
    get:
        return errors


var last_selected_text: String

var font_size: int:
    set(value):
        font_size = value
        add_theme_font_size_override("font_size", font_size * theme_overrides.scale)
    get:
        return font_size

var WEIGHTED_RANDOM_PREFIX: RegEx = RegEx.create_from_string("^\\%[\\d.]+\\s")


func _ready() -> void :

    add_gutter(0)
    set_gutter_type(0, TextEdit.GUTTER_TYPE_ICON)


    if not has_comment_delimiter("#"):
        add_comment_delimiter("#", "", true)

    syntax_highlighter = DMSyntaxHighlighter.new()


func _gui_input(event: InputEvent) -> void :

    if event is InputEventKey and event.is_pressed():
        var shortcut: String = Engine.get_meta("DialogueManagerPlugin").get_editor_shortcut(event)
        match shortcut:
            "toggle_comment":
                toggle_comment()
                get_viewport().set_input_as_handled()
            "delete_line":
                delete_current_line()
                get_viewport().set_input_as_handled()
            "move_up":
                move_line(-1)
                get_viewport().set_input_as_handled()
            "move_down":
                move_line(1)
                get_viewport().set_input_as_handled()
            "text_size_increase":
                self.font_size += 1
                get_viewport().set_input_as_handled()
            "text_size_decrease":
                self.font_size -= 1
                get_viewport().set_input_as_handled()
            "text_size_reset":
                self.font_size = theme_overrides.font_size
                get_viewport().set_input_as_handled()

    elif event is InputEventMouse:
        match event.as_text():
            "Ctrl+Mouse Wheel Up", "Command+Mouse Wheel Up":
                self.font_size += 1
                get_viewport().set_input_as_handled()
            "Ctrl+Mouse Wheel Down", "Command+Mouse Wheel Down":
                self.font_size -= 1
                get_viewport().set_input_as_handled()


func _can_drop_data(at_position: Vector2, data) -> bool:
    if typeof(data) != TYPE_DICTIONARY: return false
    if data.type != "files": return false

    var files: PackedStringArray = Array(data.files)
    return files.size() > 0


func _drop_data(at_position: Vector2, data) -> void :
    var replace_regex: RegEx = RegEx.create_from_string("[^a-zA-Z_0-9]+")

    var files: PackedStringArray = Array(data.files)
    for file in files:

        if file == main_view.current_file_path: continue

        if file.get_extension() == "dialogue":
            var path = file.replace("res://", "").replace(".dialogue", "")

            var lines = text.split("\n")
            for i in range(0, lines.size()):
                if not lines[i].begins_with("import "):
                    insert_line_at(i, "import \"%s\" as %s\n" % [file, replace_regex.sub(path, "_", true)])
                    set_caret_line(i)
                    break
        else:
            var cursor: Vector2 = get_line_column_at_pos(at_position)
            if cursor.x > -1 and cursor.y > -1:
                set_cursor(cursor)
                remove_secondary_carets()
                if has_method("insert_text"):
                    call("insert_text", "\"%s\"" % file, cursor.y, cursor.x)
                else:
                    call("insert_text_at_cursor", "\"%s\"" % file)
    grab_focus()


func _request_code_completion(force: bool) -> void :
    var cursor: Vector2 = get_cursor()
    var current_line: String = get_line(cursor.y)

    if ("=> " in current_line or "=>< " in current_line) and (cursor.x > current_line.find("=>")):
        var prompt: String = current_line.split("=>")[1]
        if prompt.begins_with("< "):
            prompt = prompt.substr(2)
        else:
            prompt = prompt.substr(1)

        if "=> " in current_line:
            if matches_prompt(prompt, "end"):
                add_code_completion_option(CodeEdit.KIND_CLASS, "END", "END".substr(prompt.length()), theme_overrides.text_color, get_theme_icon("Stop", "EditorIcons"))
            if matches_prompt(prompt, "end!"):
                add_code_completion_option(CodeEdit.KIND_CLASS, "END!", "END!".substr(prompt.length()), theme_overrides.text_color, get_theme_icon("Stop", "EditorIcons"))


        for title: String in DMCompiler.get_titles_in_text(text, main_view.current_file_path):

            if title.to_int() > 0:
                continue

            elif "/" in title:
                var bits = title.split("/")
                if matches_prompt(prompt, bits[0]) or matches_prompt(prompt, bits[1]):
                    add_code_completion_option(CodeEdit.KIND_CLASS, title, title.substr(prompt.length()), theme_overrides.text_color, get_theme_icon("CombineLines", "EditorIcons"))
            elif matches_prompt(prompt, title):
                add_code_completion_option(CodeEdit.KIND_CLASS, title, title.substr(prompt.length()), theme_overrides.text_color, get_theme_icon("ArrowRight", "EditorIcons"))
        update_code_completion_options(true)
        return

    var name_so_far: String = WEIGHTED_RANDOM_PREFIX.sub(current_line.strip_edges(), "")
    if name_so_far != "" and name_so_far[0].to_upper() == name_so_far[0]:

        var names: PackedStringArray = get_character_names(name_so_far)
        if names.size() > 0:
            for name in names:
                add_code_completion_option(CodeEdit.KIND_CLASS, name + ": ", name.substr(name_so_far.length()) + ": ", theme_overrides.text_color, get_theme_icon("Sprite2D", "EditorIcons"))
            update_code_completion_options(true)
        else:
            cancel_code_completion()


func _filter_code_completion_candidates(candidates: Array) -> Array:

    return candidates


func _confirm_code_completion(replace: bool) -> void :
    var completion = get_code_completion_option(get_code_completion_selected_index())
    begin_complex_operation()

    for i in range(0, completion.display_text.length() - completion.insert_text.length()):
        backspace()

    insert_text_at_caret(completion.display_text)
    end_complex_operation()


    call_deferred("cancel_code_completion")






func get_cursor() -> Vector2:
    return Vector2(get_caret_column(), get_caret_line())



func set_cursor(from_cursor: Vector2) -> void :
    set_caret_line(from_cursor.y, false)
    set_caret_column(from_cursor.x, false)



func matches_prompt(prompt: String, matcher: String) -> bool:
    return prompt.length() < matcher.length() and matcher.to_lower().begins_with(prompt.to_lower())



func get_titles() -> PackedStringArray:
    var titles = PackedStringArray([])
    var lines = text.split("\n")
    for line in lines:
        if line.strip_edges().begins_with("~ "):
            titles.append(line.strip_edges().substr(2))

    return titles



func check_active_title() -> void :
    var line_number = get_caret_line()
    var lines = text.split("\n")

    for i in range(line_number, -1, -1):
        if lines[i].begins_with("~ "):
            active_title_change.emit(lines[i].replace("~ ", ""))
            return

    active_title_change.emit("")



func go_to_title(title: String) -> void :
    var lines = text.split("\n")
    for i in range(0, lines.size()):
        if lines[i].strip_edges() == "~ " + title:
            set_caret_line(i)
            center_viewport_to_caret()


func get_character_names(beginning_with: String) -> PackedStringArray:
    var names: PackedStringArray = []
    var lines = text.split("\n")
    for line in lines:
        if ": " in line:
            var name: String = WEIGHTED_RANDOM_PREFIX.sub(line.split(": ")[0].strip_edges(), "")
            if not name in names and matches_prompt(beginning_with, name):
                names.append(name)
    return names



func mark_line_as_error(line_number: int, is_error: bool) -> void :

    line_number -= 1

    if line_number < 0: return

    if is_error:
        set_line_background_color(line_number, theme_overrides.error_line_color)
        set_line_gutter_icon(line_number, 0, get_theme_icon("StatusError", "EditorIcons"))
    else:
        set_line_background_color(line_number, theme_overrides.background_color)
        set_line_gutter_icon(line_number, 0, null)



func insert_bbcode(open_tag: String, close_tag: String = "") -> void :
    if close_tag == "":
        insert_text_at_caret(open_tag)
        grab_focus()
    else:
        var selected_text = get_selected_text()
        insert_text_at_caret("%s%s%s" % [open_tag, selected_text, close_tag])
        grab_focus()
        set_caret_column(get_caret_column() - close_tag.length())



func insert_text_at_cursor(text: String) -> void :
    if text != "=> END":
        insert_text_at_caret(text + "\n")
        set_caret_line(get_caret_line() + 1)
    else:
        insert_text_at_caret(text)
    grab_focus()



func toggle_comment() -> void :
    begin_complex_operation()

    var comment_delimiter: String = delimiter_comments[0]
    var is_first_line: bool = true
    var will_comment: bool = true
    var selections: Array = []
    var line_offsets: Dictionary = {}

    for caret_index in range(0, get_caret_count()):
        var from_line: int = get_caret_line(caret_index)
        var from_column: int = get_caret_column(caret_index)
        var to_line: int = get_caret_line(caret_index)
        var to_column: int = get_caret_column(caret_index)

        if has_selection(caret_index):
            from_line = get_selection_from_line(caret_index)
            to_line = get_selection_to_line(caret_index)
            from_column = get_selection_from_column(caret_index)
            to_column = get_selection_to_column(caret_index)

        selections.append({
            from_line = from_line, 
            from_column = from_column, 
            to_line = to_line, 
            to_column = to_column
        })

        for line_number in range(from_line, to_line + 1):
            if line_offsets.has(line_number): continue

            var line_text: String = get_line(line_number)


            if is_first_line:
                is_first_line = false
                will_comment = not line_text.strip_edges().begins_with(comment_delimiter)


            if will_comment:
                set_line(line_number, comment_delimiter + line_text)
                line_offsets[line_number] = 1
            elif line_text.begins_with(comment_delimiter):
                set_line(line_number, line_text.substr(comment_delimiter.length()))
                line_offsets[line_number] = -1
            else:
                line_offsets[line_number] = 0

    for caret_index in range(0, get_caret_count()):
        var selection: Dictionary = selections[caret_index]
        select(
            selection.from_line, 
            selection.from_column + line_offsets[selection.from_line], 
            selection.to_line, 
            selection.to_column + line_offsets[selection.to_line], 
            caret_index
        )
        set_caret_column(selection.from_column + line_offsets[selection.from_line], false, caret_index)

    end_complex_operation()

    text_set.emit()
    text_changed.emit()



func delete_current_line() -> void :
    var cursor = get_cursor()
    if get_line_count() == 1:
        select_all()
    elif cursor.y == 0:
        select(0, 0, 1, 0)
    else:
        select(cursor.y - 1, get_line_width(cursor.y - 1), cursor.y, get_line_width(cursor.y))
    delete_selection()
    text_changed.emit()



func move_line(offset: int) -> void :
    offset = clamp(offset, -1, 1)

    var starting_scroll: = scroll_vertical
    var cursor = get_cursor()
    var reselect: bool = false
    var from: int = cursor.y
    var to: int = cursor.y
    if has_selection():
        reselect = true
        from = get_selection_from_line()
        to = get_selection_to_line()

    var lines: = text.split("\n")


    if from + offset < 0 or to + offset >= lines.size(): return

    var target_from_index = from - 1 if offset == -1 else to + 1
    var target_to_index = to if offset == -1 else from
    var line_to_move = lines[target_from_index]
    lines.remove_at(target_from_index)
    lines.insert(target_to_index, line_to_move)

    text = "\n".join(lines)

    cursor.y += offset
    set_cursor(cursor)
    from += offset
    to += offset
    if reselect:
        select(from, 0, to, get_line_width(to))

    text_changed.emit()
    scroll_vertical = starting_scroll + offset





func _on_code_edit_symbol_validate(symbol: String) -> void :
    if symbol.begins_with("res://") and symbol.ends_with(".dialogue"):
        set_symbol_lookup_word_as_valid(true)
        return

    for title in get_titles():
        if symbol == title:
            set_symbol_lookup_word_as_valid(true)
            return
    set_symbol_lookup_word_as_valid(false)


func _on_code_edit_symbol_lookup(symbol: String, line: int, column: int) -> void :
    if symbol.begins_with("res://") and symbol.ends_with(".dialogue"):
        external_file_requested.emit(symbol, "")
    else:
        go_to_title(symbol)


func _on_code_edit_text_changed() -> void :
    request_code_completion(true)


func _on_code_edit_text_set() -> void :
    queue_redraw()


func _on_code_edit_caret_changed() -> void :
    check_active_title()
    last_selected_text = get_selected_text()


func _on_code_edit_gutter_clicked(line: int, gutter: int) -> void :
    var line_errors = errors.filter(func(error): return error.line_number == line)
    if line_errors.size() > 0:
        error_clicked.emit(line)
