
class_name DMCompilation extends RefCounted






var imported_paths: PackedStringArray = []

var using_states: PackedStringArray = []

var titles: Dictionary = {}

var first_title: String = ""

var character_names: PackedStringArray = []

var errors: Array[Dictionary] = []

var lines: Dictionary = {}

var data: Dictionary = {}








var regex: DMCompilerRegEx = DMCompilerRegEx.new()

var expression_parser: DMExpressionParser = DMExpressionParser.new()


var _imported_titles: Dictionary = {}

var _imported_line_map: Dictionary = {}

var _imported_line_count: int = 0

var _known_translation_keys: Dictionary = {}

var _first: Callable = func(_s): return true


var _goto_lines: Dictionary = {}








func compile(text: String, path: String = ".") -> Error:
    titles = {}
    character_names = []

    parse_line_tree(build_line_tree(inject_imported_files(text + "\n=> END", path)))


    for id in lines:
        var line: DMCompiledLine = lines[id]
        data[id] = line.to_data()

    if errors.size() > 0:
        return ERR_PARSE_ERROR

    return OK



func inject_imported_files(text: String, path: String) -> PackedStringArray:

    var known_imports: Dictionary = {}


    known_imports[path.hash()] = "."

    var raw_lines: PackedStringArray = text.split("\n")

    for id in range(0, raw_lines.size()):
        var line = raw_lines[id]
        if is_import_line(line):
            var import_data: Dictionary = extract_import_path_and_name(line)

            if not import_data.has("path"): continue

            var import_hash: int = import_data.path.hash()
            if import_data.size() > 0:

                if str(import_hash) in _imported_titles.keys():
                    add_error(id, 0, DMConstants.ERR_FILE_ALREADY_IMPORTED)
                if import_data.prefix in _imported_titles.values():
                    add_error(id, 0, DMConstants.ERR_DUPLICATE_IMPORT_NAME)
                _imported_titles[str(import_hash)] = import_data.prefix


                if not known_imports.has(import_hash):
                    var error: Error = import_content(import_data.path, import_data.prefix, _imported_line_map, known_imports)
                    if error != OK:
                        add_error(id, 0, error)


                if not _imported_line_map.has(import_hash):
                    _imported_line_map[import_hash] = {
                        hash = import_hash, 
                        imported_on_line_number = id, 
                        from_line = 0, 
                        to_line = 0
                    }

    var imported_content: String = ""
    var cummulative_line_number: int = 0
    for item in _imported_line_map.values():
        item["from_line"] = cummulative_line_number
        if known_imports.has(item.hash):
            cummulative_line_number += known_imports[item.hash].split("\n").size()
        item["to_line"] = cummulative_line_number
        if known_imports.has(item.hash):
            imported_content += known_imports[item.hash] + "\n"

    if imported_content == "":
        _imported_line_count = 0
        return text.split("\n")
    else:
        _imported_line_count = cummulative_line_number + 1

        return (imported_content + "\n" + text).split("\n")



