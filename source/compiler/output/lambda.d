module compiler.output.lambda;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.std;
import shaza.buildins;

import std.array;

// SECTION Lambdas

string lambdaToString(AstCtx ast) {
    if (ast.size < 3) {
        throw new CompilerError("lambda: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    //if (ast.nodes[1].type != TknType.litType) {
    //    string msg = "Lambda without explicit return type not supported yet. ";
    //    throw new CompilerError(msg ~ ast.nodes[0].tknstr());
    //}
    if (ast.nodes[1].type != TknType.closedScope && ast.nodes[2].type != TknType.closedScope) {
        string msg = "Lambda argument must given in brackets. " ~ ast.nodes[0].tknstr();
        throw new CompilerError(msg);
    }

    auto i = 1;

    AstNode returnTypeNode = ast.nodes[i];
    string returnType = null;

    if (returnTypeNode.type == TknType.closedScope) {
        returnTypeNode = null;
    } else {
        returnType = typeToString(returnTypeNode);
        i++;
    }

    AstNode[] bindings = ast.nodes[i].nodes;
    string[] bindingArgNames = getVarNamesFromBindings(bindings);
    i++;
    AstCtx[] bodyNodes = ast.subs[i .. $];

    auto result = appender("delegate ");
    result ~= returnType;
    result ~= generalFunctionBindingsToString(bindings, null);
    result ~= defineFnToString(returnType, bindingArgNames, bodyNodes, ast);
    return prependReturn(ast.requestReturn, result.get());
}
