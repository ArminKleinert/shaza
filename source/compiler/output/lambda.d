module compiler.output.lambda;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.std;
import shaza.buildins;

import std.array;

// SECTION Lambdas

string lambdaToString(AstCtx ast) {
    if (ast.size < 4) {
        throw new CompilerError("lambda: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    if (ast.nodes[1].type != TknType.litType) {
        string msg = "Lambda without explicit return type not supported yet. ";
        throw new CompilerError(msg ~ ast.nodes[0].tknstr());
    }
    if (ast.nodes[2].type != TknType.closedScope) {
        string msg = "Lambda argument must given in brackets. " ~ ast.nodes[0].tknstr();
        throw new CompilerError(msg);
    }

    AstNode returnType = ast.nodes[1];
    AstNode[] bindings = ast.nodes[2].nodes;
    string[] bindingArgNames = getVarNamesFromBindings(bindings);
    AstCtx[] bodyNodes = ast.subs[3 .. $];

    auto result = appender("delegate ");
    result ~= typeToString(returnType);
    result ~= generalFunctionBindingsToString(bindings);
    result ~= defineFnToString(typeToString(returnType), bindingArgNames, bodyNodes, ast);
    return prependReturn(ast.requestReturn, result.get());
}
