module compiler.ast;

import std.algorithm.mutation;
import std.stdio;

import compiler.types;
import shaza.buildins;
import shaza.stdlib;

// SECTION AST creation

AstNode[] mergeTopElements(AstNode[] stack) {
    auto last = stack[$ - 1];
    stack[$ - 2] ~= stack[$ - 1];
    stack = stack[0 .. $ - 1];
    return stack;
}

Context buildBasicAst(Context ctx) {
    import std.conv;

    auto root = new AstNode(Token(0, 0, keyword(":root"), ""));
    auto stack = [root];
    auto comment_line = -1;
    auto tknIndex = 0;

    foreach (Token current; ctx.tokens) {

        if (current.lineIdx == comment_line) {
            continue;
        }

        switch (current.type) {
        case TknType.scopeOpen:
            stack ~= new AstNode(Token(current.lineIdx,
                    current.charIdx, TknType.closedScope, ""));
            break;
        case TknType.lstOpen:
            stack ~= new AstNode(Token(current.lineIdx,
                    current.charIdx, TknType.closedList, ""));
            break;
        case TknType.lstTaggedOpen:
            stack ~= new AstNode(Token(current.lineIdx,
                    current.charIdx, TknType.closedTaggedList, current.text[0 .. $ - 1]));
            break;
        case TknType.lnComment:
            comment_line = current.lineIdx;
            break;
        case TknType.scopeClose:
        case TknType.lstClose:
            auto list_node = stack[$ - 1];
            auto list_token = list_node.tkn;
            if (list_node == root) {
                auto err = "Attempting to close root node: " ~ to!string(current);
                throw new CompilerError(err);
            }
            auto is_valid = list_token.type == TknType.closedList && current.type
                == TknType.lstClose;
            is_valid = is_valid || (list_token.type == TknType.closedTaggedList
                    && current.type == TknType.lstClose);
            is_valid = is_valid || (list_token.type == TknType.closedScope
                    && current.type == TknType.scopeClose);
            if (is_valid) {
                stack = mergeTopElements(stack);
            } else {
                throw new CompilerError("The closing token " ~ to!string(
                        current) ~ " isn't closing anything.");
            }
            break;
        default:
            stack ~= new AstNode(current);
            stack = mergeTopElements(stack);
            break;
        }

        tknIndex++;
    }

    for (auto i = 1; i < stack.size(); i++) {
        root ~= stack[i];
        stderr.writeln("Unclosed token: " ~ stack[i].tknstr());
    }

    ctx.ast = root;

    return ctx;
}
