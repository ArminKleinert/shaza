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


/*
bool isTypedMathOp(string text) {
    return text == "+'" || text == "-'" || text == "*'"
    || text == "/'" || text == "%'" || text == "<<'"
    || text == ">>'" || text == "bit-and'" || text == "bit-or'"
    || text == "bit-xor'" ;
}

bool isMathOp(string text) {
    return text == "+" || text == "-" || text == "*"
    || text == "/" || text == "%" || text == "<<"
    || text == ">>" || text == "bit-and" || text == "bit-or"
    || text == "bit-xor" ;
}

bool isBoolOp(string text) {
    return text == "and" || text == "or" || text == "xor"
    || text == "lsp-and" || text == "lsp-or" || text == "lsp-xor";
}

void writeScope(File f, AstNode ast) {
    Token firstTkn = ast.children[0].tkn;
    if (firstTkn.type == TknType.symbol) {
        if (firstTkn.text == "define") {
            writeDefineCall( f, ast);
        }else if (firstTkn.text == "et-define") {
            writeEtDefineCall( f, ast);
        } else if (firstTkn.text == "define-macro") {
            writeDefineMacro( f, ast);
        } else if (firstTkn.text == "define-tk-macro") {
            writeDefineTkMacro( f, ast);
        } else if (firstTkn.text == "lambda") {
            // TODO
        } else if (firstTkn.text == "t-lambda") {
            // TODO
        } else if (firstTkn.text == "def-struct") {
            // TODO
        } else if (firstTkn.text == "struct") {
            // TODO
        } else if (firstTkn.text == "cast") {
            // TODO
        } else if (firstTkn.text == "convert") {
            // TODO
        } else if (firstTkn.text == "car") {
            // TODO
        } else if (firstTkn.text == "cdr") {
            // TODO
        } else if (firstTkn.text == "coll") {
            // TODO
        } else if (firstTkn.text == "import-sz") {
            // TODO
        } else if (firstTkn.text == "rt-import-sz") {
            // TODO
        } else if (firstTkn.text == "rt-import-dll") {
            // TODO
        } else if (firstTkn.text == "call-extern") {
            // TODO
        } else if (firstTkn.text == "call-sys") {
            // TODO
        } else if (firstTkn.text == "recur") {
            // TODO
        } else if (firstTkn.text == "mut") {
            // TODO
        } else if (firstTkn.text == "alloc") {
            // TODO
        } else if (firstTkn.text == "set!") {
            // TODO
        } else if (firstTkn.text == "get!") {
            // TODO
        } else if (firstTkn.text == "free") {
            // TODO
        } else if (firstTkn.text == "pointerto") {
            // TODO
        } else if (firstTkn.text == "quote") {
            // TODO
        } else if (firstTkn.text == "pseudo-quote") {
            // TODO
        } else if (firstTkn.text == "unquote") {
            // TODO
        } else if (isTypedMathOp(firstTkn.text)) {
            // TODO
        } else if (isMathOp(firstTkn.text)) {
            // TODO
        } else if (isBoolOp(firstTkn.text)) {
            // TODO
        }
*/