func import_content(path: String, prefix: String, imported_line_map: Dictionary, known_imports: Dictionary) -> Error:
    if FileAccess.file_exists(path):
        var file = FileAccess.open(path, FileAccess.READ)
        var content: PackedStringArray = file.get_as_text().strip_edges().split("\n")

        for index in range(0, content.size()):
            var line = content[index]
            if is_import_line(line):
                var import = extract_import_path_and_name(line)
                if import.size() > 0:
                    if not known_imports.has(import.path.hash()):

                        known_imports[import.path.hash()] = ""
                        if import_content(import.path, import.prefix, imported_line_map, known_imports) != OK:
                            return ERR_LINK_FAILED

                    if not imported_line_map.has(import.path.hash()):

                        imported_line_map[import.path.hash()] = {
                            hash = import.path.hash(), 
                            imported_on_line_number = index, 
                            from_line = 0, 
                            to_line = 0
                        }

                    _imported_titles[import.prefix] = import.path.hash()

        var origin_hash: int = -1
        for hash_value in known_imports.keys():
            if known_imports[hash_value] == ".":
                origin_hash = hash_value


        for i in range(0, content.size()):
            var line = content[i]
            if line.strip_edges().begins_with("~ "):
                var title = line.strip_edges().substr(2)
                if "/" in line:
                    var bits = title.split("/")
                    content[i] = "~ %s/%s" % [_imported_titles[bits[0]], bits[1]]
                else:
                    content[i] = "~ %s/%s" % [str(path.hash()), title]

            elif "=>< " in line:
                var jump: String = line.substr(line.find("=>< ") + "=>< ".length()).strip_edges()
                if "/" in jump:
                    var bits: PackedStringArray = jump.split("/")
                    var title_hash: int = _imported_titles[bits[0]]
                    if title_hash == origin_hash:
                        content[i] = "%s=>< %s" % [line.split("=>< ")[0], bits[1]]
                    else:
                        content[i] = "%s=>< %s/%s" % [line.split("=>< ")[0], title_hash, bits[1]]

                elif not jump in ["END", "END!"]:
                    content[i] = "%s=>< %s/%s" % [line.split("=>< ")[0], str(path.hash()), jump]

            elif "=> " in line:
                var jump: String = line.substr(line.find("=> ") + "=> ".length()).strip_edges()
                if "/" in jump:
                    var bits: PackedStringArray = jump.split("/")
                    var title_hash: int = _imported_titles[bits[0]]
                    if title_hash == origin_hash:
                        content[i] = "%s=> %s" % [line.split("=> ")[0], bits[1]]
                    else:
                        content[i] = "%s=> %s/%s" % [line.split("=> ")[0], title_hash, bits[1]]

                elif not jump in ["END", "END!"]:
                    content[i] = "%s=> %s/%s" % [line.split("=> ")[0], str(path.hash()), jump]

        imported_paths.append(path)
        known_imports[path.hash()] = "\n".join(content) + "\n=> END\n"
        return OK
    else:
        return ERR_FILE_NOT_FOUND



func build_line_tree(raw_lines: PackedStringArray) -> DMTreeLine:
    var root: DMTreeLine = DMTreeLine.new("")
    var parent_chain: Array[DMTreeLine] = [root]
    var previous_line: DMTreeLine
    var doc_comments: PackedStringArray = []


    var autoload_names: PackedStringArray = get_autoload_names()

    for i in range(0, raw_lines.size()):
        var raw_line: String = raw_lines[i]
        var tree_line: DMTreeLine = DMTreeLine.new(str(i - _imported_line_count))

        tree_line.line_number = i + 1
        tree_line.type = get_line_type(raw_line)
        tree_line.text = raw_line.strip_edges()


        if raw_line.begins_with("using "):
            var using_match: RegExMatch = regex.USING_REGEX.search(raw_line)
            if "state" in using_match.names:
                var using_state: String = using_match.strings[using_match.names.state].strip_edges()
                if not using_state in autoload_names:
                    add_error(i, 0, DMConstants.ERR_UNKNOWN_USING)
                elif not using_state in using_states:
                    using_states.append(using_state)
                continue

        elif is_import_line(raw_line):
            continue

        tree_line.indent = get_indent(raw_line)


        if raw_line.strip_edges().begins_with("##"):
            doc_comments.append(raw_line.replace("##", "").strip_edges())
        elif tree_line.type == DMConstants.TYPE_DIALOGUE:
            tree_line.notes = "\n".join(doc_comments)
            doc_comments.clear()





        if tree_line.type in [DMConstants.TYPE_UNKNOWN, DMConstants.TYPE_COMMENT] and raw_lines.size() > i + 1:
            var next_line = raw_lines[i + 1]
            if previous_line and previous_line.type in [DMConstants.TYPE_UNKNOWN, DMConstants.TYPE_COMMENT] and tree_line.type in [DMConstants.TYPE_UNKNOWN, DMConstants.TYPE_COMMENT]:
                continue
            else:
                tree_line.type = DMConstants.TYPE_UNKNOWN
                tree_line.indent = get_indent(next_line)


        if tree_line.indent > parent_chain.size() - 1:
            parent_chain.append(previous_line)
        elif tree_line.indent < parent_chain.size() - 1:
            parent_chain.resize(tree_line.indent + 1)


        if tree_line.type == DMConstants.TYPE_TITLE:
            var title: String = tree_line.text.substr(2)
            if title == "":
                add_error(i, 2, DMConstants.ERR_EMPTY_TITLE)
            elif titles.has(title):
                add_error(i, 2, DMConstants.ERR_DUPLICATE_TITLE)
            else:
                titles[title] = tree_line.id
                if "/" in title:

                    var bits: PackedStringArray = title.split("/")
                    if _imported_titles.has(bits[0]):
                        title = _imported_titles[bits[0]] + "/" + bits[1]
                        titles[title] = tree_line.id
                elif first_title == "" and i >= _imported_line_count:
                    first_title = tree_line.id


        var parent: DMTreeLine = parent_chain[parent_chain.size() - 1]
        tree_line.parent = weakref(parent)
        parent.children.append(tree_line)

        previous_line = tree_line

    return root







