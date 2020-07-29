module shaza.buildins;

import std.variant;
import std.conv;
import std.typecons;

import shaza.std;

Nullable!long toIntOrNull(string text) {
    Nullable!long result;

    if (text == null || text.size == 0) {
        return result;
    }

    int base = 10;

    if (text.size > 1) {
        if (text[0] == '+' || text[0] == '-') {
            text = text[1 .. $]; // Cut prefix
        }

        if (text[0] == '0') {
            import std.stdio;

            bool hasBasePrefix = true;
            switch (text[1]) {
            case 'x':
                base = 16;
                break;
            case 'b':
                base = 2;
                break;
            case 'o':
                base = 8;
                break;
            case 'd':
                base = 10;
                break;
            default:
                base = 10;
                hasBasePrefix = false;
                break;
            }
            if (hasBasePrefix) {
                text = text[2 .. $];
            }
        }
    }

    try {
        result = to!long(text, base);
    } catch (ConvException ce) {
    }

    return result;
}

Nullable!ulong toUIntOrNull(string text) {
    Nullable!ulong result;

    if (text == null || text.size == 0) {
        return result;
    }
    if (text[$ - 1] == 'u') {
        text = text[0 .. $ - 1];
    }

    Nullable!long temp = toIntOrNull(text);
    if (!temp.isNull()) {
        result = cast(ulong) temp.get();
    }

    return result;
}

Nullable!double toFloatOrNull(string text) {
    Nullable!double result;

    if (text == null || text.size == 0) {
        return result;
    }
    if (text[$ - 1] == 'f') {
        text = text[0 .. $ - 1];
    }

    try {
        result = to!double(text);
    } catch (ConvException ce) {
    }
    return result;
}

size_t size(T)(T[] lst) {
    return lst.length;
}

bool contains(T)(T[] list, T o) {
    return indexof(list, o) != -1;
}

int indexof(T)(T[] list, T o) {
    for (int i = 0; i < list.size; i++) {
        if (list[i] == 0)
            return i;
    }
    return -1;
}

O reduce(T, O)(T[] coll, O initVal, O function(O, T) fn) {
    O output = initVal;
    foreach(T current; coll) {
        output = fn(output, current);
    }
    return output;
}

// SECTION lib
