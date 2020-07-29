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
    auto type = ast.type;
    auto types = [
        TknType.litInt, TknType.litUInt, TknType.litBool, TknType.litString,
        TknType.litKeyword, TknType.symbol, TknType.litFlt
    ];
    foreach (TknType e; types) {
        if (type == e)
            return true;
    }
    return false;
}

string callToString(AstNode ast) {
    string fnname = ast.children[0].text;
    string result = fnname ~ "(";
    AstNode[] args = ast.children[1 .. $];
    for (int i = 0; i < args.length; i++) {
        result ~= args[i].text;
        if (i < args.length - 1)
            result ~= ",";
    }
    result ~= ")";
    return result;
}

string atomToString(AstNode ast) {
    string text = ast.text;
    if (ast.type == TknType.litBool) {
        text = text == "#t" ? "true" : "false";
    } else if (ast.type == TknType.litKeyword) {
        text ~= "Keyword(";
        text ~= ast.text;
        text ~= ")";
    }
    return text;
}

string typeToString(AstNode ast) {
    string text = ast.text;
    return text[2 .. $];
}

string typeToString(string litType) {
    return litType[2 .. $];
}

string etDefineFnToString(string type, string name, AstNode[] bindings, AstNode[] bodyNodes) {
    string result = type;
    result ~= " ";
    result ~= name;
    result ~= "(";

    // Write function argument list
    for (int i = 0; i < bindings.length; i += 2) {
        result ~= typeToString(bindings[i]); // Type
        result ~= " ";
        result ~= bindings[i + 1].text; // Name
        if (i < bindings.length - 2)
            result ~= ", ";
    }

    result ~= ") {\n";

    foreach (AstNode bodyNode; bodyNodes) {
        result ~= createOutput(bodyNode);
        result ~= ";\n";
    }

    result ~= "}\n";
    return result;
}

string etDefineToString(AstNode ast) {
    string typeText = typeToString(ast.children[1]);
    AstNode signature = ast.children[2];

    // The define seems to be defining a function
    if (signature.type == TknType.closedScope) {
        string name = signature.children[0].text;
        AstNode[] bindings = signature.children[1 .. $];
        AstNode[] rest = ast.children[3 .. $];
        return etDefineFnToString(typeText, name, bindings, rest);
    }

    string result = "";

    result ~= typeText; // Type
    result ~= " ";
    result ~= signature.text; // Value
    result ~= " = ";
    result ~= createOutput(ast.children[3]); // Value
    result ~= ";\n";

    return result;
}

string tLetBindingsToString(AstNode[] bindings) {
    if (bindings.length % 3 != 0)
        throw new CompilerError("t-let: Bindings length must be divisible by 3 (type, name, value)");

    string result = "";
    for (int i = 0; i < bindings.length; i += 3) {
        result ~= typeToString(bindings[i]); // Type
        result ~= " ";
        result ~= bindings[i + 1].text; // Name
        result ~= " = ";
        result ~= createOutput(bindings[i + 2]); // Value
        result ~= ";\n";
    }
    return result;
}

string letBindingsToString(AstNode[] bindings) {
    if (bindings.length % 2 != 0)
        throw new CompilerError("let: Bindings length must be even (name, value)");

    string result = "";
    for (int i = 0; i < bindings.length; i += 2) {
        result ~= "auto ";
        result ~= bindings[i + 0].text; // Name
        result ~= " = ";
        result ~= createOutput(bindings[i + 1]); // Value
        result ~= ";\n";
    }
    return result;
}

string letToString(AstNode ast, bool isExplicitType) {
    if (ast.children.length < 2)
        throw new CompilerError("let or t-let: Too few arguments.");
    if (ast.children[1].type != TknType.closedList)
        throw new CompilerError("let or t-let: Bindings must be a list literal.");

    AstNode[] bindings = ast.children[1].children;
    AstNode[] bodyNodes = ast.children[2 .. $];

    // "{" without a keyword before it in D source code opens a new scope
    auto result = appender!string("{");

    // Write bindings
    result ~= isExplicitType ? tLetBindingsToString(bindings) : letBindingsToString(bindings);

    // Write code
    foreach (AstNode bodyNode; bodyNodes) {
        result ~= createOutput(bodyNode);
        if (result[][$-1] == ';')result ~= ";";
        result ~= "\n";
    }

    result ~= "}";
    return result[];
}

