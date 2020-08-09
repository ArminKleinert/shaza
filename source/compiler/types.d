module compiler.types;

import std.array;
import std.conv;
import shaza.buildins;

// SECTION Types

// SUBSECT CompilerError

class CompilerError : Error {
    public this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

// SUBSECT Token

enum TknType : byte {
    unknown,
    root,
    litInt,
    litUInt,
    litFlt,
    litBool,
    litString,
    litList,
    litMap,
    litKeyword,
    litType,
    symbol,
    buildinFnCall,
    buildinMacroCall,
    scopeOpen,
    scopeClose,
    lstOpen,
    lstTaggedOpen,
    lstClose,
    closedScope,
    closedTaggedList,
    closedList,
    lnComment,
}

struct Token {
    const int lineIdx;
    const int charIdx;
    const TknType type;
    const string text;

    this(int lineIdx, int charIdx, TknType type, string text) {
        this.lineIdx = lineIdx;
        this.charIdx = charIdx;
        this.type = type;
        this.text = text;
    }

    const string as_readable() @property {
        import std.conv : to;

        return to!string(this);
    }
}

// SUBSECT Abstract Syntax Tree (AST)

class AstNode {
    const Token tkn;
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

    TknType type() {
        return tkn.type;
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
}

// SECTION Helpers

// SUBSECT Token type helpers

bool isLiteral(Token tkn) {
    switch (tkn.type) {
    case TknType.litInt:
    case TknType.litUInt:
    case TknType.litFlt:
    case TknType.litBool:
    case TknType.litString:
    case TknType.litList:
    case TknType.litMap:
    case TknType.litKeyword:
    case TknType.litType:
    case TknType.symbol:
        return true;
    default:
        return false;
    }
}

bool isOpener(Token tkn) {
    switch (tkn.type) {
    case TknType.scopeOpen:
    case TknType.lstOpen:
    case TknType.lstTaggedOpen:
        return true;
    default:
        return false;
    }
}

bool isCloser(Token tkn) {
    switch (tkn.type) {
    case TknType.scopeClose:
    case TknType.lstClose:
        return true;
    default:
        return false;
    }
}

bool isSimpleLiteral(Token tkn) {
    switch (tkn.type) {
    case TknType.litInt:
    case TknType.litUInt:
    case TknType.litFlt:
    case TknType.litBool:
        return true;
    default:
        return false;
    }
}

// SUBSECT Other helpers

string get(Appender!string ap) {
    return ap[];
}