func parse_line_tree(root: DMTreeLine, parent: DMCompiledLine = null) -> Array[DMCompiledLine]:
    var compiled_lines: Array[DMCompiledLine] = []

    for i in range(0, root.children.size()):
        var tree_line: DMTreeLine = root.children[i]
        var line: DMCompiledLine = DMCompiledLine.new(tree_line.id, tree_line.type)

        match line.type:
            DMConstants.TYPE_UNKNOWN:
                line.next_id = get_next_matching_sibling_id(root.children, i, parent, _first)

            DMConstants.TYPE_TITLE:
                parse_title_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_CONDITION:
                parse_condition_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_WHILE:
                parse_while_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_MATCH:
                parse_match_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_WHEN:
                parse_when_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_MUTATION:
                parse_mutation_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_GOTO:

                if tree_line.text.begins_with("%"):
                    parse_random_line(tree_line, line, root.children, i, parent)
                parse_goto_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_RESPONSE:
                parse_response_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_RANDOM:
                parse_random_line(tree_line, line, root.children, i, parent)

            DMConstants.TYPE_DIALOGUE:

                if tree_line.text.begins_with("%"):
                    parse_random_line(tree_line, line, root.children, i, parent)
                parse_dialogue_line(tree_line, line, root.children, i, parent)


        lines[line.id] = line


        compiled_lines.append(line)

    return compiled_lines



func parse_title_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:
    var result: Error = OK

    line.text = tree_line.text.substr(tree_line.text.find("~ ") + 2).strip_edges()


    if tree_line.line_number >= _imported_line_count and regex.BEGINS_WITH_NUMBER_REGEX.search(line.text):
        result = add_error(tree_line.line_number, 2, DMConstants.ERR_TITLE_BEGINS_WITH_NUMBER)


    var valid_title = regex.VALID_TITLE_REGEX.search(line.text.replace("/", ""))
    if not valid_title:
        result = add_error(tree_line.line_number, 2, DMConstants.ERR_TITLE_INVALID_CHARACTERS)

    line.next_id = get_next_matching_sibling_id(siblings, sibling_index, parent, _first)


    titles[line.text] = line.next_id


    if _goto_lines.has(line.text):
        for goto_line in _goto_lines[line.text]:
            goto_line.next_id = line.next_id

    return result



func parse_goto_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:

    var goto_data: DMResolvedGotoData = DMResolvedGotoData.new(tree_line.text, titles)
    if goto_data.error:
        return add_error(tree_line.line_number, tree_line.indent + 2, goto_data.error)
    if goto_data.next_id or goto_data.expression:
        line.next_id = goto_data.next_id
        line.next_id_expression = goto_data.expression
        add_reference_to_title(goto_data.title, line)

    if goto_data.is_snippet:
        line.is_snippet = true
        line.next_id_after = get_next_matching_sibling_id(siblings, sibling_index, parent, _first)

    return OK



