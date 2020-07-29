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
    auto result = appender!string(fnname ~ "(");
    AstNode[] args = ast.children[1 .. $];

    for (int i = 0; i < args.length; i++) {
        result ~= createOutput(args[i]);
        if (i < args.length - 1)
            result ~= ",";
    }
    result ~= ")";
    return result.get();
}

string atomToString(AstNode ast) {
    auto text = appender(ast.text);

    if (ast.type == TknType.litBool) {
        text = appender(ast.text == "#t" ? "true" : "false");
    } else if (ast.type == TknType.litKeyword) {
        text ~= "Keyword(";
        text ~= ast.text;
        text ~= ")";
    }

    return text.get();
}

string typeToString(AstNode ast) {
    string text = ast.text;
    return text[2 .. $];
}

string typeToString(string litType) {
    return litType[2 .. $];
}

string etDefineFnToString(Appender!string result, string type, string name, AstNode[] bindings, AstNode[] bodyNodes) {
    result ~= "(";

    // Write function argument list
    for (int i = 0; i < bindings.length; i += 2) {
        string argTypeStr = bindings[i].text;
        if (bindings[i].type == TknType.litString)
            result ~= argTypeStr[1..$-1];
        else
            result ~= typeToString(bindings[i]); // Type

        result ~= " ";
        result ~= bindings[i + 1].text; // Name
        if (i < bindings.length - 2)
            result ~= ", ";
    }

    result ~= ") {\n";

    // If the body is empty, return the default value of the return-type
    // or, if the type is void, leave an empty body
    if (bodyNodes.length == 0) {
        if (type == "void") return result.get();
        result ~= "return ";
        result ~= type;
        result ~= ".init;";
        return result.get();
    }

    // Write all but the last statement
    foreach (AstNode bodyNode; bodyNodes[0..$-1]) {
        result ~= createOutput(bodyNode);
        if (result[][$-1] != ';') result ~= ";";
        result ~= "\n";
    }

    AstNode lastStmt = bodyNodes[bodyNodes.length - 1];

    // If the last node in the body is
    if (type != "void"
        && (lastStmt.type == TknType.closedScope
            && lastStmt.children[0].text != "return"
            && lastStmt.children[0].text != "let"
            && lastStmt.children[0].text != "define")
        || isAtom(lastStmt))
        result ~= "return ";

    result ~= createOutput(lastStmt);
    result ~= ";\n";

    result ~= "}\n";
    return result.get();
}

string etDefineToString(AstNode ast) {
    string typeText = typeToString(ast.children[1]);
    AstNode signature = ast.children[2];

    auto result = appender!string(typeText);
    result ~= " ";

    // The define seems to be defining a function
    if (signature.type == TknType.closedScope) {
        string name = signature.children[0].text;
        result ~= name;
        AstNode[] bindings = signature.children[1 .. $];
        AstNode[] rest = ast.children[3 .. $];
        return etDefineFnToString(result, typeText, name, bindings, rest);
    }

    result ~= signature.text; // Name
    result ~= " = ";
    result ~= createOutput(ast.children[3]); // Value
    result ~= ";\n";

    return result.get();
}

string genDefineToString(AstNode ast) {
    string type = typeToString(ast.children[1]);
    AstNode[] generics = ast.children[2].children;
    string name = ast.children[3].children[0].text;
    AstNode[] bindings = ast.children[3].children[1 .. $];
    AstNode[] bodyNodes = ast.children[4 .. $];

    auto result = appender!string(type);
    result ~= " ";
    result ~= name;
    result ~= "(";

    for (int i = 0; i < generics.length; i ++) {
        result ~= generics[i].text; // Type
        if (i < generics.length - 1)
            result ~= ", ";
    }

    result ~= ")";
    return etDefineFnToString(result, type, name, bindings, bodyNodes);
}

string tLetBindingsToString(AstNode[] bindings) {
    if (bindings.length % 3 != 0)
        throw new CompilerError("t-let: Bindings length must be divisible by 3 (type, name, value)");

    auto result = appender!string("");
    for (int i = 0; i < bindings.length; i += 3) {
        result ~= typeToString(bindings[i]); // Type
        result ~= " ";
        result ~= bindings[i + 1].text; // Name
        result ~= " = ";
        result ~= createOutput(bindings[i + 2]); // Value
        result ~= ";\n";
    }
    return result.get();
}

string letBindingsToString(AstNode[] bindings) {
    if (bindings.length % 2 != 0)
        throw new CompilerError("let: Bindings length must be even (name, value)");

    auto result = appender!string("");
    for (int i = 0; i < bindings.length; i += 2) {
        result ~= "auto ";
        result ~= bindings[i + 0].text; // Name
        result ~= " = ";
        result ~= createOutput(bindings[i + 1]); // Value
        result ~= ";\n";
    }
    return result.get();
}

string letToString(AstNode ast, bool isExplicitType) {
    if (ast.children.length < 2)
        throw new CompilerError("let or t-let: Too few arguments.");
    if (ast.children[1].type != TknType.closedList)
        throw new CompilerError("let or t-let: Bindings must be a list literal.");

    AstNode[] bindings = ast.children[1].children;
    AstNode[] bodyNodes = ast.children[2 .. $];

    // "{" without a keyword before it in D source code opens a new scope
    auto result = appender!string("{\n");

    // Write bindings
    result ~= isExplicitType ? tLetBindingsToString(bindings) : letBindingsToString(bindings);

    // Write code
    foreach (AstNode bodyNode; bodyNodes) {
        result ~= createOutput(bodyNode);
        if (result[][$ - 1] == ';')
            result ~= ";";
        result ~= "\n";
    }

    result ~= "}";
    return result[];
}

