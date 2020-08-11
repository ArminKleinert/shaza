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

// SECTION class for meta-info about functions

class FnMeta {
    const string exportName;
    const string visibility;
    const immutable(string)[] aliases;
    const immutable(string)[] generics;

    this(string exportName, string visibility, in string[] aliases, in string[] generics) {
        this.exportName = exportName;
        this.visibility = visibility;
        this.aliases = aliases.dup;
        this.generics = generics.dup;
    }

    this(string exportName, string[] generics) {
        this.exportName = exportName;
        this.generics = generics.dup;
        aliases = [];
        visibility = "public";
    }
}

// SECTION Struct for info about function declarations

class FunctionDecl {
    const FnMeta meta;
    const string name;
    const string returnType;
    const immutable(string)[] argTypes;

    this(FnMeta meta, string name, string returnType, const immutable(string)[] argTypes) {
        this.meta = meta;
        this.name = name;
        this.returnType = returnType;
        this.argTypes = argTypes;
    }

    immutable(string)[] generics() {
        if (meta is null)
            return [];
        return meta.generics;
    }

    string exportName() {
        if (meta is null || meta.exportName.size == 0)
            return szNameToHostName(name);
        return meta.exportName;
    }

    string visibility() {
        if (meta is null)
            return "public";
        return meta.visibility;
    }

    immutable(string)[] aliases() {
        if (meta is null)
            return [];
        return meta.aliases;
    }
}

// SECTION Class for Jumplabels with information about related variable-names

class Jumplabel {
    const string text;
    const immutable(string)[] vars;

    this(string _text, string[] _vars) {
        text = _text;
        vars = _vars.dup;
    }
}

// SECTION Class for a global context holding information about registered functions

class OutputContext {
    private string[] globals;
    private FunctionDecl[] _functions;
    private Jumplabel[] jumpLabelStack;

    private __gshared OutputContext _global;

    this() {
        globals = [];
        _functions = [];
    }

    public static OutputContext global() {
        if (_global is null)
            _global = new OutputContext();
        return _global;
    }

    public FunctionDecl addFunc(FnMeta meta, string name, string returnType, string[] argTypes) {
        immutable(string)[] args = argTypes.dup;
        auto fd = new FunctionDecl(meta, name, returnType, args);
        _functions ~= fd;
        return fd;
    }

    public FunctionDecl addFunc(FnMeta meta, string name, string returnType) {
        auto fd = new FunctionDecl(meta, name, returnType, []);
        _functions ~= fd;
        return fd;
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
            current ~= to!string(fn.generics)[1 .. $ - 1];
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
        return null;
    }

    string newLabel(string[] varnames) {
        string name = "jumplbl" ~ to!string(jumpLabelStack.size + 1);
        Jumplabel lbl = new Jumplabel(name, varnames);
        jumpLabelStack ~= lbl;
        return name ~ ":\n";
    }

    Jumplabel getLastJumpLabel() {
        return jumpLabelStack[jumpLabelStack.size - 1];
    }

    void removeLastLabel() {
        jumpLabelStack = jumpLabelStack[0 .. $ - 1];
    }
}

// SECTION Checked string converters

string symbolToString(AstNode node) {
    if (node.type != TknType.symbol)
        throw new CompilerError("Expected symbol: " ~ node.tknstr);
    return szNameToHostName(node.text);
}

string typestring(AstNode node) {
    if (node.type != TknType.symbol)
        throw new CompilerError("Expected type: " ~ node.tknstr);
    return node.text;
}

string keywordToString(AstNode node) {
    if (node.type != TknType.litKeyword)
        throw new CompilerError("Expected symbol: " ~ node.tknstr);
    return szNameToHostName(node.text[1 .. $]);
}

// SECTION Minor helpers

Appender!string insertSemicolon(Appender!string result, AstNode node) {
    if (result[][$ - 1] != ';' && node.text != "ll" && result[][$ - 1] != '{'
            && result[][$ - 1] != '}')
        result ~= ';';
    return result;
}

// SUBSECT Do nested search for "recur" in nodes.

