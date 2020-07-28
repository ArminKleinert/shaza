module compiler.exec;

import std.variant;
import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;
import std.array;

import compiler.types;
import shaza.buildins;
import shaza.std;

class OutputContext {
    private string[] globals;
    private Appender!(string[]) scopes;
    private string currentScopeString;

    public this() {
        globals = [];
        string[] scopes;
        this.scopes = appender(scopes);
        currentScopeString = "";
    }

    OutputContext append(string text) {
        currentScopeString ~= text;
        return this;
    }

    OutputContext closeScope() {
        scopes ~= currentScopeString;
        currentScopeString = "";
        return this;
    }

    OutputContext addGlobal(string name) {
        globals ~= name;
        return this;
    }

    string getString() {
        string s = "";
        foreach (string s1; scopes) {
            s ~= s1;
        }
        return s;
    }
}

static const OutputContext globalOutputContext = new OutputContext();

bool isTypedMathOp(string text) {
    return text == "+'" || text == "-'" || text == "*'" || text == "/'" || text == "%'"
        || text == "<<'" || text == ">>'" || text == "bit-and'"
        || text == "bit-or'" || text == "bit-xor'";
}

bool isMathOp(string text) {
    return text == "+" || text == "-" || text == "*" || text == "/" || text == "%"
        || text == "<<" || text == ">>" || text == "bit-and" || text == "bit-or" || text == "bit-xor";
}

bool isBoolOp(string text) {
    return text == "and" || text == "or" || text == "xor" || text == "lsp-and"
        || text == "lsp-or" || text == "lsp-xor";
}

bool isAtom(AstNode ast) {
    auto type = ast.tkn.type;
    return [
        TknType.litInt, TknType.litUInt, TknType.litBool, TknType.litString,
        TknType.litKeyword, TknType.symbol, TknType.litFlt
    ].contains(type);
}

string callToString(AstNode ast) {
    //TODO
    return "";
}

string atomToString(AstNode ast) {
    string text = ast.tkn.text;
    if (ast.tkn.type == TknType.litBool) {
        text = text == "#t" ? "true" : "false";
    } else if (ast.tkn.type == TknType.litKeyword) {
        text ~= "Keyword(";
        text ~= ast.tkn.text;
        text ~= ")";
    }
    return text;
}

string typeKeywordToString(AstNode ast) {
    string text = ast.tkn.text;
    return text[2 .. $];
}

string etDefineToString(AstNode ast) {
    //TODO
    return "";
}

string listLiteralToString(AstNode ast) {
    //TODO
    return "";
}

string createOutput(AstNode ast) {
    if (isAtom(ast)) {
        return atomToString(ast);
    }

    if (ast.tkn.type == TknType.closedTaggedList || ast.tkn.type == TknType.closedList) {
        return listLiteralToString(ast);
    }

    if (ast.tkn.type == TknType.closedScope) {
        Token firstTkn = ast.children[0].tkn;
        if (firstTkn.type == TknType.symbol) {
            if (firstTkn.text == "define") {
                // TODO
            } else if (firstTkn.text == "et-define") {
                return etDefineToString(ast);
            } else if (firstTkn.text == "define-macro") {
                // TODO
            } else if (firstTkn.text == "define-tk-macro") {
                // TODO
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
            } else {
                return callToString(ast);
            }
        } else {
            writeln("Error? " ~ to!string(ast));
        }
    }

    return "";
}
