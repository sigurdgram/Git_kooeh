



















































static func named_parameters(names, values):
    var named = []
    for i in range(values.size()):
        var entry = {}

        var parray = values[i]
        if (typeof(parray) != TYPE_ARRAY):
            parray = [values[i]]

        for j in range(names.size()):
            if (j >= parray.size()):
                entry[names[j]] = null
            else:
                entry[names[j]] = parray[j]
        named.append(entry)

    return named