bool nodeContainsRecur(AstNode node) {
    if (node.type == TknType.symbol && node.text == "recur") {
        return true;
    }
    return nodesContainRecur(node.nodes);
}

bool nodesContainRecur(AstNode[] astNodes) {
    if (astNodes.size == 0)
        return false;

    foreach (node; astNodes) {
        if (node.type == TknType.closedScope && node.size > 0
                && (node.nodes[0].text == "loop" || node.nodes[0].text == "define")) {
            return false;
        }
        if (nodeContainsRecur(node))
            return true;
    }

    return false;
}

// SECTION Fucntion call to string

string callToString(AstNode ast) {
    if (ast.size == 0) {
        throw new CompilerError("Unexpected empty scope. " ~ ast.tknstr());
    }

    string callingName;
    if (ast.nodes[0].type == TknType.symbol) {
        if (FunctionDecl fn = OutputContext.global.findFn(ast.nodes[0].text))
            callingName = fn.meta.exportName;
        else
            callingName = symbolToString(ast.nodes[0]);
    } else {
        // Ok, if we are not using a name to call a function,
        // it might be a lambda definition.. Just trust the user
        // what could go wrong :D
        callingName = createOutput(ast.nodes[0]);
    }

    return callingName ~ callArgsToString(ast.nodes[1 .. $]);
}

string callArgsToString(AstNode[] args) {
    auto result = appender!string("(");
    for (int i = 0; i < args.length; i++) {
        result ~= createOutput(args[i]);
        if (i < args.length - 1)
            result ~= ", ";
    }
    result ~= ')';
    return result.get();
}

// SECTION Generate text for function bindings.

static const string SHAZA_PARENT_TYPE = "Object";

string[] getVarNamesFromBindings(AstNode[] bindings) {
    string[] names;

    for (int i = 0; i < bindings.length; i++) {
        if (bindings[i].type == TknType.symbol) {
            names ~= szNameToHostName(symbolToString(bindings[i]));
        }
    }

    return names;
}

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
        result ~= szNameToHostName(symbolToString(bindings[i])); // Name

        if (i < bindings.length - 2) {
            result ~= ", ";
        }
    }

    result ~= ")";
    return result.get();
}

// SECTION Add function to globally visible functions (May be used for type induction)

FunctionDecl addFunctionFromAst(FnMeta meta, string name, AstNode typeNode, AstNode[] bindings) {
    string type = typestring(typeNode);
    return addFunctionFromAst(meta, name, type, bindings);
}

FunctionDecl addFunctionFromAst(FnMeta meta, string name, string type, AstNode[] bindings) {
    string[] args;

    // FIXME Update because sometimes the types are now optional
    for (int i = 0; i < bindings.length; i += 2) { // +2 skips name
        args ~= typeToString(bindings[i]);
    }

    return OutputContext.global.addFunc(meta, name, type, args);
}

// SECTION define-instruction

