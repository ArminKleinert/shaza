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

// SECTION Literal identifiers

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
}

bool isKeywordLiteral(string text) {
    return text.size > 1 && text[0] == ':' && isValidSymbolText(text[1 .. $]);
}

bool isBoolLiteral(string text) {
    return text == "#t" || text == "#f";
}

// SUBSECT Token-type-table

TknType tknTypeByText(string text) {
    if (!toIntOrNull(text).isNull()) {
        return TknType.litInt;
    } else if (!toUIntOrNull(text).isNull()) {
        return TknType.litUInt;
    } else if (!toUIntOrNull(text).isNull()) {
        return TknType.litUInt;
    } else if (!toFloatOrNull(text).isNull()) {
        return TknType.litFlt;
    } else if (isBoolLiteral(text)) {
        return TknType.litBool;
    } else if (isKeywordLiteral(text)) {
        return TknType.litKeyword;
    } else if (isTypeLiteral(text)) {
        return TknType.litType;
    } else if (isValidSymbolText(text)) {
        return TknType.symbol;
    } else if (isStringLiteral(text)) {
        return TknType.litString;
    } else if (text == "Set[" || text == "Map[" || text == "Lst[") {
        return TknType.lstTaggedOpen;
    } else if (text == "[") {
        return TknType.lstOpen;
    } else if (text == "]") {
        return TknType.lstClose;
    } else if (text == "(") {
        return TknType.scopeOpen;
    } else if (text == ")") {
        return TknType.scopeClose;
    } else if (text == ";") {
        return TknType.lnComment;
    }
    return TknType.unknown;
}

// SECTION Token-creation methods

// SUBSECT Close token; Reset context

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
    ctx.isInTypeLiteral = false;
    return ctx;
}

// SUBSECT Create token

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
        if (!ctx.isInTypeLiteral) {
            ctx = closeToken(ctx);
        }
        ctx.isInString = true;
        ctx.currTknText = ctx.currTknText ~ c;
    } else if (c == ':' && ctx.currTknText == ":") {
        ctx.isInTypeLiteral = true;
        ctx.currTknText ~= c;
    } else if (c == ' ' || c == '\t' || c == '\n') {
        ctx = closeToken(ctx);
    } else if (!ctx.isInTypeLiteral && (c == '(' || c == ')' || c == ']')) {
        ctx = closeToken(ctx);
        ctx.currTknText = ctx.currTknText ~ c;
        ctx = closeToken(ctx);
    } else if (!ctx.isInTypeLiteral && c == '[') {
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

// SECTION Main

string parseFully(string script) {
    auto ctx = new Context();
    ctx = tokenize(ctx, script);
    ctx = buildBasicAst(ctx);
    writeln("HERE");
    return createOutput(ctx.ast);
}

void main() {
    import std.file;

    string txt = readText("./szstd.sz");
    //    writeln(parseFully(txt));
    //string txt = "(define abc 0)";
    auto ctx = new Context();
    ctx = tokenize(ctx, txt);
    ctx = buildBasicAst(ctx);
    writeln(createOutput(ctx.ast));
}
