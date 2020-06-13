module ast;

import std.algorithm.mutation;
import compiler_types;
import buildins;

AstNode[] mergeTopElements(AstNode[] stack) {
    auto last = stack[$-1];
    stack[$-2].children ~= stack[$-1];
    stack.remove(stack.size - 1);
    return stack;
}

Context buildBasicAst(Context ctx) {
    auto root = new AstNode(Token(0, 0, TknType.unknown, ""));
    auto stack = [root];
    auto comment_line = -1;

    foreach (Token current; ctx.tokens) {
        if (current.lineIdx == comment_line) {
            continue;
        }

        switch (current.type) {
            case TknType.scopeOpen:
                stack ~= new AstNode( Token( current.lineIdx,
                  current.charIdx, TknType.closedScope, ""));
                break ;
            case TknType.lstOpen:
                stack ~= new AstNode( Token( current.lineIdx,
                  current.charIdx, TknType.closedList, ""));
                break;
            case TknType.lstTaggedOpen:
                stack ~= new AstNode( Token( current.lineIdx,
                  current.charIdx, TknType.closedTaggedList, ""));
                break ;
            case TknType.lnComment:
                comment_line = current.lineIdx;
                break ;
            case TknType.scopeClose:
            case TknType.lstClose:
                // TODO
                break ;
            default:
                stack ~= new AstNode(current);
                mergeTopElements(stack);
                break;
        }
    }

    return ctx;
}