string generalDefineToString(AstNode ast, bool forceFunctionDef, FnMeta meta) {
    int nameIndex = 1; // Assume that the name symbol is at index 1
    bool isFunctionDef = forceFunctionDef;

    // SUBSECT Try to get type.
    // If none is given, try again later.
    string type = ""; // Infer if not given.
    if (ast.nodes[nameIndex].type == TknType.litType) {
        type = typeToString(ast.nodes[nameIndex]);
        nameIndex++; // Type found, name comes later.
    }

    // SUBSECT Generics

    string[] generics = []; // None if not given
    if (ast.nodes[nameIndex].type == TknType.closedScope) {
        isFunctionDef = true;

        if (meta !is null) {
            stderr.writeln("Generics ignored because meta is given. " ~ ast.nodes[0].tknstr());
        } else {
            auto genericsNodes = ast.nodes[nameIndex].nodes;
            foreach (node; genericsNodes) {
                generics ~= szNameToHostName(node.text);
            }
        }

        nameIndex++;
    }

    // SUBSECT Name

    AstNode nameNode = ast.nodes[nameIndex];
    if (nameNode.type != TknType.symbol) {
        string msg = "Token " ~ nameNode.tknstr();
        msg ~= " not allowed as a variable/function name. Token must be a symbol!";
        throw new CompilerError(msg);
    }
    string name = nameNode.text;

    // SUBSECT Check if this is a function declaration

    if (!isFunctionDef && (ast.nodes[nameIndex + 1 .. $].length > 1)) {
        isFunctionDef = true;
    }

    // SUBSECT Induce type of variable / return-type of function

    if (type.length == 0) {
        if (!isFunctionDef) {
            type = "auto"; // For variables, use "auto" :)
        } else {
            string msg = "Cannot induce return type for function definitions yet: ";
            msg ~= nameNode.tkn.as_readable;
            msg ~= ". Assuming type 'void'.";
            stderr.writeln(msg);
            type = "void";
        }
    }

    // SUBSECT Create output text for variables and return

    if (!isFunctionDef) {
        if (meta !is null) {
            stderr.writeln("Metadata ignored. " ~ ast.nodes[0].tknstr());
        }

        string val;
        if (ast.nodes.size == nameIndex + 1) {
            assert(type != "auto");
            val = type ~ ".init";
        } else {
            val = createOutput(ast.nodes[nameIndex + 1]);
        }

        auto result = appender("");
        result ~= type;
        result ~= " ";
        result ~= symbolToString(nameNode);
        result ~= " = ";
        result ~= val; // Value
        result ~= ";\n";
        return result.get();
    }

    // SUBSECT Bindings and body

    // Arguments must be in (...)
    if (ast.nodes[nameIndex + 1].type != TknType.closedScope) {
        string msg = "Token " ~ ast.nodes[nameIndex + 1].tkn.as_readable;
        msg ~= " not allowed as function argument list. Please surround arguments with '(...)'.";
        throw new CompilerError(msg);
    }

    AstNode[] bindings = ast.nodes[nameIndex + 1].nodes;
    AstNode[] bodyNodes = ast.nodes[nameIndex + 2 .. $];
    auto argNames = getVarNamesFromBindings(bindings);

    // Add function to globals
    if (meta is null)
        meta = new FnMeta(szNameToHostName(name), generics);
    auto fndeclaration = addFunctionFromAst(meta, name, type, bindings);

    // SUBSECT Write name and (if given) generic types.

    auto result = appender("");
    if (meta.visibility != "public") {
        result ~= fndeclaration.visibility;
        result ~= ' ';
    }
    result ~= type;
    result ~= ' ';
    result ~= fndeclaration.exportName;

    // If the function has generic arguments.
    if (fndeclaration.generics.length > 0) {
        result ~= '(';
        for (int i = 0; i < fndeclaration.generics.length; i++) {
            result ~= fndeclaration.generics[i]; // Type
            if (i < fndeclaration.generics.length - 1)
                result ~= ", ";
        }
        result ~= ')';
    }

    // SUBSECT Write rest of arguments and body and return

    generalFunctionBindingsToString(result, bindings);
    defineFnToString(result, type, argNames, bodyNodes);

    foreach (aliasName; fndeclaration.aliases) {
        result ~= "alias ";
        result ~= aliasName;
        result ~= "=";
        result ~= fndeclaration.exportName;
        result ~= ";\n";
    }

    return result.get();
}

// SUBSECT Helper for body of the define-instruction

