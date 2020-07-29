module compiler.ast;

import std.algorithm.mutation;
import std.stdio;

import compiler.types;
import shaza.buildins;

AstNode[] mergeTopElements(AstNode[] stack) {
    auto last = stack[$ - 1];
    stack[$ - 2].children ~= stack[$ - 1];
    stack = stack[0 .. $ - 1];
    return stack;
}

Context buildBasicAst(Context ctx) {
    auto root = new AstNode(Token(0, 0, TknType.root, ""));
    auto stack = [root];
    auto comment_line = -1;

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
                auto err = "Attempting to close root node.";
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
                import std.conv;

                throw new CompilerError("The closing token " ~ to!string(
                        current) ~ " isn't closing anything.");
            }
            break;
        default:
            stack ~= new AstNode(current);
            stack = mergeTopElements(stack);
            break;
        }
    }

    for (auto i = 1; i < stack.size(); i++) {
        root.children ~= stack[i];
    }

    ctx.ast = root;

    return ctx;
}
