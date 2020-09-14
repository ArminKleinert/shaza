module compiler.output.defmacro;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.stdlib;

import std.array : appender;

string defmacroToString(AstCtx ast) {
    if (ast.size < 3 || ast[1].type != keyword(":symbol") || ast[2].type != keyword(":closedScope")) {
        throw new CompilerError(
                "defmacro must have the following form: (defmacro <symbol> (<bindings>) &<body>)");
    }

    auto res = appender("AstNode ");
    res ~= symbolToString(ast[1]);
    res ~= "(";

    AstNode[] bindings = ast[2].nodes;
    string[] bindingNames = [];
    for (auto i = 0; i < bindings.size; i++) {
        bindingNames ~= symbolToString(bindings[i]);
        res ~= "AstNode ";
        res ~= bindingNames[i];
        if (i < bindings.size - 1)
            res ~= ", ";
    }

    res ~= ")";
    res ~= defineFnToString("AstNode", bindingNames, ast[3].subs, ast);
    return res.get();
}