string defineFnToString(Appender!string result, string type, string[] argNames, AstNode[] bodyNodes) {
    result ~= "{\n";

    // If the body is empty, return the default value of the return-type
    // or, if the type is void, leave an empty body
    if (bodyNodes.length == 0) {
        if (type == "void")
            return result.get();
        result ~= "return ";
        result ~= type;
        result ~= ".init;\n}\n";
        return result.get();
    }

    // Add jump-label
    bool doAddLabel = nodesContainRecur(bodyNodes);
    if (doAddLabel) {
        result ~= OutputContext.global.newLabel(argNames);
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

    // Pop jump label
    if (doAddLabel)
        OutputContext.global.removeLastLabel();

    result ~= "\n}";
    return result.get();
}

// SECTION let-instruction

string tLetBindingsToString(AstNode[] bindings) {
    if (bindings.length % 3 != 0)
        throw new CompilerError("t-let: Bindings length must be divisible by 3 (type, name, value)");

    auto result = appender!string("");
    for (int i = 0; i < bindings.length; i += 3) {
        result ~= typeToString(bindings[i]); // Type
        result ~= " ";
        result ~= szNameToHostName(symbolToString(bindings[i + 1])); // Name
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
        result ~= szNameToHostName(symbolToString(bindings[i + 0])); // Name
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

// SECTION import-host

string importHostToString(AstNode ast) {
    auto nodes = ast.nodes[1 .. $];

    // Handle some errors
    if (nodes.length == 0)
        throw new CompilerError("Too few arguments for import-host.");
    if (nodes[0].type != TknType.symbol && nodes[0].type != TknType.litString) {
        throw new CompilerError("import-host: Module name must be string or symbol.");
    }

    // Parse name of import
    string nameText;
    if (nodes[0].type == TknType.litString) {
        nameText = nodes[0].text[1 .. $ - 1];
    } else {
        nameText = symbolToString(nodes[0]);
    }

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
            result ~= symbolToString(nodes[1].nodes[i]);
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

// SECTION List literal to string

string listLiteralToString(AstNode ast) {
    if (ast.nodes.length == 0)
        return "[]"; // Empty list

    auto result = appender!string("[");
    for (int i = 0; i < ast.nodes.length; i++) {
        result ~= symbolToString(ast.nodes[i]);
        if (i < ast.nodes[i].nodes.length - 1)
            result ~= ",";
    }
    result ~= "]";
    return result.get();
}

// SECTION setv! (assignment) to string

string simpleSetvToString(string name, AstNode newVal) {
    return name ~ " = " ~ createOutput(newVal);
}

string attrSetvToString(string name, AstNode attr, AstNode newVal) {
    expectType(attr, TknType.symbol, TknType.litKeyword, TknType.litString);

    string s;
    if (attr.type == TknType.litKeyword)
        s = keywordToString(attr);
    else if (attr.type == TknType.litString)
        s = attr.text[1 .. $ - 1];
    else
        s = symbolToString(attr);

    return name ~ "." ~ s ~ " = " ~ createOutput(newVal);
}

string setvToString(AstNode ast) {
    if (ast.nodes.size < 3) {
        throw new CompilerError("setv: Too few arguments. " ~ ast.tknstr());
    }

    auto result = appender("");
    expectType(ast.nodes[1], TknType.symbol);
    auto varname = createOutput(ast.nodes[1]); // Var name

    if (ast.nodes.size == 3) {
        result ~= simpleSetvToString(varname, ast.nodes[2]);
    } else if (ast.nodes.size == 4) {
        result ~= attrSetvToString(varname, ast.nodes[2], ast.nodes[3]);
    }
    insertSemicolon(result, ast);
    return result.get();
}

// SECTION ll-instruction

// SUBSECT Convert arguments of ll back into their string representation

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

// SUBSECT Un-quotify strings from ll-blocks

string llQuotedStringToString(string text) {
    import std.array : replace;

    text = text[1 .. $ - 1];
    text = text.replace("\\\"", "\"");
    text = text.replace("\\\r", "\r");
    text = text.replace("\\\n", "\n");
    text = text.replace("\\\t", "\t");
    return text;
}

// SUBSECT ll-instruction main

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

// SECTION if-else

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
        result ~= " else {\n";
        result ~= createOutput(branchElse);
        insertSemicolon(result, branchElse);
        result ~= "\n}";
    }
    return result.get();
}

// SECTION Lambdas

// FIXME
string lambdaToString(AstNode ast) {
    if (ast.size < 4) {
        throw new CompilerError("lambda: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    if (ast.nodes[1].type != TknType.litType) {
        string msg = "Lambda without explicit return type not supported yet. ";
        throw new CompilerError(msg ~ ast.nodes[0].tknstr());
    }
    if (ast.nodes[2].type != TknType.closedScope) {
        string msg = "Lambda argument must given in brackets. " ~ ast.nodes[0].tknstr();
        throw new CompilerError(msg);
    }

    AstNode returnType = ast.nodes[1];
    AstNode[] bindings = ast.nodes[2].nodes;
    string[] bindingArgNames = getVarNamesFromBindings(bindings);
    AstNode[] bodyNodes = ast.nodes[3 .. $];

    auto result = appender("delegate ");
    result ~= typeToString(returnType);
    generalFunctionBindingsToString(result, bindings);
    return defineFnToString(result, typeToString(returnType), bindingArgNames, bodyNodes);
}

// SECTION loop

string loopToString(AstNode ast) {
    // SUBSECT Error checking

    if (ast.size < 3) {
        throw new CompilerError("Loop: not enough arguments. " ~ ast.nodes[0].tknstr);
    }
    if (ast.nodes[1].type != TknType.closedScope) {
        throw new CompilerError("Loop: First argument must be a scope. " ~ ast.nodes[1].tknstr());
    }

    // SUBSECT Retrieve bindings and body

    AstNode[] bindings = ast.nodes[1].nodes;
    AstNode[] bodyNodes = ast.nodes[2 .. $];
    string[] argNames = getVarNamesFromBindings(bindings);

    // SUBSECT Write bindings to result

    auto result = appender("");

    for (auto i = 0; i < bindings.size; i += 2) {
        // Type
        if (bindings[i].type == TknType.litType) {
            result ~= typeToString(bindings[i]);
            i++;
        } else {
            result ~= "auto"; // If no type is given, insert "auto"
        }
        result ~= ' ';

        // Write variable name
        if (bindings[i].type != TknType.symbol) {
            throw new CompilerError("Loop: Variable name must be symbol: " ~ bindings[i].tknstr());
        }
        result ~= symbolToString(bindings[i]);
        result ~= " = ";

        // Write value of variable
        if (bindings.size <= i + 1) {
            throw new CompilerError("Loop: Value for variable expected: " ~ bindings[i].tknstr());
        }
        result ~= createOutput(bindings[i + 1]);
        insertSemicolon(result, bindings[i + 1]);
        result ~= '\n';
    }

    // SUBSECT Add jump-label
    bool doAddLabel = nodesContainRecur(bodyNodes);
    if (doAddLabel)
        result ~= OutputContext.global.newLabel(argNames);

    // SUBSECT Generate body
    foreach (node; bodyNodes) {
        result ~= createOutput(node);
        insertSemicolon(result, node);
        result ~= '\n';
    }

    // SUBSECT Remove label and return
    if (doAddLabel)
        OutputContext.global.removeLastLabel();
    return result.get();
}

// SECTION recur

string recurToString(AstNode ast) {
    // TODO verification

    AstNode[] bindings = ast.nodes[1 .. $];
    auto lastLabel = OutputContext.global.getLastJumpLabel();

    if (bindings.size != lastLabel.vars.size) {
        throw new CompilerError("Too many or too few bindings" ~ ast.nodes[0].tknstr());
    }

    auto result = appender("");

    for (auto i = 0; i < lastLabel.vars.size; i++) {
        result ~= lastLabel.vars[i];
        result ~= " = ";
        result ~= createOutput(bindings[i]);
        insertSemicolon(result, bindings[i]);
        result ~= '\n';
    }

    result ~= "goto ";
    result ~= lastLabel.text;
    result ~= ';';
    return result.get();
}

// SECTION conversions -> cast and to

string conversionToString(AstNode ast) {
    if (ast.size < 3) {
        throw new CompilerError("to: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    auto s = "to!" ~ typeToString(ast.nodes[1]);
    return toOrCastToString(ast, s);
}

string castToString(AstNode ast) {
    if (ast.size < 3) {
        throw new CompilerError("cast: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    auto s = "cast(" ~ typeToString(ast.nodes[1]) ~ ")";
    return toOrCastToString(ast, s);
}

string toOrCastToString(AstNode ast, string start) {
    if (ast.size < 3) {
        throw new CompilerError("cast: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    expectType(ast.nodes[1], TknType.litType);

    auto result = appender(start);
    result ~= "(";
    result ~= createOutput(ast.nodes[2]);

    if (ast.size > 3) {
        foreach (arg; ast.nodes[3 .. $]) {
            result ~= ", ";
            result ~= createOutput(arg);
        }
    }

    result ~= ")";
    return result.get();
}

// SECTION Return

string returnToString(AstNode ast) {
    return "return " ~ createOutput(ast.nodes[1]) ~ ";";
}

// SECTION new-operator

string newToString(AstNode ast) {
    if (ast.nodes.length < 2) {
        throw new CompilerError("new requires at least one parameter. " ~ ast.tknstr);
    }

    if (ast.nodes[1].type != TknType.litType) {
        throw new CompilerError("new: First parameter must be type literal. " ~ ast.nodes[1].tknstr);
    }

    return "new " ~ createOutput(ast.nodes[1]) ~ callArgsToString(ast.nodes[2 .. $]) ~ ";";
}

// SECTION Code for def-struct

// This should really be made into a macro once possible...
string defStructToString(AstNode ast) {
    // SUBSECT Error checking stuff

    if (ast.size < 2) {
        auto msg = "def-struct: Not enough parameters. ";
        throw new CompilerError(msg ~ ast.tknstr);
    }

    // SUBSECT Get type name

    AstNode typeNode = ast.nodes[1]; // Type name

    if (typeNode.type != TknType.symbol) {
        auto msg = "def-struct: First argument must be a symbol. ";
        throw new CompilerError(msg ~ typeNode.tknstr);
    }

    // SUBSECT find generics (if given) and fields

    AstNode generics; // Optional
    AstNode[] attrList;

    // If the type is not empty
    if (ast.nodes.size > 2) {
        // If the type has generics
        if (ast.nodes[2].type == TknType.closedScope) {
            generics = ast.nodes[2];
            attrList = ast.nodes[3 .. $];
        } else {
            attrList = ast.nodes[2 .. $];
        }
    }

    if (attrList.size % 2 != 0) {
        auto msg = "def-struct: fields must be a sequence of types and symbols.";
        throw new CompilerError(msg ~ typeNode.tknstr);
    }

    // SUBSECT Retrieve field types and field names

    string[] fieldTypes = [];
    string[] fieldNames = [];
    for (auto i = 0; i < attrList.size; i += 2) {
        fieldTypes ~= typeToString(attrList[i]);
        fieldNames ~= symbolToString(attrList[i + 1]);
    }

    // SUBSECT Write header

    // Start class definition text
    auto result = appender("class ");
    result ~= symbolToString(typeNode); // Write typename

    // SUBSECT Generate list of generics (if given).
    if (generics !is null) {
        result ~= "(";
        for (int i = 0; i < generics.size; i++) {
            result ~= symbolToString(generics.nodes[i]);
            if (i < generics.size - 1)
                result ~= ", ";
        }
        result ~= ")";
    }

    result ~= " {\n";

    // SUBSECT Write list of attributes

    for (auto i = 0; i < fieldTypes.size; i++) {
        result ~= fieldTypes[i];
        result ~= ' ';
        result ~= fieldNames[i];
        result ~= ";\n";
    }

    // SUBSECT Write constructor

    // Name
    result ~= "this(";
    // Write constructor arguments; Arguments have a '_' in front of the name.
    for (auto i = 0; i < fieldTypes.size; i++) {
        result ~= fieldTypes[i];
        result ~= " _";
        result ~= fieldNames[i];
        if (i < fieldTypes.size - 1)
            result ~= ", ";
    }
    result ~= "){\n";
    // Write constructor body
    foreach (field; fieldNames) {
        result ~= field;
        result ~= " = _";
        result ~= field;
        result ~= ";\n";
    }
    result ~= '}';

    // Close
    result ~= "}\n";
    return result.get();
}

// SECTION Operator call (+, -, *, /, &, %, |) for > 2 arguments

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

// SECTION Parse "meta" instruction

string parseMetaGetString(AstNode ast) {
    if (ast.size < 3) {
        throw new CompilerError("meta: Too few arguments. " ~ ast.nodes[0].tknstr());
    }

    auto attribs = ast.nodes[1];
    auto wrapped = ast.nodes[2];

    if (wrapped.nodes.size < 2 && wrapped.nodes[0].text != "define"
            && wrapped.nodes[0].text != "define-fn") {
        string msg = "meta can only be used on function definitions. Otherwise, it is ignored. ";
        stderr.writeln(msg ~ ast.nodes[0].tknstr());
        return createOutput(wrapped);
    }

    // Crash if attribute list is invalid
    expectType(attribs, TknType.closedScope);

    // SUBSECT Parse attributes

    // Default values
    string visibility = "public";
    string[] generics = [];
    string[] aliases = [];
    string exportName = null;

    // Currently accepted options are :generics, :visibility, :aliases, :export-as
    for (auto i = 0; i < attribs.size; i++) {
        expectType(attribs.nodes[i], TknType.litKeyword);
        if (attribs.nodes[i].text == ":generics") {
            i++;
            expectType(attribs.nodes[i], TknType.litList, TknType.closedList);
            foreach (genNode; attribs.nodes[i].nodes) {
                expectType(genNode, TknType.symbol);
                generics ~= symbolToString(genNode);
            }
        } else if (attribs.nodes[i].text == ":visibility") {
            i++;
            expectType(attribs.nodes[i], TknType.litKeyword);
            visibility = keywordToString(attribs.nodes[i]);
        } else if (attribs.nodes[i].text == ":aliases") {
            i++;
            expectType(attribs.nodes[i], TknType.litList, TknType.closedList);
            foreach (aliasNode; attribs.nodes[i].nodes) {
                expectType(aliasNode, TknType.symbol);
                aliases ~= symbolToString(aliasNode);
            }
        } else if (attribs.nodes[i].text == ":export-as") {
            i++;
            expectType(attribs.nodes[i], TknType.litString);
            exportName = attribs.nodes[i].text[1 .. $ - 1];
        } else {
            stderr.writeln("Unknown meta-option. " ~ attribs.nodes[i].tknstr());
        }
    }

    // SUBSECT Create and parse function

    auto meta = new FnMeta(exportName, visibility, aliases, generics);
    auto forceIsFn = wrapped.nodes[0].text == "define-fn";

    return generalDefineToString(wrapped, forceIsFn, meta);
}

// SECTION Main switch-table for string-creation of ast.

string createOutput(AstNode ast) {
    import std.conv;

    auto s_to_i_with_base_test = to!int("12345", 16);
    auto s_to_i_test = to!int("12345");
    auto cast_f_i_test = cast(int)(1.5f);

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
                return generalDefineToString(ast, false, null);
            case "define-fn":
                return generalDefineToString(ast, true, null);
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
            case "return":
                return returnToString(ast);
            case "new":
                return newToString(ast);
            case "loop":
                return loopToString(ast);
            case "recur":
                return recurToString(ast);
            case "to":
                return conversionToString(ast);
            case "cast":
                return castToString(ast);
            case "opcall":
                return opcallToString(ast);
            case "comment":
                return "";
            case "def-struct":
                return defStructToString(ast);
            case "struct":
                break; // TODO
            case "import-sz":
                break; // TODO
            case "import-host":
                return importHostToString(ast);
            case "rt-import-sz":
                break; // TODO
            case "rt-import-dll":
                break; // TODO
            case "quote":
                break; // TODO
            case "pseudo-quote":
                break; // TODO
            case "unquote":
                break; // TODO
            case "meta":
                return parseMetaGetString(ast);
            default:
                break;
            }
        }
        return callToString(ast);
    }

    if (ast.type == TknType.root) {
        auto rootTexts = appender!(string[])();
        foreach (AstNode child; ast.nodes) {
            rootTexts ~= createOutput(child);
        }
        rootTexts ~= OutputContext.global().globals;
        auto result = appender("");
        foreach (txt; rootTexts[]) {
            result ~= txt ~ "\n";
        }
        return result.get();
    }

    return "";
}
