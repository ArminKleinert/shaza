module compiler.output.helpers;

import std.array;

import compiler.types;
import shaza.stdlib;

// SECTION class for meta-info about functions

class FnMeta {
    const string exportName;
    const string visibility;
    const string returnType;
    const bool variadic;
    const immutable(string)[] aliases;
    const immutable(string)[] generics;

    this(string exportName, string visibility, in string[] aliases,
            in string[] generics, string returnType, bool variadic) {
        this.exportName = exportName;
        this.visibility = visibility;
        this.aliases = aliases.dup;
        this.generics = generics.dup;
        this.returnType = returnType;
        this.variadic = variadic;
    }

    this(string exportName, string[] generics, string returnType) {
        this.exportName = exportName;
        this.generics = generics.dup;
        aliases = [];
        visibility = "";
        this.returnType = returnType;
        this.variadic = false;
    }

    FnMeta combineWith(FnMeta other) {
        if (other is null)
            return this;

        return new FnMeta((other.exportName) ? other.exportName : exportName,
                other.visibility.size > 0 ? other.visibility : visibility,
                other.aliases.size > 0 ? other.aliases : aliases, other.generics.size > 0
                ? other.generics : generics, other.returnType.size > 0
                ? other.returnType : returnType, other.variadic ? true : variadic);
    }
}

// SECTION Struct for info about function declarations

class FunctionDecl {
    const FnMeta meta;
    const string name;
    const immutable(string)[] argTypes;
    const immutable(string)[] _generics;
    const string _returnType;

    this(FnMeta meta, string name, string returnType,
            const immutable(string)[] argTypes, const immutable(string)[] _generics) {
        this.meta = meta;
        this.name = name;
        this.argTypes = argTypes;
        this._returnType = returnType;
        this._generics = _generics;
    }