string defineToString(AstNode ast) {
    if (ast.children[1].type == TknType.closedScope) {
        throw new CompilerError("Functions without explicit typing are not supported yet.");
    }

    string result = "";
    result ~= "auto ";
    result ~= ast.children[1].text; // Variable name
    result ~= " = ";
    result ~= createOutput(ast.children[2]); // Value
    result ~= ";\n";

    return result;
}

string importHostToString(AstNode ast) {
    auto nodes = ast.children[1 .. $];

    // Handle some errors
    if (nodes.length == 0)
        throw new CompilerError("Too few arguments for import-host.");
    if (nodes[0].type != TknType.symbol || nodes[0].type != TknType.litString)
        throw new CompilerError("import-host: Module name must be string or symbol.");

    // Parse name of import
    string nameText = nodes[0].text;
    nameText = nodes[0].type == TknType.litString ? nameText[1 .. $ - 1] : nameText;

    if (nodes.length == 1) {
        // Normal import
        return "import " ~ nameText ~ ";";
    } else if (nodes.length == 2) {
        // Import only specific list of functions.
        if (nodes[1].type != TknType.closedList || nodes[1].type != TknType.closedScope)
            throw new CompilerError(
                    "import-host: list of imported functions must be a list. '(...)' or '[...]'");

        // Build output string
        string result = "import " ~ nameText ~ " : ";
        for (int i = 0; i < nodes[1].children.length; i++) {
            result ~= nodes[i].text;
            if (i != nodes[i].children.length - 1)
                result ~= ",";
        }
        result ~= ";\n";
        return result;
    } else {
        // Too many arguments
        throw new CompilerError("import-host: Too many arguments.");
    }
}

string listLiteralToString(AstNode ast) {
    if (ast.children.length == 0)
        return "[]"; // Empty list

    string result = "[";
    for (int i = 0; i < ast.children.length; i++) {
        result ~= ast.children[i].text;
        if (i != ast.children[i].children.length - 1)
            result ~= ",";
    }
    result ~= "]";
    return result;
}

string setvToString(AstNode ast) {
    if (ast.children.length != 3)
        throw new CompilerError("setv! requires exactly 2 arguments!");
    string result = ast.children[1].text;
    result ~= " = ";
    result ~= createOutput(ast.children[2]);
    if (result[$ - 1] != ';')
        result ~= ";";
    return result;
}

string createOutput(AstNode ast) {
    /*
    writeln(isAtom(ast));
    writeln(ast.type == TknType.closedTaggedList || ast.type == TknType.closedList);
    writeln(ast.type == TknType.closedScope);
    Token fTkn = ast.children[0].tkn;
    writeln(fTkn.type == TknType.symbol);
    writeln(fTkn.text == "et-define");
    */

    if (isAtom(ast)) {
        return atomToString(ast);
    }

    if (ast.type == TknType.closedTaggedList || ast.type == TknType.closedList) {
        return listLiteralToString(ast);
    }

    if (ast.type == TknType.closedScope) {
        Token firstTkn = ast.children[0].tkn;
        if (firstTkn.type == TknType.symbol) {
            if (firstTkn.text == "define") {
                return defineToString(ast);
            } else if (firstTkn.text == "et-define") {
                return etDefineToString(ast);
            } else if (firstTkn.text == "define-macro") {
                // TODO
            } else if (firstTkn.text == "define-tk-macro") {
                // TODO
            } else if (firstTkn.text == "let") {
                return letToString(ast, false);
            } else if (firstTkn.text == "t-let") {
                return letToString(ast, true);
            } else if (firstTkn.text == "setv!") {
                return setvToString(ast);
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
            } else if (firstTkn.text == "import-host") {
                importHostToString(ast);
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
