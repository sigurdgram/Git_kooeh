


class Printer:
    var _format_enabled = true
    var _disabled = false
    var _printer_name = "NOT SET"
    var _show_name = false

    func get_format_enabled():
        return _format_enabled

    func set_format_enabled(format_enabled):
        _format_enabled = format_enabled

    func send(text, fmt = null):
        if (_disabled):
            return

        var formatted = text
        if (fmt != null and _format_enabled):
            formatted = format_text(text, fmt)

        if (_show_name):
            formatted = str("(", _printer_name, ")") + formatted

        _output(formatted)

    func get_disabled():
        return _disabled

    func set_disabled(disabled):
        _disabled = disabled




    func _output(text):
        pass

    func format_text(text, fmt):
        return text




class GutGuiPrinter:
    extends Printer
    var _textbox = null

    var _colors = {
            red = Color.RED, 
            yellow = Color.YELLOW, 
            green = Color.GREEN
    }

    func _init():
        _printer_name = "gui"

    func _wrap_with_tag(text, tag):
        return str("[", tag, "]", text, "[/", tag, "]")

    func _color_text(text, c_word):
        return "[color=" + c_word + "]" + text + "[/color]"

















    func format_text(text, fmt):
        if (_textbox == null):
            return

        if (fmt == "bold"):
            _textbox.push_bold()
        elif (fmt == "underline"):
            _textbox.push_underline()
        elif (_colors.has(fmt)):
            _textbox.push_color(_colors[fmt])
        else:

            _textbox.push_normal()

        _textbox.add_text(text)
        _textbox.pop()

        return ""

    func _output(text):
        if (_textbox == null):
            return

        _textbox.add_text(text)

    func get_textbox():
        return _textbox

    func set_textbox(textbox):
        _textbox = textbox


    func clear_line():
        _textbox.remove_line(_textbox.get_line_count() - 1)
        _textbox.queue_redraw()

    func get_bbcode():
        return _textbox.text

    func get_disabled():
        return _disabled and _textbox != null






class ConsolePrinter:
    extends Printer
    var _buffer = ""

    func _init():
        _printer_name = "console"



    func _output(text):
        if (text.ends_with("\n")):
            print(_buffer + text.left(text.length() - 1))
            _buffer = ""
        else:
            _buffer += text




class TerminalPrinter:
    extends Printer

    var escape = PackedByteArray([27]).get_string_from_ascii()
    var cmd_colors = {
        red = escape + "[31m", 
        yellow = escape + "[33m", 
        green = escape + "[32m", 

        underline = escape + "[4m", 
        bold = escape + "[1m", 

        default = escape + "[0m", 

        clear_line = escape + "[2K"
    }

    func _init():
        _printer_name = "terminal"

    func _output(text):

        printraw(text)

    func format_text(text, fmt):
        return cmd_colors[fmt] + text + cmd_colors.default

    func clear_line():
        send(cmd_colors.clear_line)

    func back(n):
        send(escape + str("[", n, "D"))

    func forward(n):
        send(escape + str("[", n, "C"))