    immutable(string)[] generics() {
        if (_generics !is null)
            return _generics;
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

    string returnType() {
        if (_returnType != null && _returnType.size > 0)
            return _returnType;
        if (meta is null)
            return "void";
        return meta.returnType;
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
    string[] globals;
    private string[] modules;
    private FunctionDecl[] _functions;
    private FunctionDecl[string] aliasedFunctions;
    private Jumplabel[] jumpLabelStack;
    string[string] fullModuleTexts;
    string sourcedir = "";

    private __gshared OutputContext _global;

    this() {
        globals = [];
        _functions = [];
        modules = [];
    }

    public static OutputContext global() {
        if (_global is null)
            _global = new OutputContext();
        return _global;
    }

    public FunctionDecl addFunc(FnMeta meta, string name, string returnType,
            string[] argTypes, string[] _generics) {
        immutable(string)[] args = argTypes.dup;
        immutable(string)[] generics = _generics.dup;
        return addFunc(new FunctionDecl(meta, name, returnType, args, generics));
    }

    public FunctionDecl addFunc(FnMeta meta, string name, string returnType) {
        return addFunc(new FunctionDecl(meta, name, returnType, [], null));
    }

    private FunctionDecl addFunc(FunctionDecl fd) {
        foreach (al; fd.aliases) {
            if (al in aliasedFunctions)
                warning(
                        "Function alias " ~ al ~ " already exists! Ignoring alias " ~ al ~ " for function " ~ fd.toString());
            else
                aliasedFunctions[al] = fd;
        }
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
        import std.conv;

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

    FunctionDecl findFn(string name) {
        foreach (fn; _functions) {
            if (fn.name == name)
                return fn;
        }
        if (name in aliasedFunctions) {
            return aliasedFunctions[name];
        }
        return null;
    }

    string newLabel(string[] varnames) {
        import std.conv;

        string name = "jumplbl" ~ to!string(jumpLabelStack.size + 1);
        Jumplabel lbl = new Jumplabel(name, varnames);
        jumpLabelStack ~= lbl;
        return name ~ ":\n";
    }

    Jumplabel getLastJumpLabel() {
        if (jumpLabelStack.size > 0) {
            return jumpLabelStack[jumpLabelStack.size - 1];
        } else {
            return null;
        }
    }

    void removeLastLabel() {
        if (jumpLabelStack.size > 0) {
            jumpLabelStack = jumpLabelStack[0 .. $ - 1];
        }
    }

    bool addModule(string modulename) {
        if (hasImported(modulename))
            return false;
        modules ~= modulename;
        fullModuleTexts[modulename] = "";
        return true;
    }

    bool hasImported(string modulename) {
        import std.algorithm.searching;

        return canFind(modules, modulename);
    }

    void appendToModuleText(string modulename, string text) {
        if (!hasImported(modulename))
            addModule(modulename);
        fullModuleTexts[modulename] ~= text;
    }
}

// SECTION Ast with additional context

struct AstCtx {
    AstNode ast;
    AstNode fullAst;
    bool requestReturn;

    alias ast this;

    this(AstNode fullAst, AstNode ast) {
        this.fullAst = fullAst;
        this.ast = ast;
        requestReturn = false;
    }

    AstCtx needReturn(bool v) {
        AstCtx cpy = AstCtx(fullAst, ast);
        cpy.requestReturn = v;
        return cpy;
    }

    /*
    AstCtx withAst(AstNode node) {
        AstCtx cpy = AstCtx(fullAst, node);
        cpy.requestReturn = requestReturn;
        return cpy;
    }
    */

    AstCtx opIndex(size_t i) {
        return AstCtx(fullAst, ast.nodes[i]);
    }

    AstCtx opCall(AstNode node) {
        return AstCtx(fullAst, node);
    }

    AstCtx[] subs() {
        AstCtx[] res = [];
        foreach (n; nodes) {
            // Do not want to inherit eg. requestReturn
            res ~= AstCtx(fullAst, n);
        }
        return res;
    }
}

// SECTION Checked string converters

string symbolToString(AstNode node) {
    if (node.type != keyword(":symbol"))
        throw new CompilerError("Expected symbol: " ~ node.tknstr);
    return szNameToHostName(node.text);
}

string typestring(AstNode node) {
    if (node.type != keyword(":symbol"))
        throw new CompilerError("Expected type: " ~ node.tknstr);
    return node.text;
}

string keywordToString(AstNode node) {
    if (node.type != keyword(":litKeyword"))
        throw new CompilerError("Expected symbol: " ~ node.tknstr);
    return szNameToHostName(node.text[1 .. $]);
}

// SECTION Minor helpers

Appender!string insertSemicolon(Appender!string result, AstNode node) {
    bool allow = result[][$ - 1] != ';' && result[][$ - 1] != '{' && result[][$ - 1] != '}';
    if (node.type == keyword(":closedScope") && node.size > 0) {
        allow = allow && node.nodes[0].text != "ll" && node.nodes[0].text != "loop";
    }
    if (allow || (node.size > 0 && node.nodes[0].text == "lambda"))
        result ~= ';';
    return result;
}

// SUBSECT Do nested search for "recur" in nodes.

bool nodeContainsRecur(AstCtx node) {
    if (node.type == keyword(":symbol") && node.text == "recur") {
        return true;
    }
    return nodesContainRecur(node.nodes);
}

bool nodeContainsRecur(AstNode node) {
    if (node.type == keyword(":symbol") && node.text == "recur") {
        return true;
    }
    return nodesContainRecur(node.nodes);
}

bool nodesContainRecur(AstNode[] astNodes) {
    if (astNodes.size == 0)
        return false;

    foreach (node; astNodes) {
        if (node.type == keyword(":closedScope") && node.size > 0
                && (node.nodes[0].text == "loop" || node.nodes[0].text == "define")) {
            return false;
        }
        if (nodeContainsRecur(node))
            return true;
    }

    return false;
}

// SECTION Warnings / Errors

void warning(string s) {
    import std.stdio;

    stderr.writeln(s);
}

// SECTION

string createOutput(AstCtx ast) {
    return _createOutput(ast);
}

string parseRootNodeIntoContextAndReturnModulename(AstCtx ast) {
    return _parseRootNodeIntoContextAndReturnModulename(ast);
}

string prependReturn(bool requested, string s) {
    if (!requested)
        return s;
    return "return " ~ s;
}

// SECTION Predefined names

bool isPredefinedName(string s) {
    import std.algorithm.searching : canFind;

    return [
        "module", "define", "define-fn", "define-macro", "define-tk-macro", "let",
        "setv!", "ll", "llr", "when", "lambda", "return", "new", "loop", "recur",
        "to", "cast", "opcall", "comment", "def-struct", "struct", "import-sz",
        "import-host", "rt-import-sz", "rt-import-dll", "quote",
        "pseudo-quote", "unquote", "meta"
    ].canFind(s);
}

// SECTION Generate symbol

private shared(ulong) gensymCounter = 0;
string gensym() {
    import std.conv : to;
    import std.datetime.systime;
    import core.atomic : atomicOp;

    return "_gensym_" ~ to!string(Clock.currStdTime() + atomicOp!"+="(gensymCounter, 1));
}

// SECTION Init

bool initialized = false;

string function(AstCtx) _createOutput;
string function(AstCtx) _parseRootNodeIntoContextAndReturnModulename;

void initialize(string function(AstCtx) crOutput, string function(AstCtx) parseRoot) {
    if (!initialized) {
        _createOutput = crOutput;
        _parseRootNodeIntoContextAndReturnModulename = parseRoot;
        initialized = true;
    }
}
