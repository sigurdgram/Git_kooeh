
class_name DMResolvedGotoData extends RefCounted



var title: String = ""

var next_id: String = ""

var expression: Array[Dictionary] = []

var text_without_goto: String = ""

var is_snippet: bool = false

var error: int

var index: int = 0


var regex: DMCompilerRegEx = DMCompilerRegEx.new()


func _init(text: String, titles: Dictionary) -> void :
    if not "=> " in text and not "=>< " in text: return

    if "=> " in text:
        text_without_goto = text.substr(0, text.find("=> ")).strip_edges()
    elif "=>< " in text:
        is_snippet = true
        text_without_goto = text.substr(0, text.find("=>< ")).strip_edges()

    var found: RegExMatch = regex.GOTO_REGEX.search(text)
    if found == null:
        return

    title = found.strings[found.names.goto].strip_edges()
    index = found.get_start(0)

    if title == "":
        error = DMConstants.ERR_UNKNOWN_TITLE
        return


    if title == "END!":
        next_id = DMConstants.ID_END_CONVERSATION



    elif title == "END":
        next_id = DMConstants.ID_END

    elif titles.has(title):
        next_id = titles.get(title)
    elif title.begins_with("{{"):
        var expression_parser: DMExpressionParser = DMExpressionParser.new()
        var title_expression: Array[Dictionary] = expression_parser.extract_replacements(title, 0)
        if title_expression[0].has("error"):
            error = title_expression[0].error
        else:
            expression = title_expression[0].expression
    else:
        next_id = title
        error = DMConstants.ERR_UNKNOWN_TITLE


func _to_string() -> String:
    return "%s =>%s %s (%s)" % [text_without_goto, "<" if is_snippet else "", title, next_id]
