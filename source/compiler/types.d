module compiler.types;

import std.array;
import std.conv;
import shaza.buildins;

class CompilerError : Error {
    public this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

enum TknType : byte {
    unknown,
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
    int lineIdx;
    int charIdx;
    TknType type;
    string text;

    this(int lineIdx, int charIdx, TknType type, string text) {
        this.lineIdx = lineIdx;
        this.charIdx = charIdx;
        this.type = type;
        this.text = text;
    }
}

class AstNode {
    Token tkn;
    AstNode[] children;
    int argc;

    this(Token tkn, AstNode[] children) {
        this.tkn = tkn;
        this.children = children;
    }

    this(Token tkn) {
        this(tkn, []);
    }

    public override string toString() {
        string[] res = [];
        auto result = appender(&res);
        result.put(["\nAstNode { token=", to!string(tkn), "\nchildren=["]);
        foreach (AstNode child; children) {
            result.put(child.toString());
        }
        result.put("] }");
        return result[].join();
    }
}

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
}

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
