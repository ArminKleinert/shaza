module compiler.output;

import std.variant;
import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;
import std.array;

import compiler.types;
import compiler.ast;
import shaza.buildins;
import shaza.std;

struct FunctionDecl {
    const string name;
    const string returnType;
    const immutable(string)[] genericTypes;
    const immutable(string)[] argTypes;

    this(string name, string returnType, const immutable(string)[] genericTypes,
            const immutable(string)[] argTypes) {
        this.name = name;
        this.returnType = returnType;
        this.genericTypes = genericTypes;
        this.argTypes = argTypes;
    }
}

class OutputContext {
    private string[] globals;
    private FunctionDecl[] _functions;
    private static FunctionDecl NO_FUNCTION;

    private __gshared OutputContext _global;

    static this() {
        NO_FUNCTION = FunctionDecl(null, null, null, null);
    }

    this() {
        globals = [];
        _functions = [];
    }

    public static OutputContext global() {
        if (_global is null)
            _global = new OutputContext();
        return _global;
    }

    public void addFunc(string name, string returnType, string[] genericTypes, string[] argTypes) {
        immutable(string)[] args = argTypes.dup;
        immutable(string)[] gens = genericTypes.dup;
        _functions ~= FunctionDecl(name, returnType, gens, args);
    }

    public void addFunc(string name, string returnType, string[] argTypes) {
        immutable(string)[] args = argTypes.dup;
        _functions ~= FunctionDecl(name, returnType, [], args);
    }

    public void addFunc(string name, string returnType) {
        _functions ~= FunctionDecl(name, returnType, [], []);
    }

    public string[] functions() {
        string[] names;
        foreach (fn; _functions) {
            names ~= fn.name;
        }
        return names;
    }

    public string returnTypeOf(string functionName) {
        return findFn(functionName).returnType;
    }

    public immutable(string)[] argumentsOf(string functionName) {
        return findFn(functionName).argTypes;
    }

    public string[] listFunctions() {
        string[] fns;
        string current;
        foreach (fn; _functions) {
            current = fn.returnType;
            current ~= ' ';
            current ~= fn.name;
            current ~= '(';
            current ~= to!string(fn.genericTypes)[1 .. $ - 1];
            current ~= ")(";
            current ~= to!string(fn.argTypes)[1 .. $ - 1];
            current ~= ')';
            fns ~= current;
        }
        return fns;
    }

    public string listFunctionsAsString() {
        auto fns = listFunctions();
        string res = "";
        foreach (fn; fns) {
            res ~= fn ~ "\n";
        }
        return res;
    }

    private FunctionDecl findFn(string name) {
        foreach (fn; _functions) {
            if (fn.name == name)
                return fn;
        }
        return NO_FUNCTION;
    }

}

