module compiler.output.imports;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.stdlib;

import std.array;

// SECTION import-host

string importHostToString(AstNode ast) {
    auto nodes = ast.nodes[1 .. $];

    // Handle some errors
    if (nodes.size == 0)
        throw new CompilerError("Too few arguments for import-host.");
    if (nodes[0].type != keyword(":symbol") && nodes[0].type != keyword(":litString")) {
        throw new CompilerError("import-host: Module name must be string or symbol.");
    }

    // Parse name of import
    string nameText;
    if (nodes[0].type == keyword(":litString")) {
        nameText = nodes[0].text[1 .. $ - 1];
    } else {
        nameText = symbolToString(nodes[0]);
    }

    if (nodes.size == 1) {
        // Normal import
        return "import " ~ nameText ~ ";";
    } else if (nodes.size == 2) {
        // Import only specific list of functions.
        if (nodes[1].type != keyword(":closedList") && nodes[1].type != keyword("closedScope"))
            throw new CompilerError(
                    "import-host: list of imported functions must be a list. '(...)' or '[...]'");

        // Build output string
        auto result = appender!string("import ");
        result ~= nameText;
        result ~= " : ";

        for (int i = 0; i < nodes[1].nodes.size; i++) {
            result ~= symbolToString(nodes[1].nodes[i]);
            if (i < nodes[1].nodes.size - 1)
                result ~= ",";
        }
        result ~= ";";
        return result.get();
    } else {
        // Too many arguments
        throw new CompilerError("import-host: Too many arguments.");
    }
}

// SECTION import-sz

string importShazaToString(AstNode ast) {
    if (ast.size < 2)
        warning("Import: No file to import: " ~ ast.nodes[0].tknstr() ~ "; Ignoring...");

    auto node = ast.nodes[1];
    auto fname = "";

    if (node.type == keyword(":litString")) {
        fname = node.tkn.text[1 .. $ - 1];
    } else if (node.type == keyword(":symbol")) {
        fname = OutputContext.global.sourcedir ~ "/" ~ node.tkn.text ~ ".sz";
    } else {
        warning("Import: Expecting string or symbol: " ~ ast.nodes[1].tknstr() ~ "; Ignoring...");
        return "";
    }

    import std.file : exists, readText;

    if (!exists(fname)) {
        throw new CompilerError(
                "Import: Shaza file " ~ fname ~ " could not be found." ~ ast.nodes[1].tknstr());
    }

    import compiler.types : Context;
    import compiler.tokenizer : tokenize;
    import compiler.ast : buildBasicAst;

    auto ctx = new Context();
    ctx = tokenize(ctx, readText(fname));
    ctx = buildBasicAst(ctx);
    auto astCtx = AstCtx(ctx.ast, ctx.ast);
    auto importedModuleName = parseRootNodeIntoContextAndReturnModulename(astCtx);

    return "import " ~ importedModuleName ~ ";";
}

// SECTION Include

string includeToString(AstNode ast) {
    if (ast.size < 2)
        warning("No file to import: " ~ ast.nodes[0].tknstr() ~ "; Ignoring...");

    auto node = ast.nodes[1];
    auto fname = "";

    if (node.type == keyword(":litString")) {
        fname = node.tkn.text[1 .. $ - 1];
    } else if (node.type == keyword(":symbol")) {
        fname = OutputContext.global.sourcedir ~ "/" ~ node.tkn.text ~ ".sz";
    } else {
        warning("Expecting string or symbol: " ~ ast.nodes[1].tknstr() ~ "; Ignoring...");
        return "";
    }

    import std.file : exists, readText;

    warning("Including " ~ fname);

    if (!exists(fname)) {
        throw new CompilerError(
                "Import: Shazafile " ~ fname ~ " could not be found." ~ ast.nodes[1].tknstr());
    }

    import compiler.types : Context;
    import compiler.tokenizer : tokenize;
    import compiler.ast : buildBasicAst;

    auto oldImportedModules = OutputContext.global.fullModuleTexts.keys;

    auto ctx = new Context();
    ctx = tokenize(ctx, readText(fname));
    ctx = buildBasicAst(ctx);
    auto astCtx = AstCtx(ctx.ast, ctx.ast);
    auto importedModuleName = parseRootNodeIntoContextAndReturnModulename(astCtx);

    auto output = OutputContext.global.fullModuleTexts[importedModuleName];

    import std.algorithm.searching : canFind;

    if (!oldImportedModules.canFind(importedModuleName))
        OutputContext.global.fullModuleTexts.remove(importedModuleName);

    // SUBSECT Cut "module" declaration
    // FIXME This should be implemented in a safer way...
    import std.string : indexOf;

    output = output[output.indexOf('\n') .. $];

    return output;
}
