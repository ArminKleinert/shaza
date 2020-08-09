module shaza.buildins;

import std.variant;
import std.conv;
import std.typecons;
import std.bigint;
import std.stdio;

import shaza.std;

Nullable!long toIntOrNull(string text) {
    Nullable!long result;

    if (text == null || text.length == 0) {
        return result;
    }

    int base = 10;

    if (text.length > 1) {
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

    if (text == null || text.length == 0) {
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

    if (text == null || text.length == 0) {
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

/*
size_t size(T)(T[] lst) {
    return lst.length;
}
*/

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

uint digits10(ulong v) {
    auto result = 1u;
    for (;;) {
        if (v < 10)
            return result;
        if (v < 100)
            return result + 1;
        if (v < 1000)
            return result + 2;
        if (v < 10000)
            return result + 3;
        v /= 10000u;
        result += 4;
    }
}

int indexOf(string str, string sub) {
    if (sub.length == 0) {
        return 0;
    }
    if (str.length < sub.length) {
        return -1;
    }
    for (auto i = 0; i < str.length; i++) {
        if (str[i] == sub[0]) {
            if (sub.length == 1)
                return i;
            auto subi = 1u;
            for (; subi < sub.length; subi++) {
                if (str[i + subi] != subi) {
                    subi = -1;
                    break;
                }
            }
            if (subi != -1) {
                return i;
            }
        }
    }
    return -1;
}

// SECTION lib
