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

Appender!string insertSemicolon(Appender!string result, AstNode node) {
    if (result[][$ - 1] != ';' && node.text != "ll" && result[][$ - 1] != '}')
        result ~= ';';
    return result;
}

string callToString(AstNode ast) {
    string fnname = ast.nodes[0].text;
    auto result = appender!string(szNameToHostName(fnname));
    result ~= '(';
    AstNode[] args = ast.nodes[1 .. $];

    for (int i = 0; i < args.length; i++) {
        result ~= createOutput(args[i]);
        if (i < args.length - 1)
            result ~= ", ";
    }
    result ~= ')';
    return result.get();
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

static const string SHAZA_PARENT_TYPE = "Object";

string generalFunctionBindingsToString(Appender!string result, AstNode[] bindings) {
    result ~= "(";

    // Write function argument list
    for (int i = 0; i < bindings.length; i++) {
        if (bindings[i].type == TknType.litType) {
            result ~= typeToString(bindings[i]);
            i++;
        } else {
            result ~= SHAZA_PARENT_TYPE;
        }
        result ~= " ";
        result ~= szNameToHostName(bindings[i].text); // Name

        if (i < bindings.length - 2) {
            result ~= ", ";
        }
    }

    result ~= ")";
    return result.get();
}

string defineFnToString(Appender!string result, string type, AstNode[] bodyNodes) {
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
        insertSemicolon(result, bodyNode);
        result ~= '\n';
    }

    AstNode lastStmt = bodyNodes[bodyNodes.length - 1];

    // Implicitly insert "return" if possible.
    if (allowImplicitReturn(type, lastStmt)) {
        result ~= "return ";
    }

    result ~= createOutput(lastStmt);
    insertSemicolon(result, lastStmt);

    result ~= "\n}\n";
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

string generalDefineToString(AstNode ast) {
    int nameIndex = 1; // Assume that the name symbol is at index 1
    bool isFunctionDef = false;

    // Try to get type. If no
    string type = ""; // Infer if not given.
    if (ast.nodes[nameIndex].type == TknType.litType) {
        type = typeToString(ast.nodes[nameIndex]);
        nameIndex++;
    }

    AstNode[] generics = []; // None if not given
    if (ast.nodes[nameIndex].type == TknType.closedScope) {
        isFunctionDef = true;
        generics = ast.nodes[nameIndex].nodes;
        nameIndex++;
    }

    AstNode nameNode = ast.nodes[nameIndex];
    if (nameNode.type != TknType.symbol) {
        string msg = "Token " ~ nameNode.tkn.as_readable;
        msg ~= " not allowed as a variable/function name. Token must be a symbol!";
        throw new CompilerError(msg);
    }
    string name = nameNode.text;

    if (!isFunctionDef && (ast.nodes[nameIndex + 1 .. $].length > 1)) {
        isFunctionDef = true;
    }

    if (type.length == 0) {
        if (!isFunctionDef) {
            type = "auto";
        } else {
            string msg = "Cannot induce return type for function definitions yet: ";
            msg ~= nameNode.tkn.as_readable;
            msg ~= ". Assuming type 'void'.";
            stderr.writeln(msg);
            type = "void";
        }
    }

    if (!isFunctionDef) {
        auto result = appender("");
        result ~= type;
        result ~= " ";
        result ~= name;
        result ~= " = ";
        result ~= createOutput(ast.nodes[2]); // Value
        result ~= ";\n";
        return result.get();
    }

    if (ast.nodes[nameIndex + 1].type != TknType.closedScope) {
        string msg = "Token " ~ ast.nodes[nameIndex + 1].tkn.as_readable;
        msg ~= " not allowed as function argument list. Please surround arguments with '(...)'.";
        throw new CompilerError(msg);
    }

    AstNode[] bindings = ast.nodes[nameIndex + 1].nodes;
    AstNode[] bodyNodes = ast.nodes[nameIndex + 2 .. $];

    if (bodyNodes.length == 0) {
        throw new CompilerError("Empty function body: " ~ ast.tkn.as_readable());
    }

    addFunctionFromAst(name, type, generics, bindings);

    auto result = appender!string(type);
    result ~= " ";
    result ~= szNameToHostName(name);

    // If the function has generic arguments.
    if (generics.length > 0) {
        result ~= "(";
        for (int i = 0; i < generics.length; i++) {
            result ~= generics[i].text; // Type
            if (i < generics.length - 1)
                result ~= ", ";
        }
        result ~= ")";
    }

    generalFunctionBindingsToString(result, bindings);
    return defineFnToString(result, type, bodyNodes);
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
    if (ast.nodes.length < 2)
        throw new CompilerError("let or t-let: Too few arguments.");
    if (ast.nodes[1].type != TknType.closedList)
        throw new CompilerError("let or t-let: Bindings must be a list literal.");

    AstNode[] bindings = ast.nodes[1].nodes;
    AstNode[] bodyNodes = ast.nodes[2 .. $];

    // "{" without a keyword before it in D source code opens a new scope
    auto result = appender!string("{\n");

    // Write bindings
    result ~= isExplicitType ? tLetBindingsToString(bindings) : letBindingsToString(bindings);

    // Write code
    foreach (AstNode bodyNode; bodyNodes) {
        result ~= createOutput(bodyNode);
        insertSemicolon(result, bodyNode);
        result ~= "\n";
    }

    result ~= "}";
    return result[];
}

string importHostToString(AstNode ast) {
    auto nodes = ast.nodes[1 .. $];

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
        return "import " ~ nameText ~ ";\n";
    } else if (nodes.length == 2) {
        // Import only specific list of functions.
        if (nodes[1].type != TknType.closedList && nodes[1].type != TknType.closedScope)
            throw new CompilerError(
                    "import-host: list of imported functions must be a list. '(...)' or '[...]'");

        // Build output string
        auto result = appender!string("import ");
        result ~= nameText;
        result ~= " : ";

        for (int i = 0; i < nodes[1].nodes.length; i++) {
            result ~= nodes[1].nodes[i].text;
            if (i < nodes[1].nodes.length - 1)
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
    if (ast.nodes.length == 0)
        return "[]"; // Empty list

    auto result = appender!string("[");
    for (int i = 0; i < ast.nodes.length; i++) {
        result ~= ast.nodes[i].text;
        if (i < ast.nodes[i].nodes.length - 1)
            result ~= ",";
    }
    result ~= "]";
    return result.get();
}

string setvToString(AstNode ast) {
    if (ast.nodes.length != 3)
        throw new CompilerError("setv! requires exactly 2 arguments!");
    auto result = appender!string(szNameToHostName(ast.nodes[1].text));
    result ~= " = ";
    result ~= createOutput(ast.nodes[2]);
    insertSemicolon(result, ast);
    return result.get();
}

void llToStringSub(Appender!string result, AstNode ast) {
    if (ast.type == TknType.closedList || ast.type == TknType.closedTaggedList) {
        result ~= ast.text; // Empty for closedList, list tag for closedTaggedList
        result ~= '[';
        foreach (AstNode child; ast.nodes) {
            llToStringSub(result, child);
        }
        result ~= ']';
    } else if (ast.type == TknType.closedScope) {
        result ~= '(';
        foreach (AstNode child; ast.nodes) {
            llToStringSub(result, child);
        }
        result ~= ')';
    } else {
        result ~= ast.text;
        foreach (AstNode child; ast.nodes) {
            llToStringSub(result, child);
        }
    }
}

string llQuotedStringToString(string text) {
    import std.array : replace;

    text = text[1 .. $ - 1];
    text = text.replace("\\\"", "\"");
    text = text.replace("\\\r", "\r");
    text = text.replace("\\\n", "\n");
    text = text.replace("\\\t", "\t");
    return text;
}

string llToString(AstNode ast) {
    auto result = appender("");
    foreach (AstNode child; ast.nodes[1 .. $]) {
        if (child.type == TknType.litString) {
            result ~= llQuotedStringToString(child.text);
        } else {
            llToStringSub(result, child);
        }
    }
    return result.get();
}

string ifToString(AstNode ast) {
    AstNode condition = ast.nodes[1];
    AstNode branchThen = ast.nodes[2];
    auto result = appender("");
    result ~= "if(";
    result ~= createOutput(condition);
    result ~= ") {\n";
    result ~= createOutput(branchThen);
    insertSemicolon(result, branchThen);
    result ~= "\n}";

    if (ast.size == 4) {
    AstNode branchElse = ast.nodes[3];
    result ~=" else {\n";
    result ~= createOutput(branchElse);
    insertSemicolon(result, branchElse);
    result ~= "\n}";}
    return result.get();
}

// FIXME
string tLambdaToString(AstNode ast) {
    throw new CompilerError("t-lambda not implemented yet: " ~ ast.tkn.as_readable());
}

// FIXME
string lambdaToString(AstNode ast) {
    throw new CompilerError("lambda not implemented yet: " ~ ast.tkn.as_readable());
}

string returnToString(AstNode ast) {
    return "return " ~ createOutput(ast.nodes[1]) ~ ";";
}

string boolOpToString(AstNode ast) {
    string op = ast.nodes[0].text;
    if (op == "and")
        op = "&&";
    else if (op == "or")
        op = "||";
    else if (op == "xor")
        op = "^";
    return "(" ~ createOutput(ast.nodes[1]) ~ op ~ createOutput(ast.nodes[2]) ~ ")";
}

string opcallToString(AstNode ast) {
    string op = szNameToHostName(ast.nodes[1].text);
    auto result = appender("(");
    for (size_t i = 2; i < ast.nodes.length - 1; i++) {
        result ~= createOutput(ast.nodes[i]);
        result ~= " ";
        result ~= op;
        result ~= " ";
    }
    result ~= createOutput(ast.nodes[ast.size - 1]);
    result ~= ")";
    return result.get();
}

string createOutput(AstNode ast) {
    if (isAtom(ast.tkn)) {
        return atomToString(ast);
    }

    if (ast.type == TknType.closedTaggedList || ast.type == TknType.closedList) {
        return listLiteralToString(ast);
    }

    if (ast.type == TknType.closedScope) {
        Token firstTkn = ast.nodes[0].tkn;
        if (firstTkn.type == TknType.symbol) {
            switch (firstTkn.text) {
            case "define":
                return generalDefineToString(ast);
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
            case "llr":
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
            case "opcall":
                return opcallToString(ast);
            case "comment":
                return "";
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
        foreach (AstNode child; ast.nodes) {
            result ~= createOutput(child);
        }
        return result;
    }

    return "";
}
