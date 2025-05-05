@tool
extends ColorRect





enum ORIENTATION{
    LEFT, 
    RIGHT
}

@export var orientation: = ORIENTATION.RIGHT:
    get: return orientation
    set(val):
        orientation = val
        queue_redraw()
@export var resize_control: Control = null
@export var vertical_resize: = true

var _line_width = 0.5
var _line_color = Color(0.4, 0.4, 0.4)
var _active_line_color = Color(0.3, 0.3, 0.3)
var _invalid_line_color = Color(1, 0, 0)

var _grab_margin = 2
var _line_space = 3
var _num_lines = 8

var _mouse_down = false



func _draw():
    var c = _line_color
    if (resize_control == null):
        c = _invalid_line_color
    elif (_mouse_down):
        c = _active_line_color

    if (orientation == ORIENTATION.LEFT):
        _draw_resize_handle_left(c)
    else:
        _draw_resize_handle_right(c)


func _gui_input(event):
    if (resize_control == null):
        return

    if (orientation == ORIENTATION.LEFT):
        _handle_left_input(event)
    else:
        _handle_right_input(event)




func _draw_resize_handle_right(color):
    var br = size

    for i in range(_num_lines):
        var start = br - Vector2(i * _line_space, 0)
        var end = br - Vector2(0, i * _line_space)
        draw_line(start, end, color, _line_width, true)


func _draw_resize_handle_left(color):
    var bl = Vector2(0, size.y)

    for i in range(_num_lines):
        var start = bl + Vector2(i * _line_space, 0)
        var end = bl - Vector2(0, i * _line_space)
        draw_line(start, end, color, _line_width, true)


func _handle_right_input(event: InputEvent):
    if (event is InputEventMouseMotion):
        if (_mouse_down and 
            event.global_position.x > 0 and 
            event.global_position.y < DisplayServer.window_get_size().y):

            if (vertical_resize):
                resize_control.size.y += event.relative.y
            resize_control.size.x += event.relative.x
    elif (event is InputEventMouseButton):
        if (event.button_index == MOUSE_BUTTON_LEFT):
            _mouse_down = event.pressed
            queue_redraw()


func _handle_left_input(event: InputEvent):
    if (event is InputEventMouseMotion):
        if (_mouse_down and 
            event.global_position.x > 0 and 
            event.global_position.y < DisplayServer.window_get_size().y):

            var start_size = resize_control.size
            resize_control.size.x -= event.relative.x
            if (resize_control.size.x != start_size.x):
                resize_control.global_position.x += event.relative.x

            if (vertical_resize):
                resize_control.size.y += event.relative.y
    elif (event is InputEventMouseButton):
        if (event.button_index == MOUSE_BUTTON_LEFT):
            _mouse_down = event.pressed
            queue_redraw()