func parse_condition_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:




    for next_sibling: DMTreeLine in siblings.slice(sibling_index + 1):
        if not next_sibling.type in [DMConstants.TYPE_UNKNOWN, DMConstants.TYPE_CONDITION]:
            break
        elif next_sibling.type == DMConstants.TYPE_CONDITION:
            if next_sibling.text.begins_with("el"):
                line.next_sibling_id = next_sibling.id
                break
            else:
                break

    line.next_id_after = get_next_matching_sibling_id(siblings, sibling_index, parent, func(s: DMTreeLine):

        return s.type != DMConstants.TYPE_CONDITION or s.text.begins_with("if ")
    )

    if line.next_id_after == DMConstants.ID_NULL:
        line.next_id_after = parent.next_id_after if parent != null and parent.next_id_after else DMConstants.ID_END


    if tree_line.children.size() == 0:
        return add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_INVALID_CONDITION_INDENTATION)


    if "if " in tree_line.text:
        var condition: Dictionary = extract_condition(tree_line.text, false, tree_line.indent)
        if condition.has("error"):
            return add_error(tree_line.line_number, condition.index, condition.error)
        else:
            line.expression = condition


    parse_children(tree_line, line)

    return OK



func parse_while_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:
    line.next_id_after = get_next_matching_sibling_id(siblings, sibling_index, parent, _first)


    var condition: Dictionary = extract_condition(tree_line.text, false, tree_line.indent)
    if condition.has("error"):
        return add_error(tree_line.line_number, condition.index, condition.error)
    else:
        line.expression = condition


    parse_children(tree_line, line)

    return OK


func parse_match_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:
    var result: Error = OK


    line.next_id_after = get_next_matching_sibling_id(siblings, sibling_index, parent, _first)


    var condition: Dictionary = extract_condition(tree_line.text, false, tree_line.indent)
    if condition.has("error"):
        result = add_error(tree_line.line_number, condition.index, condition.error)
    else:
        line.expression = condition


    if tree_line.children.size() == 0:
        result = add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_INVALID_CONDITION_INDENTATION)


    for child in tree_line.children:
        if child.type == DMConstants.TYPE_WHEN: continue
        if child.type == DMConstants.TYPE_CONDITION and child.text.begins_with("else"): continue

        result = add_error(child.line_number, child.indent, DMConstants.ERR_EXPECTED_WHEN_OR_ELSE)



    var children: Array[DMCompiledLine] = parse_children(tree_line, line)
    for child: DMCompiledLine in children:

        if child.type == DMConstants.TYPE_WHEN:
            line.siblings.append({
                condition = child.expression, 
                next_id = child.next_id
            })

        elif child.type == DMConstants.TYPE_CONDITION:
            if line.siblings.any(func(s): return s.has("is_else")):
                result = add_error(child.line_number, child.indent, DMConstants.ERR_ONLY_ONE_ELSE_ALLOWED)
            else:
                line.siblings.append({
                    next_id = child.next_id, 
                    is_else = true
                })

        lines.erase(child.id)

    return result


func parse_when_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:
    var result: Error = OK


    if parent.type != DMConstants.TYPE_MATCH:
        result = add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_WHEN_MUST_BELONG_TO_MATCH)


    if tree_line.children.size() == 0:
        result = add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_INVALID_CONDITION_INDENTATION)


    line.next_id_after = parent.next_id_after


    var condition: Dictionary = extract_condition(tree_line.text, false, tree_line.indent)
    if condition.has("error"):
        result = add_error(tree_line.line_number, condition.index, condition.error)
    else:
        line.expression = condition

    parse_children(tree_line, line)

    return result



func parse_mutation_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:
    var mutation: Dictionary = extract_mutation(tree_line.text)
    if mutation.has("error"):
        return add_error(tree_line.line_number, mutation.index, mutation.error)
    else:
        line.expression = mutation

    line.next_id = get_next_matching_sibling_id(siblings, sibling_index, parent, _first)

    return OK



