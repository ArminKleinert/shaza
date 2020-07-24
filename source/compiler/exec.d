module compiler.exec;

import std.variant;
import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;

import compiler.types;
import shaza.buildins;
import shaza.std;

Variable tokenToAtom(Token tkn) {
    switch(tkn.type) {
        case TknType.litInt: return variable(to!long(tkn.text));
        case TknType.litUInt: return variable(to!ulong(tkn.text));
        case TknType.litFlt: return variable(to!double(tkn.text));
        case TknType.litKeyword: return variable(Keyword(tkn.text));
        case TknType.litType: return variable(ClassKeyword(tkn.text));
        case TknType.litString: return variable(tkn.text);
        case TknType.litBool: return variable(tkn.text == "#t");
        case TknType.symbol : return variable(tkn.text);
        default : throw new CompilerError("Error converting " ~ to!string(tkn));
    }
}

Variable exec_define(AstNode ast) {
    /*
    if (ast.children.size == 3) {
        shaza_define( ast.children[1].tkn.text, execScope( ast.children[2]));
    } else {
        // shaza_define_function(ast.children[1].tkn.text, execScope(ast.children[2]), )
    }
    */
    return variable("");
}

Variable execCommand(AstNode ast) {
    string command = ast.children[0].tkn.text;
    SzFunction fn = Namespace.globalNs.findFn(command);

    if (fn is null) { throw new CompilerError("Function not found: " ~ ast.children[0].tkn.text); }

    if (fn.numParams == 0) { return fn(); }

    Variable[] args = [];
    foreach (AstNode child; ast.children[1..$]) {
        Variable temp = exec(child);
        if (temp.peek!(Symbol) !is null) { temp = Namespace.globalNs.find(temp.get!(Symbol).name); }
        args ~= exec(child);
    }

    return fn(args);
}

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
    || text == "bit-xor";
}

bool isBoolOp(string text) {
    return text == "and" || text == "or" || text == "xor"
    || text == "lsp-and" || text == "lsp-or" || text == "lsp-xor";
}

bool isAtom(AstNode ast) {
    auto type = ast.tkn.type;
    return [ TknType.litInt, TknType.litUInt, TknType.litBool, TknType.litString,
    TknType.litKeyword, TknType.symbol, TknType.litFlt, TknType.litType].contains( type);
}

Variable parseAtom(AstNode ast) {
    return variable(tokenToAtom(ast.tkn));
}

Variable parseList(AstNode ast) {
    // TODO
    return variable(SzNull.get);
}

Variable exec(AstNode ast) {
    if (isAtom( ast)) {
        return parseAtom( ast);
    }

    if (ast.tkn.type == TknType.closedTaggedList
    || ast.tkn.type == TknType.closedList) {
        return parseList( ast);
    }

    if (ast.tkn.type == TknType.closedScope) {
        Token firstTkn = ast.children[0].tkn;
        if (firstTkn.type == TknType.symbol) {
            if (firstTkn.text == "define") {
                return exec_define( ast);
                /*
        } else if (firstTkn.text == "et-define") {
            exec_et_define( ast);
        } else if (firstTkn.text == "define-macro") {
            exec_define_macro( ast);
        } else if (firstTkn.text == "define-tk-macro") {
            exec_define_tk_macro( ast);
        } else if (firstTkn.text == "lambda") {
            make_lambda( ast);
        } else if (firstTkn.text == "t-lambda") {
            make_t_lambda( ast);
        } else if (firstTkn.text == "def-struct") {
            exec_def_struct( ast);
        } else if (firstTkn.text == "struct") {
            exec_make_struct( ast);
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
        */
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
            //} else if (isTypedMathOp( firstTkn.text)) {
            //    return execCommand( ast);
            //} else if (isMathOp( firstTkn.text)) {
            //    return execCommand( ast);
            //} else if (isBoolOp( firstTkn.text)) {
            //    return execCommand( ast);
            } else {
                return execCommand( ast);
            }
        } else {
            writeln( "Error? " ~ to!string( ast));
        }
    }

    writeln( "Error2? " ~ to!string( ast));

    return variable(SzNull.get);
}
