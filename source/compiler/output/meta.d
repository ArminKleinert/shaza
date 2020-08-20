module meta;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.std;

import std.array;

// SECTION Parse "meta" instruction

string parseMetaGetString(AstCtx ast) {
    return parseMetaGetString(ast, null);
}

string parseMetaGetString(AstCtx ast, FnMeta parentMeta) {
    if (ast.size < 3) {
        throw new CompilerError("meta: Too few arguments. " ~ ast.nodes[0].tknstr());
    }

    auto attribs = ast.nodes[1];
    auto wrapped = ast.nodes[2 .. $];

    // Crash if attribute list is invalid
    expectType(attribs, TknType.closedScope);

    // SUBSECT Parse attributes

    // Default values
    string visibility = "";
    string[] generics = [];
    string[] aliases = [];
    string exportName = null;
    string returnType = null;

    // Currently accepted options are :generics, :visibility, :aliases, :export-as
    for (auto i = 0; i < attribs.size; i++) {
        expectType(attribs.nodes[i], TknType.litKeyword);
        if (attribs.nodes[i].text == ":generics") {
            i++;
            expectType(attribs.nodes[i], TknType.litList, TknType.closedList);
            foreach (genNode; attribs.nodes[i].nodes) {
                expectType(genNode, TknType.litType);
                generics ~= typeToString(genNode);
            }
        } else if (attribs.nodes[i].text == ":visibility") {
            i++;
            expectType(attribs.nodes[i], TknType.litKeyword);
            visibility = keywordToString(attribs.nodes[i]);
        } else if (attribs.nodes[i].text == ":returns") {
            i++;
            expectType(attribs.nodes[i], TknType.litType);
            returnType = typeToString(attribs.nodes[i]);
        } else if (attribs.nodes[i].text == ":aliases") {
            i++;
            //if (wrapped.size > 1) {
            //    stderr.writeln(
            //            ":aliases only allowed for one function per meta-block. " ~ attribs.nodes[i].tknstr());
            //} else {
            expectType(attribs.nodes[i], TknType.litList, TknType.closedList);
            foreach (aliasNode; attribs.nodes[i].nodes) {
                expectType(aliasNode, TknType.symbol);
                aliases ~= aliasNode.text;
            }
            //}
        } else if (attribs.nodes[i].text == ":export-as") {
            i++;
            //if (wrapped.size > 1) {
            //    stderr.writeln(
            //            ":export-as only allowed for one function per meta-block. " ~ attribs.nodes[i].tknstr());
            //} else {
            expectType(attribs.nodes[i], TknType.litString);
            exportName = attribs.nodes[i].text[1 .. $ - 1];
            //}
        } else {
            warning("Unknown meta-option. " ~ attribs.nodes[i].tknstr());
        }
    }

    // SUBSECT Create and parse function

    auto meta = new FnMeta(exportName, visibility, aliases, generics, returnType);
    if (parentMeta !is null) {
        meta = parentMeta.combineWith(meta);
    }

    auto result = appender("");

    foreach (c; wrapped) {
        if (c.nodes[0].text == "meta") {
            result ~= parseMetaGetString(ast(c), meta);
        } else if (c.nodes[0].text != "define" && c.nodes[0].text != "define-fn") {
            string msg = "meta can only be used on function definitions. Otherwise, it is ignored. ";
            warning(msg ~ ast.nodes[0].tknstr());
            result ~= createOutput(ast(c));
        } else {
            auto forceIsFn = c.text == "define-fn";
            result ~= generalDefineToString(ast(c), forceIsFn, meta);
        }
    }

    return result.get();
}