func parse_response_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:
    var result: Error = OK


    tree_line.text = tree_line.text.substr(2)


    var static_line_id: String = extract_static_line_id(tree_line.text)
    if static_line_id:
        tree_line.text = tree_line.text.replace("[ID:%s]" % [static_line_id], "")
        line.translation_key = static_line_id


    if " [if " in tree_line.text:
        var condition = extract_condition(tree_line.text, true, tree_line.indent)
        if condition.has("error"):
            result = add_error(tree_line.line_number, condition.index, condition.error)
        else:
            line.expression = condition
            tree_line.text = regex.WRAPPED_CONDITION_REGEX.sub(tree_line.text, "").strip_edges()


    var original_response: DMTreeLine = tree_line
    for i in range(sibling_index - 1, 0, -1):
        if siblings[i].type == DMConstants.TYPE_RESPONSE:
            original_response = siblings[i]
        elif siblings[i].type != DMConstants.TYPE_UNKNOWN:
            break


    if original_response == tree_line:
        line.next_id_after = get_next_matching_sibling_id(siblings, sibling_index, parent, (func(s: DMTreeLine):

            return not s.type in [DMConstants.TYPE_RESPONSE, DMConstants.TYPE_UNKNOWN]
        ), true)
        line.responses = [line.id]

        if tree_line.children.size() > 0:
            parse_children(tree_line, line)

        else:
            line.next_id = line.next_id_after

    else:
        var original_line: DMCompiledLine = lines[original_response.id]
        line.next_id_after = original_line.next_id_after
        line.siblings = original_line.siblings
        original_line.responses.append(line.id)

        if tree_line.children.size() > 0:
            parse_children(tree_line, line)

        else:
            line.next_id = original_line.next_id_after

    parse_character_and_dialogue(tree_line, line, siblings, sibling_index, parent)

    return OK



func parse_random_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:

    var weight: float = 1
    var found = regex.WEIGHTED_RANDOM_SIBLINGS_REGEX.search(tree_line.text + " ")
    var condition: Dictionary = {}
    if found:
        if found.names.has("weight"):
            weight = found.strings[found.names.weight].to_float()
        if found.names.has("condition"):
            condition = extract_condition(tree_line.text, true, tree_line.indent)


    var original_sibling: DMTreeLine = tree_line
    for i in range(sibling_index - 1, -1, -1):
        if siblings[i] and siblings[i].is_random:
            original_sibling = siblings[i]
        else:
            break

    var weighted_sibling: Dictionary = {weight = weight, id = line.id, condition = condition}


    if original_sibling == tree_line:
        line.next_id_after = get_next_matching_sibling_id(siblings, sibling_index, parent, (func(s: DMTreeLine):


            return not s.text.begins_with("%")
        ), true)
        line.siblings = [weighted_sibling]

        if tree_line.children.size() > 0:
            parse_children(tree_line, line)

        else:
            line.next_id = line.next_id_after


    else:
        var original_line: DMCompiledLine = lines[original_sibling.id]
        line.next_id_after = original_line.next_id_after
        line.siblings = original_line.siblings
        original_line.siblings.append(weighted_sibling)

        if tree_line.children.size() > 0:
            parse_children(tree_line, line)

        else:
            line.next_id = original_line.next_id_after


    tree_line.text = regex.WEIGHTED_RANDOM_SIBLINGS_REGEX.sub(tree_line.text, "")
    tree_line.is_random = true

    return OK



