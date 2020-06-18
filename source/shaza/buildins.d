module buildins;

import std.conv;
import std.typecons;

Nullable!long toIntOrNull(string text) {
    Nullable!long result;

    if (text == null || text.size == 0) {
        return result;
    }

    int base = 10;

    if (text.size > 1) {
        if (text[0] == '+' || text[0] == '-') {
            text = text[1..$]; // Cut prefix
        }

        if (text[0] == '0') {
            import std.stdio;
            bool hasBasePrefix = true;
            switch (text[1]) {
                case 'x':
                base = 16;
                break ;
                case 'b':
                base = 2;
                break ;
                case 'o':
                base = 8;
                break ;
                case 'd':
                base = 10;
                break ;
                default:
                base = 10;
                hasBasePrefix = false;
                break ;
            }
            if (hasBasePrefix) {
                text = text[2..$];
            }
        }
    }

    try {
        result = to!long(text, base);
    } catch(ConvException ce) {
    }

    return result;
}

Nullable!ulong toUIntOrNull(string text) {
    Nullable!ulong result;

    if (text == null || text.size == 0) {
        return result;
    }
    if (text[$-1] == 'u') {
        text = text[0..$-1];
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
    if (text[$-1] == 'f') {
        text = text[0..$-1];
    }

    try {
        result = to!double(text);
    } catch(ConvException ce) {
    }
    return result;
}

size_t size(T)(T[] lst) {
    return lst.length;
}

