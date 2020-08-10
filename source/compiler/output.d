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

// SECTION Struct for info about function declarations

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
    private static FunctionDecl NO_FUNCTION;
    private Jumplabel[] jumpLabelStack;

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

    public void addScope(Token orig,) {

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
    return symbolToString(ast.nodes[0]) ~ callArgsToString(ast.nodes[1 .. $]);
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

void addFunctionFromAst(string name, AstNode typeNode, AstNode[] generics, AstNode[] bindings) {
    string type = typestring(typeNode);
    addFunctionFromAst(name, type, generics, bindings);
}

void addFunctionFromAst(string name, string type, AstNode[] generics, AstNode[] bindings) {
    string[] genericTypes;

    for (int i = 0; i < generics.length; i++) {
        genericTypes ~= symbolToString(generics[i]); // Type
    }

    string[] args;

    // FIXME Update because sometimes the types are now optional
    for (int i = 0; i < bindings.length; i += 2) { // +2 skips name
        args ~= typeToString(bindings[i]);
    }

    if (OutputContext.global)
        OutputContext.global.addFunc(name, type, genericTypes, args);
}

// SECTION define-instruction

string generalDefineToString(AstNode ast) {
    int nameIndex = 1; // Assume that the name symbol is at index 1
    bool isFunctionDef = false;

    // SUBSECT Try to get type.
    // If none is given, try again later.
    string type = ""; // Infer if not given.
    if (ast.nodes[nameIndex].type == TknType.litType) {
        type = typeToString(ast.nodes[nameIndex]);
        nameIndex++; // Type found, name comes later.
    }

    // SUBSECT Generics

    AstNode[] generics = []; // None if not given
    if (ast.nodes[nameIndex].type == TknType.closedScope) {
        isFunctionDef = true;
        generics = ast.nodes[nameIndex].nodes;
        nameIndex++;
    }

    // SUBSECT Name

    AstNode nameNode = ast.nodes[nameIndex];
    if (nameNode.type != TknType.symbol) {
        string msg = "Token " ~ nameNode.tkn.as_readable;
        msg ~= " not allowed as a variable/function name. Token must be a symbol!";
        throw new CompilerError(msg);
    }
    string name = symbolToString(nameNode);

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
        auto result = appender("");
        result ~= type;
        result ~= " ";
        result ~= name;
        result ~= " = ";
        result ~= createOutput(ast.nodes[2]); // Value
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

    // Error if body is empty
    if (bodyNodes.length == 0) {
        throw new CompilerError("Empty function body: " ~ ast.tknstr);
    }

    // Add function to globals
    addFunctionFromAst(name, type, generics, bindings);

    // SUBSECT Write name and (if given) generic types.

    auto result = appender!string(type);
    result ~= " ";
    result ~= szNameToHostName(name);

    // If the function has generic arguments.
    if (generics.length > 0) {
        result ~= "(";
        for (int i = 0; i < generics.length; i++) {
            result ~= symbolToString(generics[i]); // Type
            if (i < generics.length - 1)
                result ~= ", ";
        }
        result ~= ")";
    }

    // SUBSECT Write rest of arguments and body and return

    generalFunctionBindingsToString(result, bindings);
    return defineFnToString(result, type, argNames, bodyNodes);
}

// SUBSECT Helper for bindings and body of the define-instruction

string defineFnToString(Appender!string result, string type, string[] argNames, AstNode[] bodyNodes) {
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

    result ~= "\n}\n";
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

string setvToString(AstNode ast) {
    if (ast.nodes.length != 3) {
        throw new CompilerError("setv! requires exactly 2 arguments!");
    }

    auto result = appender("");
    result ~= szNameToHostName(symbolToString(ast.nodes[1])); // Var name
    result ~= " = ";
    result ~= createOutput(ast.nodes[2]); // Value
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
string tLambdaToString(AstNode ast) {
    throw new CompilerError("t-lambda not implemented yet: " ~ ast.tknstr);
}

// FIXME
string lambdaToString(AstNode ast) {
    throw new CompilerError("lambda not implemented yet: " ~ ast.tknstr);
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

// SECTION Boolean operator to string

// TODO Remove when support for lazy arguments is added

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

// SECTION Main switch-table for string-creation of ast.

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
            case "new":
                return newToString(ast);
            case "loop":
                return loopToString(ast);
            case "recur":
                return recurToString(ast);
            case "and":
            case "or":
            case "xor":
                return boolOpToString(ast);
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
