module compiler.output.ll;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.stdlib;

import std.array;

// SECTION ll-instruction

// SUBSECT Convert arguments of ll back into their string representation

void llToStringSub(Appender!string result, AstCtx ast) {
    if (ast.type == keyword(":closedList") || ast.type == keyword(":closedTaggedList")) {
        result ~= ast.text; // Empty for closedList, list tag for closedTaggedList
        result ~= '[';
        foreach (child; ast.subs) {
            llToStringSub(result, child);
        }
        result ~= ']';
    } else if (ast.type == keyword(":closedScope")) {
        result ~= '(';
        foreach (child; ast.subs) {
            llToStringSub(result, child);
        }
        result ~= ')';
    } else {
        result ~= ast.text;
        foreach (child; ast.subs) {
            llToStringSub(result, child);
        }
    }
}

// SUBSECT Un-quotify strings from ll-blocks

string llQuotedStringToString(string text) {
    text = text[1 .. $ - 1];
    text = text.replace("\\\"", "\"");
    text = text.replace("\\\r", "\r");
    text = text.replace("\\\n", "\n");
    text = text.replace("\\\t", "\t");
    return text;
}

// SUBSECT ll-instruction main

string llToString(AstCtx ast) {
    auto result = appender("");
    foreach (child; ast.nodes[1 .. $]) {
        if (child.type == keyword(":litString")) {
            result ~= llQuotedStringToString(child.text);
        } else {
            llToStringSub(result, ast(child));
        }
    }
    if (ast.nodes[0].text == "llr" && ast.requestReturn) {
        return prependReturn(true, result.get());
    }
    return result.get();
}