string callToString(AstNode ast) {
    string fnname = ast.children[0].text;
    auto result = appender!string(szNameToHostName(fnname));
    result ~= '(';
    AstNode[] args = ast.children[1 .. $];

    for (int i = 0; i < args.length; i++) {
        result ~= createOutput(args[i]);
        if (i < args.length - 1)
            result ~= ", ";
    }
    result ~= ')';
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

string szNameToHostName(string szVarName) {
    if (szVarName[$ - 1] == '?')
        return szVarName[0 .. $ - 1] ~ "_Q";
    else if (szVarName[$ - 1] == '!')
        return szVarName[0 .. $ - 1] ~ "_E";
    else
        return szVarName;
}

string typeToString(AstNode ast) {
    import core.exception;

    try {
        return typeToString(ast.text);
    } catch (RangeError re) {
        writeln(ast.toString());
        throw re;
    }
}

string typeToString(string litType) {
    if (litType[0 .. 2] == "::")
        litType = litType[2 .. $];
    if (litType[0] == '"' && litType[litType.length - 1] == '"')
        litType = litType[1 .. $ - 1];
    return litType;
}

string functionBindingsToString(Appender!string result, AstNode[] bindings) {
    result ~= "(";

    // Write function argument list
    for (int i = 0; i < bindings.length; i++) {
        result ~= szNameToHostName(bindings[i].text); // Name
        if (i < bindings.length - 1)
            result ~= ", ";
    }

    result ~= ")";
    return result.get();
}

string typedFunctionBindingsToString(Appender!string result, AstNode[] bindings) {
    result ~= "(";

    // Write function argument list
    for (int i = 0; i < bindings.length; i += 2) {
        result ~= typeToString(bindings[i]);

        result ~= " ";
        result ~= szNameToHostName(bindings[i + 1].text); // Name
        if (i < bindings.length - 2)
            result ~= ", ";
    }

    result ~= ")";
    return result.get();
}

string functionBodyToString(Appender!string result, string fnType,
        AstNode[] bindings, AstNode[] bodyNodes, bool withLineBreaks) {
    result ~= '{';
    if (withLineBreaks)
        result ~= '\n';

    // If the body is empty, return the default value of the return-type
    // or, if the type is void, leave an empty body
    if (bodyNodes.length == 0) {
        if (fnType == "void")
            return result.get();
        result ~= "return ";
        result ~= fnType;
        result ~= ".init;";
        return result.get();
    }

    // Write all but the last statement
    foreach (AstNode bodyNode; bodyNodes[0 .. $ - 1]) {
        result ~= createOutput(bodyNode);
        if (result[][$ - 1] != ';')
            result ~= ';';
        if (withLineBreaks)
            result ~= '\n';
    }

    AstNode lastStmt = bodyNodes[bodyNodes.length - 1];

    // If the last node in the body is
    if (fnType != "void" && (lastStmt.type == TknType.closedScope
            && lastStmt.children[0].text != "return" && lastStmt.children[0].text != "let"
            && lastStmt.children[0].text != "define"
            && lastStmt.children[0].text != "if" && lastStmt.children[0].text != "for"
            && lastStmt.children[0].text != "foreach") || isAtom(lastStmt))
        result ~= "return ";

    result ~= createOutput(lastStmt);
    result ~= ';';
    if (withLineBreaks)
        result ~= '\n';

    result ~= '}';
    if (withLineBreaks)
        result ~= '\n';
    return result.get();
}

string etDefineFnToString(Appender!string result, string type, AstNode[] bodyNodes) {
    result ~= "{\n";

    // If the body is empty, return the default value of the return-type
    // or, if the type is void, leave an empty body
    if (bodyNodes.length == 0) {
        if (type == "void")
            return result.get();
        result ~= "return ";
        result ~= type;
        result ~= ".init;";
        return result.get();
    }

    // Write all but the last statement
    foreach (AstNode bodyNode; bodyNodes[0 .. $ - 1]) {
        result ~= createOutput(bodyNode);
        if (result[][$ - 1] != ';' && result[][$ - 1] != '}')
            result ~= ';';
        result ~= '\n';
    }

    AstNode lastStmt = bodyNodes[bodyNodes.length - 1];

    // If the last node in the body is
    if (type != "void" && (lastStmt.type == TknType.closedScope
            && lastStmt.children[0].text != "return" && lastStmt.children[0].text != "let"
            && lastStmt.children[0].text != "define"
            && lastStmt.children[0].text != "if" && lastStmt.children[0].text != "for"
            && lastStmt.children[0].text != "foreach") || isAtom(lastStmt))
        result ~= "return ";

    result ~= createOutput(lastStmt);
    if (result[][$ - 1] != ';' && result[][$ - 1] != '}')
        result ~= ";\n";

    result ~= "}\n";
    return result.get();
}

void addFunctionFromAst(string name, AstNode typeNode, AstNode[] generics, AstNode[] bindings) {
    string type = typeToString(typeNode);
    addFunctionFromAst(name, type, generics, bindings);
}

void addFunctionFromAst(string name, string type, AstNode[] generics, AstNode[] bindings) {
    string[] genericTypes;

    for (int i = 0; i < generics.length; i++) {
        genericTypes ~= generics[i].text; // Type
    }

    string[] args;

    for (int i = 0; i < bindings.length; i += 2) { // +2 skips name
        string argTypeStr = bindings[i].text;
        if (bindings[i].type == TknType.litString)
            args ~= argTypeStr[1 .. $ - 1];
        else
            args ~= typeToString(bindings[i]);
    }

    if (OutputContext.global)
        OutputContext.global.addFunc(name, type, genericTypes, args);
}

string etDefineToString(AstNode ast) {
    string typeText = typeToString(ast.children[1]);
    AstNode signature = ast.children[2];

    auto result = appender!string(typeText);
    result ~= " ";

    // The define seems to be defining a function
    if (signature.type == TknType.closedScope) {
        string name = signature.children[0].text;
        result ~= szNameToHostName(name);
        AstNode[] bindings = signature.children[1 .. $];
        AstNode[] rest = ast.children[3 .. $];
        typedFunctionBindingsToString(result, bindings);

        addFunctionFromAst(name, typeText, [], bindings);

        return etDefineFnToString(result, typeText, rest);
    }

    result ~= szNameToHostName(signature.text); // Name
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

    addFunctionFromAst(name, type, generics, bindings);

    auto result = appender!string(type);
    result ~= " ";
    result ~= szNameToHostName(name);
    result ~= "(";

    for (int i = 0; i < generics.length; i++) {
        result ~= generics[i].text; // Type
        if (i < generics.length - 1)
            result ~= ", ";
    }

    result ~= ")";
    typedFunctionBindingsToString(result, bindings);
    return etDefineFnToString(result, type, bodyNodes);
}

string tLetBindingsToString(AstNode[] bindings) {
    if (bindings.length % 3 != 0)
        throw new CompilerError("t-let: Bindings length must be divisible by 3 (type, name, value)");

    auto result = appender!string("");
    for (int i = 0; i < bindings.length; i += 3) {
        result ~= typeToString(bindings[i]); // Type
        result ~= " ";
        result ~= szNameToHostName(bindings[i + 1].text); // Name
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
        result ~= szNameToHostName(bindings[i + 0].text); // Name
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
    result ~= szNameToHostName(ast.children[1].text); // Variable name
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
            if (i < nodes[1].children.length - 1)
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
        if (i < ast.children[i].children.length - 1)
            result ~= ",";
    }
    result ~= "]";
    return result.get();
}

string setvToString(AstNode ast) {
    if (ast.children.length != 3)
        throw new CompilerError("setv! requires exactly 2 arguments!");
    auto result = appender!string(szNameToHostName(ast.children[1].text));
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

// FIXME
string tLambdaToString(AstNode ast) {
    auto type = typeToString(ast.children[1]);
    auto bindings = ast.children[2].children;
    auto bodyNodes = ast.children[3 .. $];
    auto result = appender("(delegate ");
    result ~= type;
    typedFunctionBindingsToString(result, bindings);
    etDefineFnToString(result, type, bodyNodes);
    result ~= ")";
    return result.get();
}

// FIXME
string lambdaToString(AstNode ast) {
    auto bindings = ast.children[1].children;
    auto bodyNodes = ast.children[2 .. $];
    auto result = appender("(delegate ");
    functionBindingsToString(result, bindings);
    etDefineFnToString(result, "", bodyNodes);
    result ~= ")";
    return result.get();
}

string returnToString(AstNode ast) {
    return "return " ~ createOutput(ast.children[1]) ~ ";";
}

string boolOpToString(AstNode ast) {
    string op = ast.children[0].text;
    if (op == "and")
        op = "&&";
    else if (op == "or")
        op = "||";
    else if (op == "xor")
        op = "^";
    return createOutput(ast.children[1]) ~ op ~ createOutput(ast.children[2]);
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
                return lambdaToString(ast);
            case "t-lambda":
                return tLambdaToString(ast);
            case "return":
                return returnToString(ast);
            case "and":
            case "or":
            case "xor":
                return boolOpToString(ast);
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
        foreach (AstNode child; ast.children) {
            result ~= createOutput(child);
        }
        return result;
    }

    return "";
}
