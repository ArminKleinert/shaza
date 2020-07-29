import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;

import shaza.buildins;

import compiler.types;
import compiler.ast;
import compiler.output;

bool isStringLiteral(string text) {
    return text.size >= 2 && text[0] == '"' && text[$ - 1] == '"' && text[$ - 2] != 92;
}

bool isValidSymbolText(string text) {
    // Not allowed: '"', ';', '(', ')', '[', ']', '{', '}', '#', ':'
    foreach (char c; "\";()[]{}#:") {
        if (text.canFind(c))
            return false;
    }
    return true;
}

bool isTypeLiteral(string text) {
    return text.size > 2 && text[0] == ':' && text[1] == ':';
    // return text.size > 2 && text[0] == ':' && text[1] == ':' && isValidSymbolText(text[2 .. $]);
}

bool isKeywordLiteral(string text) {
    return text.size > 1 && text[0] == ':' && isValidSymbolText(text[1 .. $]);
}

bool isBoolLiteral(string text) {
    return text == "#t" || text == "#f";
}

TknType tknTypeByText(string text) {
    if (!toIntOrNull(text).isNull()) {
        return TknType.litInt;
    }
    if (!toUIntOrNull(text).isNull()) {
        return TknType.litUInt;
    }
    if (!toUIntOrNull(text).isNull()) {
        return TknType.litUInt;
    }
    if (!toFloatOrNull(text).isNull()) {
        return TknType.litFlt;
    }
    if (isBoolLiteral(text)) {
        return TknType.litBool;
    }
    if (isKeywordLiteral(text)) {
        return TknType.litKeyword;
    }
    if (isTypeLiteral(text)) {
        return TknType.litType;
    }
    if (isValidSymbolText(text)) {
        return TknType.symbol;
    }
    if (isStringLiteral(text)) {
        return TknType.litString;
    }
    if (text == "Set[" || text == "Map[" || text == "Lst[") {
        return TknType.lstTaggedOpen;
    }
    if (text == "[") {
        return TknType.lstOpen;
    }
    if (text == "]") {
        return TknType.lstClose;
    }
    if (text == "(") {
        return TknType.scopeOpen;
    }
    if (text == ")") {
        return TknType.scopeClose;
    }
    if (text == ";") {
        return TknType.lnComment;
    }
    return TknType.unknown;
}