string defineToString(AstNode ast) {
    if (ast.children[1].type == TknType.closedScope) {
        throw new CompilerError("Functions without explicit typing are not supported yet.");
    }

    auto result = appender!string("");
    result ~= "auto ";
    result ~= ast.children[1].text; // Variable name
    result ~= " = ";
    result ~= createOutput(ast.children[2]); // Value
    result ~= ";\n";
    return result.get();
}

string importHostToString(AstNode ast) {
    auto nodes = ast.children[1 .. $];

    // Handle some errors
    if (nodes.length == 0)
        throw new CompilerError("Too few arguments for import-host.");
    if (nodes[0].type != TknType.symbol && nodes[0].type != TknType.litString) {
        throw new CompilerError("import-host: Module name must be string or symbol.");
    }

    // Parse name of import
    string nameText = nodes[0].text;
    nameText = nodes[0].type == TknType.litString ? nameText[1 .. $ - 1] : nameText;

    if (nodes.length == 1) {
        // Normal import
        return "import " ~ nameText ~ ";";
    } else if (nodes.length == 2) {
        // Import only specific list of functions.
        if (nodes[1].type != TknType.closedList && nodes[1].type != TknType.closedScope)
            throw new CompilerError(
                    "import-host: list of imported functions must be a list. '(...)' or '[...]'");

        // Build output string
        auto result = appender!string("import ");
        result ~= nameText;
        result ~= " : ";

        for (int i = 0; i < nodes[1].children.length; i++) {
            result ~= nodes[1].children[i].text;
            if (i != nodes[1].children.length - 1)
                result ~= ",";
        }
        result ~= ";";
        return result.get();
    } else {
        // Too many arguments
        throw new CompilerError("import-host: Too many arguments.");
    }
}

string listLiteralToString(AstNode ast) {
    if (ast.children.length == 0)
        return "[]"; // Empty list

    auto result = appender!string("[");
    for (int i = 0; i < ast.children.length; i++) {
        result ~= ast.children[i].text;
        if (i != ast.children[i].children.length - 1)
            result ~= ",";
    }
    result ~= "]";
    return result.get();
}

string setvToString(AstNode ast) {
    if (ast.children.length != 3)
        throw new CompilerError("setv! requires exactly 2 arguments!");
    auto result = appender!string(ast.children[1].text);
    result ~= " = ";
    result ~= createOutput(ast.children[2]);
    if (result[][$ - 1] != ';')
        result ~= ";";
    return result.get();
}

void llToStringSub(Appender!string result, AstNode ast) {
    if (ast.type == TknType.closedList || ast.type == TknType.closedTaggedList) {
        result ~= ast.text; // Empty for closedList, list tag for closedTaggedList
        result ~= '[';
        foreach (AstNode child; ast.children) {
            llToStringSub(result, child);
        }
        result ~= ']';
    } else if (ast.type == TknType.closedScope) {
        result ~= '(';
        foreach (AstNode child; ast.children) {
            llToStringSub(result, child);
        }
        result ~= ')';
    } else {
        result ~= ast.text;
        foreach (AstNode child; ast.children) {
            llToStringSub(result, child);
        }
    }
}

string llToString(AstNode ast) {
    auto result = appender("");
    foreach (AstNode child; ast.children[1 .. $]) {
        if (child.type == TknType.litString) {
            result ~= child.text[1 .. $ - 1];
        } else {
            llToStringSub(result, child);
        }
    }
    return result.get();
}

string ifToString(AstNode ast) {
    AstNode condition = ast.children[1];
    AstNode branchThen = ast.children[2];
    AstNode branchElse = ast.children[3];
    auto result = appender("");
    result ~= "if(";
    result ~= createOutput(condition);
    result ~= ") {\n";
    result ~= createOutput(branchThen);
    result ~= "} else {\n";
    result ~= createOutput(branchElse);
    result ~= "}";
    return result.get();
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
            switch (firstTkn.text) {
            case "define":
                return defineToString(ast);
            case "et-define":
                return etDefineToString(ast);
            case "gen-define":
                return genDefineToString(ast);
            case "define-macro":
                break; // TODO
            case "define-tk-macro":
                break; // TODO
            case "let":
                return letToString(ast, false);
            case "t-let":
                return letToString(ast, true);
            case "setv!":
                return setvToString(ast);
            case "ll":
                return llToString(ast);
            case "if":
                return ifToString(ast);
            case "lambda":
                break; // TODO
            case "t-lambda":
                break; // TODO
            case "def-struct":
                break; // TODO
            case "struct":
                break; // TODO
            case "cast":
                break; // TODO
            case "convert":
                break; // TODO
            case "import-sz":
                break; // TODO
            case "import-host":
                return importHostToString(ast);
            case "rt-import-sz":
                break; // TODO
            case "rt-import-dll":
                break; // TODO
            case "call-extern":
                break; // TODO
            case "call-sys":
                break; // TODO
            case "recur":
                break; // TODO
            case "mut":
                break; // TODO
            case "alloc":
                break; // TODO
            case "set!":
                break; // TODO
            case "get!":
                break; // TODO
            case "free":
                break; // TODO
            case "pointerto":
                break; // TODO
            case "deref":
                break; // TODO
            case "quote":
                break; // TODO
            case "pseudo-quote":
                break; // TODO
            case "unquote":
                break; // TODO
            default:
                return callToString(ast);
            }
        } else {
            writeln("Error? " ~ to!string(ast));
        }
    }

    if (ast.type == TknType.root) {
        auto result = "";
        foreach(AstNode child; ast.children) {
            result ~= createOutput(child);
        }
        return result;
    }

    return "";
}
