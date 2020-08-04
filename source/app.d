import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;

import shaza.buildins;
import shaza.std;

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
    return text.size >= 2 && text[0] == ':' && text[1] == ':';
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

N inc(N)(N n) {
    return n + 1;
}

N dec(N)(N n) {
    return n - 1;
}

/*
void main() {
    import std.file;

    //string txt = readText("./szstd.sz");
    //auto ctx = new Context();
    // tx = tokenize(ctx, txt);
    //writeln(ctx.tokens);
    //writeln(parseFully(txt));
}
*/
