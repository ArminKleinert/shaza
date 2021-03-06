module compiler.types;

import std.array : Appender, replace, appender;
import std.stdio;

import shaza.stdlib;

// SECTION Types

// SUBSECT CompilerError

class CompilerError : Error {
    public this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

// SUBSECT Token

struct Token {
    const int lineIdx;
    const int charIdx;
    Keyword type;
    string text;

    this(int lineIdx, int charIdx, Keyword type, string text) {
        this.lineIdx = lineIdx;
        this.charIdx = charIdx;
        this.type = type;
        this.text = text;
    }

    this(Keyword type, string text) {
        this(0, 0, type, text);
    }
}

string as_readable(Token t) {
    return to_s(t);
}

// SUBSECT Abstract Syntax Tree (AST)

/*
class AstNode {
    Token tkn;
    private AstNode[] children;

    this(Token tkn, AstNode[] children) {
        this.tkn = tkn;
        this.children = children;
    }

    this(Token tkn) {
        this(tkn, []);
    }

    string text() {
        return tkn.text;
    }

    Keyword type() {
        return tkn.type;
    }

    string tknstr() {
        return tkn.as_readable();
    }

    size_t size() {
        return children.length;
    }

    AstNode[] nodes() {
        return children;
    }

    AstNode opOpAssign(string op)(AstNode other) if (op == "~") {
        children ~= other;
        return this;
    }

    public override string toString() {
        string[] res = [];
        auto result = appender(&res);
        result.put(["\nAstNode { token=", to!string(tkn), " children=["]);
        foreach (AstNode child; children) {
            result.put(child.toString());
        }
        result.put("] }");
        return result[].join();
    }
}
*/
class AstNode {
    Token tkn;
    AstNode[] children;
    this(Token _tkn, AstNode[] _children) {
        tkn = _tkn;
        children = _children;
    }

    AstNode with_tkn(Token tkn) {
        return new AstNode(tkn, children);
    }

    AstNode with_children(AstNode[] children) {
        return new AstNode(tkn, children);
    }

    AstNode clone() {
        return new AstNode(tkn, children);
    }
}

auto ast_node(Token tkn, AstNode[] children) {
    return new AstNode(tkn, children);
}

auto ast_node(Token tkn) {
    return new AstNode(tkn, []);
}

auto type(AstNode ast) {
    return ast.tkn.type;
}

auto nodes(AstNode ast) {
    return ast.children;
}

auto ast_size(AstNode ast) {
    return size(ast.children);
}

auto tkn_text(AstNode ast) {
    return ast.tkn.text;
}

auto tknstr(AstNode ast) {
    return str(ast.tkn);
}

string ast_string(AstNode ast) {
    return join([
            "\nAstNode { token=", (ast.tknstr), " children=[",
            reduce(delegate string(AstNode node, string res) {
                return append(res, ast_string(node));
            }, nodes(ast), ""), "] }"
            ]);
}

// SUBSECT Compiler-Context
// Holds helperss for the tokenization phase and AST-Building

class Context {
    Token[] tokens = [];
    AstNode ast = null;

    int currTknLine = 0;
    int currTknChar = 0;
    int currTknStartLine = 0;
    int currTknStartChar = 0;
    bool nextEscaped = false;
    string currTknText = "";
    bool isInString = false;
    bool isInTypeLiteral = false;