Context closeToken(Context ctx) {
    if (ctx.currTknText.size > 0) {
        auto type = tknTypeByText(ctx.currTknText);
        auto tkn = Token(ctx.currTknStartLine, ctx.currTknStartChar, type, ctx.currTknText);
        ctx.tokens ~= tkn;
    }
    ctx.currTknText = "";
    ctx.currTknStartLine = ctx.currTknLine;
    ctx.currTknStartChar = ctx.currTknChar;
    ctx.nextEscaped = false;
    ctx.isInString = false;
    ctx.isInSpecialExpression = false;
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
    } else if (c == ':' && ctx.currTknText == ":") {
        ctx.isInSpecialExpression = true;
        ctx.currTknText ~= c;
    } else if (c == ' ' || c == '\t' || c == '\n') {
        ctx = closeToken(ctx);
    } else if (!ctx.isInSpecialExpression && (c == '(' || c == ')' || c == ']')) {
        ctx = closeToken(ctx);
        ctx.currTknText = ctx.currTknText ~ c;
        ctx = closeToken(ctx);
    } else if (!ctx.isInSpecialExpression && c == '[') {
        auto txt = ctx.currTknText;
        if (txt == "Set" || txt == "Map" || txt == "Lst" || txt == "Vec") {
            ctx.currTknText = ctx.currTknText ~ c;
            ctx = closeToken(ctx);
        } else {
            ctx.currTknText = ctx.currTknText ~ c;
            ctx = closeToken(ctx);
        }
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

string parseFully(string script) {
    auto ctx = new Context();
    ctx = tokenize(ctx, script);
    ctx = buildBasicAst(ctx);
    return createOutput(ctx.ast);
}

void times(int n, int delegate(int) f) {
    while (n > 0) {
        f(n--);
    }
}

void main() {
    int hi(int i) {
        writeln(i);
        return i;
    }

    times(10, &hi);
    /*
    auto ctx = new Context();
    ctx = tokenize(ctx, "fncall customns/fncall var " ~ "\"string\" \"string\nwith\nlinebreak\" "
            ~ ":keyword ::typeliteral ::int[string] 15 15u 0xF 0b1111 0xFu 0b1111u "
            ~ "15.0 15f 15.f " ~ "#t #f nil " ~ "() [] Lst[] (+ 1 1) ");
    writeln(ctx.tokens);
    writeln();
    //ctx = buildBasicAst(ctx);
    //writeln(ctx.ast);

    AstNode root = new AstNode(Token(0, 0, TknType.closedScope, ""));
    root ~= new AstNode(Token(0, 0, TknType.symbol, "et-define"));
    root ~= new AstNode(Token(0, 0, TknType.litInt, "::int"));
    root ~= new AstNode(Token(0, 0, TknType.litInt, "name"));
    root ~= new AstNode(Token(0, 0, TknType.litInt, "2"));
    writeln(createOutput(root));

    root = new AstNode(Token(0, 0, TknType.closedScope, ""));
    root ~= new AstNode(Token(0, 0, TknType.symbol, "et-define"));
    root ~= new AstNode(Token(0, 0, TknType.litInt, "::int"));
    AstNode sig = new AstNode(Token(0, 0, TknType.closedScope, ""));
    sig ~= new AstNode(Token(0, 0, TknType.litInt, "name"));
    sig ~= new AstNode(Token(0, 0, TknType.litType, "::int"));
    sig ~= new AstNode(Token(0, 0, TknType.symbol, "arg0"));
    sig ~= new AstNode(Token(0, 0, TknType.litType, "::int"));
    sig ~= new AstNode(Token(0, 0, TknType.symbol, "arg1"));
    root ~= sig;
    AstNode returnCall = new AstNode(Token(0, 0, TknType.closedScope, ""));
    returnCall ~= new AstNode(Token(0, 0, TknType.symbol, "return"));
    returnCall ~= new AstNode(Token(0, 0, TknType.litInt, "1"));
    root ~= returnCall;
    writeln(createOutput(root));

    root = new AstNode(Token(0, 0, TknType.closedScope, ""));
    AstNode letNode = new AstNode(Token(0, 0, TknType.symbol, "t-let"));
    root ~= letNode;
    AstNode bindings = new AstNode(Token(0, 0, TknType.closedList, ""));
    bindings ~= new AstNode(Token(0, 0, TknType.litType, "::int"));
    bindings ~= new AstNode(Token(0, 0, TknType.symbol, "arg0"));
    bindings ~= new AstNode(Token(0, 0, TknType.litInt, "1"));
    bindings ~= new AstNode(Token(0, 0, TknType.litType, "::int"));
    bindings ~= new AstNode(Token(0, 0, TknType.symbol, "arg1"));
    bindings ~= new AstNode(Token(0, 0, TknType.litInt, "2"));
    root ~= bindings;
    AstNode bodyNode = new AstNode(Token(0, 0, TknType.closedScope, ""));
    bodyNode ~= new AstNode(Token(0, 0, TknType.symbol, "setv!"));
    bodyNode ~= new AstNode(Token(0, 0, TknType.symbol, "globalvar"));
    AstNode bodyNode2 = new AstNode(Token(0, 0, TknType.closedScope, ""));
    bodyNode2 ~= new AstNode(Token(0, 0, TknType.symbol, "mul"));
    bodyNode2 ~= new AstNode(Token(0, 0, TknType.symbol, "arg0"));
    bodyNode2 ~= new AstNode(Token(0, 0, TknType.symbol, "arg1"));
    bodyNode ~= bodyNode2;
    root ~= bodyNode;
    writeln(createOutput(root));

    writeln();
    root = new AstNode(Token(0, 0, TknType.closedScope, ""));
    root ~= new AstNode(Token(0, 0, TknType.symbol, "ll"));
    root ~= new AstNode(Token(0, 0, TknType.litInt, "8"));
    root ~= new AstNode(Token(0, 0, TknType.litString, "\" \""));
    root ~= new AstNode(Token(0, 0, TknType.symbol, "+"));
    root ~= new AstNode(Token(0, 0, TknType.litString, "\" \""));
    root ~= new AstNode(Token(0, 0, TknType.litInt, "8"));
    writeln(createOutput(root));

    writeln();
    ctx = new Context();
    ctx = tokenize(ctx, "(et-define ::void (helloWorld) (writeln \"Hello World!\"))");
    ctx = buildBasicAst(ctx);
    writeln(createOutput(ctx.ast));

    ctx = new Context();
    ctx = tokenize(ctx, "(gen-define ::T (T) (concat ::T coll0 ::coll1 coll1) (ll coll0 ~= coll1))");
    ctx = buildBasicAst(ctx);
    writeln(createOutput(ctx.ast));
    */

    /*
    string testScript = "(gen-define ::bool (T) (contains ::T[] coll0 ::T value)"
                                                     ~"(let [i 0]"
                                                      ~"(ll while \"(i < size(coll0)) {\")"
                                                      ~"(if (eql? (get coll0 i) value) (return #t) null)"
                                                      ~"(ll \"}\"))"
                                                      ~"#f)";
    */
    string testScript;

    testScript = "(et-define ::int (inc2 ::int i0) (plus (plus i0 1) 1))";
    writeln(parseFully(testScript));

    testScript = "(et-define ::int (plus ::int i0 ::int i1) (ll i0 + i1))";
    writeln(parseFully(testScript));

    testScript = "(et-define ::int n 2)";
    writeln(parseFully(testScript));

    testScript = "(define n2 4)";
    writeln(parseFully(testScript));

    testScript = "(et-define ::int (plus \"int\" i0 ::int i1) (ll i0 + i1))";
    writeln(parseFully(testScript));

}