func parse_dialogue_line(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:
    var result: Error = OK


    if tree_line.text.begins_with("\\using"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\if"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\elif"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\else"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\while"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\match"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\when"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\do"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\set"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\-"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\~"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\=>"): tree_line.text = tree_line.text.substr(1)
    if tree_line.text.begins_with("\\%"): tree_line.text = tree_line.text.substr(1)


    for i in range(0, tree_line.children.size()):
        var child: DMTreeLine = tree_line.children[i]
        if child.type == DMConstants.TYPE_DIALOGUE:
            tree_line.text += "\n" + child.text
        else:
            result = add_error(child.line_number, child.indent, DMConstants.ERR_INVALID_INDENTATION)


    var static_line_id: String = extract_static_line_id(tree_line.text)
    if static_line_id:
        tree_line.text = tree_line.text.replace("[ID:%s]" % [static_line_id], "")
        line.translation_key = static_line_id


    if tree_line.text.begins_with("| "):

        if " =>" in tree_line.text:
            result = add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_GOTO_NOT_ALLOWED_ON_CONCURRECT_LINES)

        tree_line.text = tree_line.text.substr(2)
        var previous_sibling: DMTreeLine = siblings[sibling_index - 1]
        if previous_sibling.type != DMConstants.TYPE_DIALOGUE:
            result = add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_CONCURRENT_LINE_WITHOUT_ORIGIN)
        else:


            var previous_line: DMCompiledLine = lines[previous_sibling.id]
            previous_line.concurrent_lines.append(line.id)
            line.concurrent_lines = previous_line.concurrent_lines

    parse_character_and_dialogue(tree_line, line, siblings, sibling_index, parent)


    var resolved_line_data: DMResolvedLineData = DMResolvedLineData.new("")
    var bbcodes: Array[Dictionary] = resolved_line_data.find_bbcode_positions_in_string(tree_line.text, true, true)
    for bbcode: Dictionary in bbcodes:
        var tag: String = bbcode.code
        var code: String = bbcode.raw_args
        if tag.begins_with("do") or tag.begins_with("set") or tag.begins_with("if"):
            var expression: Array = expression_parser.tokenise(code, DMConstants.TYPE_MUTATION, bbcode.start + bbcode.code.length())
            if expression.size() == 0:
                add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_INVALID_EXPRESSION)
            elif expression[0].type == DMConstants.TYPE_ERROR:
                add_error(tree_line.line_number, tree_line.indent + expression[0].index, expression[0].value)



    if line.next_id == DMConstants.ID_NULL and line.siblings.size() == 0:
        line.next_id = get_next_matching_sibling_id(siblings, sibling_index, parent, func(s: DMTreeLine):

            return not s.text.begins_with("| ")
        )

    return result



func parse_character_and_dialogue(tree_line: DMTreeLine, line: DMCompiledLine, siblings: Array[DMTreeLine], sibling_index: int, parent: DMCompiledLine) -> Error:
    var result: Error = OK

    var text: String = tree_line.text


    line.notes = tree_line.notes


    var tag_data: DMResolvedTagData = DMResolvedTagData.new(text)
    line.tags = tag_data.tags
    text = tag_data.text_without_tags


    if " =><" in text:


        var goto_data: DMResolvedGotoData = DMResolvedGotoData.new(text, titles)
        if goto_data.error:
            result = add_error(tree_line.line_number, tree_line.indent + 3, goto_data.error)
        if goto_data.next_id or goto_data.expression:
            text = goto_data.text_without_goto
            var goto_line: DMCompiledLine = DMCompiledLine.new(line.id + ".1", DMConstants.TYPE_GOTO)
            goto_line.next_id = goto_data.next_id
            line.next_id_expression = goto_data.expression
            if line.type == DMConstants.TYPE_RESPONSE:
                goto_line.next_id_after = get_next_matching_sibling_id(siblings, sibling_index, parent, func(s: DMTreeLine):

                    return s.type != DMConstants.TYPE_RESPONSE
                )
            else:
                goto_line.next_id_after = get_next_matching_sibling_id(siblings, sibling_index, parent, _first)
            goto_line.is_snippet = true
            lines[goto_line.id] = goto_line
            line.next_id = goto_line.id
            add_reference_to_title(goto_data.title, goto_line)
    elif " =>" in text:
        var goto_data: DMResolvedGotoData = DMResolvedGotoData.new(text, titles)
        if goto_data.error:
            result = add_error(tree_line.line_number, tree_line.indent + 2, goto_data.error)
        if goto_data.next_id or goto_data.expression:
            text = goto_data.text_without_goto
            line.next_id = goto_data.next_id
            line.next_id_expression = goto_data.expression
            add_reference_to_title(goto_data.title, line)


    text = text.replace("\\:", "!ESCAPED_COLON!")
    if ": " in text:

        var bits = Array(text.strip_edges().split(": "))
        line.character = bits.pop_front().strip_edges()
        if not line.character in character_names:
            character_names.append(line["character"])

        line.character_replacements = expression_parser.extract_replacements(line.character, tree_line.indent)
        for replacement in line.character_replacements:
            if replacement.has("error"):
                result = add_error(tree_line.line_number, replacement.index, replacement.error)
        text = ": ".join(bits).replace("!ESCAPED_COLON!", ":")
    else:
        line.character = ""
        text = text.replace("!ESCAPED_COLON!", ":")


    line.text_replacements = expression_parser.extract_replacements(text, line.character.length() + 2 + tree_line.indent)
    for replacement in line.text_replacements:
        if replacement.has("error"):
            result = add_error(tree_line.line_number, replacement.index, replacement.error)


    text = text.replace("\\n", "\n").strip_edges()


    if line.translation_key == "":
        line.translation_key = text

    line.text = text


    if line.translation_key != "":
        if _known_translation_keys.has(line.translation_key) and _known_translation_keys.get(line.translation_key) != line.text:
            result = add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_DUPLICATE_ID)
        else:
            _known_translation_keys[line.translation_key] = line.text

    elif DMSettings.get_setting(DMSettings.MISSING_TRANSLATIONS_ARE_ERRORS, false):
        result = add_error(tree_line.line_number, tree_line.indent, DMConstants.ERR_MISSING_ID)

    return result








