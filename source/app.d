import std.stdio;

enum TknType : byte {
    unknown,
    litValue,
    symbol,
    buildinFnCall,
    buildinMacroCall,
    scopeOpen,
    scopeClose,
    lstOpen,
    lstTaggedOpen,
    lstClose,
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
    
    this(Token tkn, AstNode[] children) {
        this.tkn = tkn;
        this.children = children;
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

TknType tknTypeByText(string text) {
    return TknType.unknown;
}

Context closeToken(Context ctx) {
    if (ctx.currTknText.length > 0) {
        auto type = tknTypeByText(ctx.currTknText);
        auto tkn = Token(
            ctx.currTknStartLine, ctx.currTknStartChar,
            type, ctx.currTknText);
        ctx.tokens ~= tkn;
    }
    ctx.currTknText = "";
    ctx.currTknStartLine = ctx.currTknLine;
    ctx.currTknStartChar = ctx.currTknChar;
    ctx.nextEscaped = false;
    ctx.isInString = false;
    return ctx;
}

Context tokenizeSubNextCharInString(Context ctx, char c) {
    ctx.currTknText = ctx.currTknText ~ c;
    if (ctx.nextEscaped) {
        ctx.nextEscaped = false;
    } else if (c == '"' && !ctx.nextEscaped) {
        ctx = closeToken(ctx);
    } else if (!ctx.nextEscaped && c == '\\') {
        ctx.nextEscaped = true;
    }
    return ctx;
}

Context tokenizeSubNextChar(Context ctx, char c) {
    if (c == '"') {
        ctx = closeToken(ctx);
        ctx.isInString = true;
        ctx.currTknText = ctx.currTknText ~ c;
    } else if (c == ' ' || c == '\t') {
        ctx = closeToken(ctx);
    } else if (c == '\n') {
        ctx = closeToken(ctx);
    } else {
        ctx.currTknText = ctx.currTknText ~ c;
    }
    return ctx;
}

Context tokenize(Context ctx, string source) {
    foreach (char c; source) {
        ctx.currTknChar += 1;
        if (c == '\n') {
            ctx.currTknLine += 1;
            ctx.currTknChar = 0;
        }
        if (ctx.isInString) {
            ctx = tokenizeSubNextCharInString(ctx, c);
        } else {
            ctx = tokenizeSubNextChar(ctx, c);
        }
    }
    ctx = closeToken(ctx);
    
    return ctx;
}

void main()
{
    auto ctx = new Context();
    ctx = tokenize(ctx, "fncall customns/fncall var" ~
    "\"string\" \"string\nwith\nlinebreak\""~
    ":keyword" ~ 
    "::typeliteral" ~
    "15 15u 0xF 0b1111 0xFu 0b1111u" ~
    "15.0 15f 15.f" ~
    "#t #f nil" ~
    "() [] Lst[] (+ 1 1)");
    writeln(ctx.tokens);
}
