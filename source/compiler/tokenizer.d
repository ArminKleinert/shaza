module compiler.tokenizer;

import std.stdio;
import std.conv : to;
import std.typecons;
import std.string;
import std.algorithm;

import shaza.stdlib;

import compiler.types;

// SECTION Literal identifiers

bool lastCharMustBeSeperated(string text) {
    return (text[$ - 1] == ')' && !text.canFind('(')) || (text[$ - 1] == ']'
            && !text.canFind('[')) || (text[$ - 1] == '}' && !text.canFind('{')) || text[$ - 1] == ';';
}

auto last_char_must_separated_Q(string text) {
    return or(and(ends_with_Q(text, ")"), not(in_Q(text, "("))), and(ends_with_Q(text,
            "]"), not(in_Q(text, "["))), and(ends_with_Q(text, "}"), not(in_Q(text, "{"))));
}

// SUBSECT Token-type-table

bool is_string_literal_Q(string text) {
    return and(ge_Q(size(text), 2), starts_with_Q(text, "\""),
            ends_with_Q(text, "\""), not(ends_with_Q(text, "\\\"")));
}

bool is_valid_symbol_text_Q(string text) {
    return none_Q(delegate bool(immutable(char) c) { return includes_Q(text, c); }, "\";()[]{}#:");
}

bool is_type_literal_Q(string text) {
    return starts_with_Q(text, "::");
}

bool is_keyword_literal_Q(string text) {
    return and(ge_Q(size(text), 1), starts_with_Q(text, ":"), is_valid_symbol_text_Q(rest(text)));
}

bool is_bool_literal_Q(string text) {
    return or(eql_Q(text, "#t"), eql_Q(text, "#f"));
}

bool is_char_literal_Q(string text) {
    return if2(eql_Q(size(text), 2), starts_with_Q(text, "\\"),
            and(gt_Q(size(text), 2), in_Q([
                    "\\space", "\\newline", "\\tab", "\\colon"
                ], text)));
}

Keyword tkn_type_by_text(string text) {
    return if2(to_ulong_valid_Q(text), keyword(":litUInt"), if2(to_long_valid_Q(text),
            keyword(":litInt"), if2(to_double_valid_Q(text), keyword(":litFlt"),
            if2(is_bool_literal_Q(text), keyword(":litBool"), if2(is_keyword_literal_Q(text),
            keyword(":litKeyword"), if2(is_type_literal_Q(text), keyword(":litType"),
            if2(is_char_literal_Q(text), keyword(":litChar"), if2(is_valid_symbol_text_Q(text),
            keyword(":symbol"), if2(is_string_literal_Q(text), keyword(":litString"),
            if2(eql_Q(text, "["), keyword(":lstOpen"), if2(eql_Q(text, "]"),
            keyword(":lstClose"), if2(eql_Q(text, "("), keyword(":scopeOpen"),
            if2(eql_Q(text, ")"), keyword(":scopeClose"), if2(eql_Q(text, ";"),
            keyword(":lnComment"), keyword(":unknown")))))))))))))));
}

// SECTION Token-creation methods

// SUBSECT Close token; Reset context

Context close_token(Context ctx) {
    auto txt = ctx.currTknText;
    if (ctx.isInTypeLiteral) {
        if (!is_type_literal_Q(txt)) {
            auto tknTextForErrors = Token(ctx.currTknStartLine,
                    ctx.currTknStartChar, keyword(":litType"), txt).as_readable();
            throw new CompilerError("Illegal type literal: " ~ tknTextForErrors);
        } else if (last_char_must_separated_Q(txt)) {
            auto tkntxt = txt[0 .. $ - 1];
            auto type = tkn_type_by_text(tkntxt);
            auto tkn = Token(ctx.currTknStartLine, ctx.currTknStartChar, type, tkntxt);
            ctx.tokens ~= tkn;

            tkntxt = "" ~ txt[$ - 1];
            type = tkn_type_by_text(tkntxt);
            auto tkn2 = Token(ctx.currTknStartLine, ctx.currTknStartChar, type, tkntxt);
            ctx.tokens ~= tkn2;

            txt = ""; // Skip normal closing of token!
        }
    }
    if (txt.size > 0) {
        auto type = tkn_type_by_text(ctx.currTknText);
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
        ctx = close_token(ctx);
    } else if (!ctx.nextEscaped && c == '\\') {
        ctx.nextEscaped = true;
    }
    return ctx;
}

Context tokenize_sub_next_char(Context ctx, char c) {
    if (c == '"') {
        if (!ctx.isInTypeLiteral) {
            ctx = close_token(ctx);
        }
        ctx.isInString = true;
        ctx.currTknText = ctx.currTknText ~ c;
    } else if (c == ':' && ctx.currTknText == ":") {
        ctx.isInTypeLiteral = true;
        ctx.currTknText ~= c;
    } else if (c == ' ' || c == '\t' || c == '\n') {
        ctx = close_token(ctx);
    } else if ((c == ']' && !ctx.currTknText.canFind('[')) || (c == ')'
            && !ctx.currTknText.canFind('(')) || (c == '}' && !ctx.currTknText.canFind('{'))) {
        ctx = close_token(ctx);
        ctx.currTknText = ctx.currTknText ~ c;
        ctx = close_token(ctx);
    } else if (!ctx.isInTypeLiteral && (c == '(' || c == ')' || c == ']')) {
        ctx = close_token(ctx);
        ctx.currTknText = ctx.currTknText ~ c;
        ctx = close_token(ctx);
    } else if (!ctx.isInTypeLiteral && c == '[') {
        auto txt = ctx.currTknText;
        if (txt == "Set" || txt == "Map" || txt == "Lst" || txt == "Vec") {
            ctx.currTknText = ctx.currTknText ~ c;
            ctx = close_token(ctx);
        } else {
            ctx.currTknText = ctx.currTknText ~ c;
            ctx = close_token(ctx);
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
            ctx = tokenize_sub_next_char(ctx, c);
        }
    }
    ctx = close_token(ctx);

    return ctx;
}
