module compiler.ast;

import std.algorithm.mutation;
import std.stdio;

import compiler.types;
import shaza.buildins;
import shaza.std;

// SECTION AST creation

AstNode[] mergeTopElements(AstNode[] stack) {
    auto last = stack[$ - 1];
    stack[$ - 2].children ~= stack[$ - 1];
    stack = stack[0 .. $ - 1];
    return stack;
}

Context buildBasicAst(Context ctx) {
    import std.conv;

    auto root = new AstNode(Token(0, 0, TknType.root, ""));
    auto stack = [root];
    auto comment_line = -1;
    auto tknIndex = 0;

    foreach (Token current; ctx.tokens) {

        if (current.lineIdx == comment_line) {
            continue;
        }

        if (stack[$ - 1].type == TknType.litType && current.type == TknType.litString) {
            stack[$ - 1].tkn.text ~= current.text;
            stack = mergeTopElements(stack);
            continue;
        }

        switch (current.type) {
        case TknType.litType:
            stack ~= new AstNode(current);
            if (!(current.text.length == 2 && ctx.tokens[tknIndex + 1].type == TknType.litString)) {
                stack = mergeTopElements(stack);
            }
            break;
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
                writeln(stack);
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
                writeln(stack);
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
        root.children ~= stack[i];
    }

    ctx.ast = root;

    return ctx;
}

// SECTION Conversion from AST to Cells

bool isTypedMathOp(string text) {
    return text == "+'" || text == "-'" || text == "*'" || text == "/'" || text == "%'"
        || text == "<<'" || text == ">>'" || text == "bit-and'"
        || text == "bit-or'" || text == "bit-xor'";
}

bool isMathOp(string text) {
    return text == "+" || text == "-" || text == "*" || text == "/" || text == "%"
        || text == "<<" || text == ">>" || text == "bit-and" || text == "bit-or" || text == "bit-xor";
}

bool isBoolOp(string text) {
    return text == "and" || text == "or" || text == "xor" || text == "lsp-and"
        || text == "lsp-or" || text == "lsp-xor";
}

bool isAtom(AstNode ast) {
    auto type = ast.type;
    auto types = [
        TknType.litInt, TknType.litUInt, TknType.litBool, TknType.litString,
        TknType.litKeyword, TknType.symbol, TknType.litFlt
    ];
    foreach (TknType e; types) {
        if (type == e)
            return true;
    }
    return false;
}

Cell parseAtom(AstNode node) {
    import std.conv : to;

    switch (node.type) {
    case TknType.litInt:
        return Cell.wrap(to!long(node.text));
    case TknType.litUInt:
        return Cell.wrap(to!ulong(node.text));
    case TknType.litBool:
        return Cell.wrap(node.text != "#f");
    case TknType.litString:
        return Cell.wrap(node.text[1 .. $ - 1]);
    case TknType.litKeyword:
        return Cell.wrap(Keyword(node.text));
    case TknType.symbol:
        return Cell.wrap(Symbol(node.text));
    case TknType.litFlt:
        return Cell.wrap(to!double(node.text));
    default:
        return null;
    }
}

Cell convertAstToCells(AstNode ast) {
    Cell root = Cell.wrap(null);

    return root;
}
