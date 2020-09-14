module compiler.output.create_module;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.stdlib;

import std.array;

// SECTION module

string retrieveModuleName(AstNode modulecallAst) {
    return modulecallAst.nodes[1].symbolToString();
}

string moduleToString(AstNode ast) {
    if (ast.nodes.size < 2)
        throw new CompilerError("module: Too few arguments. " ~ ast.nodes[0].tknstr());
    if (ast.nodes[1].type != keyword(":symbol"))
        throw new CompilerError("module: Name has to be a symbol. " ~ ast.nodes[1].tknstr());

    string modulename = retrieveModuleName(ast);

    // Module already exists. It was probably imported.
    if (!OutputContext.global.addModule(modulename))
        return null;

    return "module " ~ modulename ~ ";\n";
}