func add_error(line_number: int, column_number: int, error: int) -> Error:

    for item in _imported_line_map.values():
        if line_number < item.to_line:
            errors.append({
                line_number = item.imported_on_line_number, 
                column_number = 0, 
                error = DMConstants.ERR_ERRORS_IN_IMPORTED_FILE, 
                external_error = error, 
                external_line_number = line_number
            })
            return error


    errors.append({
        line_number = line_number - _imported_line_count, 
        column_number = column_number, 
        error = error
    })

    return error








func get_autoload_names() -> PackedStringArray:
    var autoloads: PackedStringArray = []

    var project = ConfigFile.new()
    project.load("res://project.godot")
    if project.has_section("autoload"):
        return Array(project.get_section_keys("autoload")).filter(func(key): return key != "DialogueManager")

    return autoloads



func is_import_line(text: String) -> bool:
    return text.begins_with("import ") and " as " in text



func extract_import_path_and_name(line: String) -> Dictionary:
    var found: RegExMatch = regex.IMPORT_REGEX.search(line)
    if found:
        return {
            path = found.strings[found.names.path], 
            prefix = found.strings[found.names.prefix]
        }
    else:
        return {}



func get_indent(raw_line: String) -> int:
    var tabs: RegExMatch = regex.INDENT_REGEX.search(raw_line)
    if tabs:
        return tabs.get_string().length()
    else:
        return 0



func get_line_type(raw_line: String) -> String:
    raw_line = raw_line.strip_edges()
    var text: String = regex.WEIGHTED_RANDOM_SIBLINGS_REGEX.sub(raw_line + " ", "").strip_edges()

    if text.begins_with("import "):
        return DMConstants.TYPE_IMPORT

    if text.begins_with("#"):
        return DMConstants.TYPE_COMMENT

    if text.begins_with("~ "):
        return DMConstants.TYPE_TITLE

    if text.begins_with("if ") or text.begins_with("elif") or text.begins_with("else"):
        return DMConstants.TYPE_CONDITION

    if text.begins_with("while "):
        return DMConstants.TYPE_WHILE

    if text.begins_with("match "):
        return DMConstants.TYPE_MATCH

    if text.begins_with("when "):
        return DMConstants.TYPE_WHEN

    if text.begins_with("do ") or text.begins_with("do! ") or text.begins_with("set "):
        return DMConstants.TYPE_MUTATION

    if text.begins_with("=> ") or text.begins_with("=>< "):
        return DMConstants.TYPE_GOTO

    if text.begins_with("- "):
        return DMConstants.TYPE_RESPONSE

    if raw_line.begins_with("%") and text.is_empty():
        return DMConstants.TYPE_RANDOM

    if not text.is_empty():
        return DMConstants.TYPE_DIALOGUE

    return DMConstants.TYPE_UNKNOWN