    string sourcedir = ".";
}

// SECTION Helpers

// SUBSECT Token type helpers

bool isLiteral(Token tkn) {
    return includes_Q([
            keyword(":litInt"), keyword(":litUInt"), keyword(":litFlt"),
            keyword(":litBool"), keyword(":litString"), keyword(":litList"),
            keyword(":litMap"), keyword(":litKeyword"), keyword(":litType"),
            keyword(":litChar")
            ], tkn.type);
}

bool allowImplicitReturn(string returnType, AstNode command) {
    if (returnType == "void")
        return false;
    if (isAtom(command.tkn))
        return true;
    if (command.type == keyword(":closedList") || command.type == keyword(":closedTaggedList"))
        return true;
    if (command.type != keyword(":closedScope"))
        return false;

    switch (tkn_text(command.nodes[0])) {
    case "return":
    case "let":
    case "define":
    case "ll":
    case "when":
    case "for":
    case "foreach":
    case "while":
    case "loop":
    case "recur":
        return false;
    default:
        return true;
    }
}

bool isAtom(Token tkn) {
    return isLiteral(tkn) || tkn.type == keyword(":symbol");
}

bool isOpener(Token tkn) {
    return includes_Q([
            keyword(":scopeOpen"), keyword(":lstOpen"), keyword(":lstTaggedOpen")
            ], tkn.type);
}

bool isCloser(Token tkn) {
    return includes_Q([keyword(":scopeClose"), keyword(":lstClose")], tkn.type);
}

bool isSimpleLiteral(Token tkn) {
    return includes_Q([
            keyword(":litInt"), keyword(":litUInt"), keyword(":litFlt"),
            keyword(":litBool")
            ], tkn.type);
}

// SUBSECT AST type helper

bool opensScope(AstNode node) {
    if (node.type != keyword(":closedScope"))
        return false;
    if (ast_size(node) == 0)
        return false;
    if (node.type == keyword(":root"))
        return true;

    switch (tkn_text(node.nodes[0])) {
    case "let":
    case "loop":
    case "define":
        return true;
    default:
        return false;
    }
}

// SUBSECT String conversion helpers

string atomToString(AstNode ast) {
    auto text = appender(ast.tkn_text);

    if (ast.type == keyword(":litBool")) {
        text = appender(ast.tkn_text == "#t" ? "true" : "false");
    } else if (ast.type == keyword(":litKeyword")) {
        text = appender("Keyword(\"");
        text ~= ast.tkn_text;
        text ~= "\")";
    } else if (ast.type == keyword(":litChar")) {
        if (ast.tkn_text == "\\space")
            return "' '";
        if (ast.tkn_text == "\\newline")
            return "'\\n'";
        if (ast.tkn_text == "\\tab")
            return "'\\t'";
        return "'" ~ ast.tkn_text[1] ~ "'";
    } else if (ast.type == keyword(":symbol") && ast.tkn_text == "nil") {
        return "null";
    } else if (ast.type == keyword(":symbol")) {
        return szNameToHostName(ast.tkn_text);
    }

    return text.get();
}

string szNameToHostName(string szVarName) {
    if (szVarName.size == 1)
        return szVarName;
    szVarName = szVarName.replace("=", "_");
    szVarName = szVarName.replace("~", "_");
    szVarName = szVarName.replace("-", "_");
    if (szVarName[$ - 1] == '?')
        szVarName = szVarName[0 .. $ - 1] ~ "_Q";
    else if (szVarName[$ - 1] == '!')
        szVarName = szVarName[0 .. $ - 1] ~ "_E";
    return szVarName;
}

string typeToString(AstNode ast) {
    import core.exception;

    try {
        return typeToString(tkn_text(ast));
    } catch (RangeError re) {
        writeln(ast.toString());
        throw re;
    }
}

string typeToString(string litType) {
    assert(litType.size > 2 && litType[0 .. 2] == "::");

    import std.array;

    litType = litType[2 .. $];
    if (litType[0] == '"' && litType[litType.size - 1] == '"') {
        litType = litType[1 .. $ - 1];
    } else {
        litType = litType.replace(":", " ");
    }
    return litType;
}

void expectType(AstNode node, Keyword type) {
    if (node.type != type) {
        string msg = "Expected " ~ str(type) ~ " but got " ~ node.tknstr();
        throw new CompilerError(msg);
    }
}

void expectType(AstNode node, Keyword t1, Keyword t2) {
    if (node.type != t1 && node.type != t2) {
        string msg = "Expected " ~ str(t1) ~ " or " ~ str(t2) ~ " but got " ~ node.tknstr();
        throw new CompilerError(msg);
    }
}

void expectType(AstNode node, Keyword t1, Keyword t2, Keyword t3) {
    if (node.type != t1 && node.type != t2 && node.type != t3) {
        string msg = "Expected " ~ str(t1) ~ " or " ~ str(t2) ~ " or " ~ str(t3);
        throw new CompilerError(msg ~ " but got " ~ node.tknstr());
    }
}

// SUBSECT Other helpers

T get(T)(Appender!T ap) {
    return ap[];
}

bool isValidDIdentifier(string s) {
    import std.algorithm;

    return !s.canFind('=') && !s.canFind('!') && !s.canFind('?');
}
