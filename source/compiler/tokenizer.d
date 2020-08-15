module compiler.tokenizer;

import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;

import shaza.buildins;
import shaza.std;

import compiler.types;

// Helper, delete when possible
int idxOf(string text, char c) {
    for (auto i = 0; i < text.size; i++) {
        if (text[i] == c)
            return i;
    }
    return -1;
}

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

bool isCharLiteral(string text) {
    if (text.size < 2)
        return false;
    return text == "\\space" || text == "\\newline" || text == "\\tab"
    || (text[0] == "\\"[0] && text.size == 2);
}

bool isValidTypeLiteral(string text) {
    // Handle bracket
    auto idx_of_ob = text.idxOf('(');
    auto idx_of_cb = text.idxOf(')');
    if (idx_of_ob >= 0 && idx_of_ob > idx_of_cb)
        return false;

    // Handle curly brace
    auto idx_of_ocb = text.idxOf('{');
    auto idx_of_ccb = text.idxOf('}');
    if (idx_of_ocb >= 0 && idx_of_ocb > idx_of_ccb)
        return false;

    // Handle square brackets
    auto idx_of_osb = text.idxOf('[');
    auto idx_of_csb = text.idxOf(']');
    if (idx_of_osb >= 0 && idx_of_osb > idx_of_csb)
        return false;

    // When a closing bracket, closing curly brace or square
    // brace is at the end, we are find also.
    auto last_text_idx = text.size - 1;
    if (idx_of_ob < 0 && idx_of_cb >= 0 && idx_of_cb != last_text_idx)
        return false;
    if (idx_of_ocb < 0 && idx_of_ccb >= 0 && idx_of_ccb != last_text_idx)
        return false;
    if (idx_of_osb < 0 && idx_of_csb >= 0 && idx_of_csb != last_text_idx)
        return false;

    return true;
}

bool lastCharMustBeSeperated(string text) {
    return (text[$ - 1] == ')' && !text.canFind('(')) || (text[$ - 1] == ']'
    && !text.canFind('[')) || (text[$ - 1] == '}' && !text.canFind('{')) || text[$ - 1] == ';';
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
    } else if (isCharLiteral(text)) {
        return TknType.litChar;
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
    auto txt = ctx.currTknText;
    if (ctx.isInTypeLiteral) {
        if (!isValidTypeLiteral(txt)) {
            auto tknTextForErrors = Token(ctx.currTknStartLine,
            ctx.currTknStartChar, TknType.litType, txt).as_readable();
            throw new CompilerError("Illegal type literal: " ~ tknTextForErrors);
        } else if (lastCharMustBeSeperated(txt)) {
            auto tkntxt = txt[0 .. $ - 1];
            auto type = tknTypeByText(tkntxt);
            auto tkn = Token(ctx.currTknStartLine, ctx.currTknStartChar, type, tkntxt);
            ctx.tokens ~= tkn;

            tkntxt = "" ~ txt[$ - 1];
            type = tknTypeByText(tkntxt);
            auto tkn2 = Token(ctx.currTknStartLine, ctx.currTknStartChar, type, tkntxt);
            ctx.tokens ~= tkn2;

            txt = ""; // Skip normal closing of token!
        }
    }
    if (txt.size > 0) {
        auto type = tknTypeByText(ctx.currTknText);
        auto tkn = Token(ctx.currTknStartLine, ctx.currTknStartChar, type, txt);
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
    } else if ((c == ']' && !ctx.currTknText.canFind('[')) || (c == ')'
    && !ctx.currTknText.canFind('(')) || (c == '}' && !ctx.currTknText.canFind('{'))) {
        ctx = closeToken(ctx);
        ctx.currTknText = ctx.currTknText ~ c;
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