func get_next_matching_sibling_id(siblings: Array[DMTreeLine], from_index: int, parent: DMCompiledLine, matcher: Callable, with_empty_lines: bool = false) -> String:
    for i in range(from_index + 1, siblings.size()):
        var next_sibling: DMTreeLine = siblings[i]

        if not with_empty_lines:

            if not next_sibling or next_sibling.type == DMConstants.TYPE_UNKNOWN:
                continue

        if matcher.call(next_sibling):
            return next_sibling.id


    if parent != null:
        return parent.id if parent.type == DMConstants.TYPE_WHILE else parent.next_id_after

    return DMConstants.ID_NULL



func extract_static_line_id(text: String) -> String:

    var found: RegExMatch = regex.STATIC_LINE_ID_REGEX.search(text)
    if found:
        return found.strings[found.names.id]
    else:
        return ""



func extract_condition(text: String, is_wrapped: bool, index: int) -> Dictionary:
    var regex: RegEx = regex.WRAPPED_CONDITION_REGEX if is_wrapped else regex.CONDITION_REGEX
    var found: RegExMatch = regex.search(text)

    if found == null:
        return {
            index = 0, 
            error = DMConstants.ERR_INCOMPLETE_EXPRESSION
        }

    var raw_condition: String = found.strings[found.names.expression]
    if raw_condition.ends_with(":"):
        raw_condition = raw_condition.substr(0, raw_condition.length() - 1)

    var expression: Array = expression_parser.tokenise(raw_condition, DMConstants.TYPE_CONDITION, index + found.get_start("expression"))

    if expression.size() == 0:
        return {
            index = index + found.get_start("expression"), 
            error = DMConstants.ERR_INCOMPLETE_EXPRESSION
        }
    elif expression[0].type == DMConstants.TYPE_ERROR:
        return {
            index = expression[0].index, 
            error = expression[0].value
        }
    else:
        return {
            expression = expression
        }



func extract_mutation(text: String) -> Dictionary:
    var found: RegExMatch = regex.MUTATION_REGEX.search(text)

    if not found:
        return {
            index = 0, 
            error = DMConstants.ERR_INCOMPLETE_EXPRESSION
        }

    if found.names.has("expression"):
        var expression: Array = expression_parser.tokenise(found.strings[found.names.expression], DMConstants.TYPE_MUTATION, found.get_start("expression"))
        if expression.size() == 0:
            return {
                index = found.get_start("expression"), 
                error = DMConstants.ERR_INCOMPLETE_EXPRESSION
            }
        elif expression[0].type == DMConstants.TYPE_ERROR:
            return {
                index = expression[0].index, 
                error = expression[0].value
            }
        else:
            return {
                expression = expression, 
                is_blocking = not "!" in found.strings[found.names.keyword]
            }

    else:
        return {
            index = found.get_start(), 
            error = DMConstants.ERR_INCOMPLETE_EXPRESSION
        }



func add_reference_to_title(title: String, line: DMCompiledLine) -> void :
    if title in [DMConstants.ID_END, DMConstants.ID_END_CONVERSATION, DMConstants.ID_NULL]: return

    if not _goto_lines.has(title):
        _goto_lines[title] = []
    _goto_lines[title].append(line)



func parse_children(tree_line: DMTreeLine, line: DMCompiledLine) -> Array[DMCompiledLine]:
    var children = parse_line_tree(tree_line, line)
    if children.size() > 0:
        line.next_id = children.front().id

        var last_child: DMCompiledLine = children.back()
        if last_child.next_id == DMConstants.ID_NULL:
            last_child.next_id = line.next_id_after
            if last_child.siblings.size() > 0:
                for sibling in last_child.siblings:
                    lines.get(sibling.id).next_id = last_child.next_id

    return children
