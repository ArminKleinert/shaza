module compiler.output.meta;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.stdlib;

import std.array;

// SECTION Parse "meta" instruction

void replaceTkAliases(AstNode root, string replacement, string orig) {
    if (isPredefinedName(orig)) {
        warning("meta, tk-aliases. Warning: overriding predefined name " ~ orig);
    }
    if (root.text == orig) {
        import compiler.tokenizer;

        root.tkn.text = replacement;
        root.tkn.type = tknTypeByText(replacement);
    }
    foreach (child; root.nodes) {
        replaceTkAliases(child, replacement, orig);
    }
}

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
    bool variadic = false;

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
        } else if (attribs.nodes[i].text == ":tk-aliases") {
            i++;
            if (attribs.nodes[i].type != TknType.closedList) {
                throw new CompilerError(
                        "meta: Expected list for attribute tk-aliases. " ~ attribs.nodes[i].tknstr);
            } else if (attribs.nodes[i].size % 2 != 0) {
                throw new CompilerError(
                        "meta: tk-aliases requires even number of arguments. "
                        ~ attribs.nodes[i].tknstr);
            }

            AstNode aliasedStuff = attribs.nodes[i];
            AstNode replacement, orig;
            for (auto i2 = 0; i2 < aliasedStuff.size; i2 += 2) {
                orig = aliasedStuff.nodes[i2];
                replacement = aliasedStuff.nodes[i2 + 1];
                if (!isAtom(orig.tkn) || !isAtom(replacement.tkn)) {
                    throw new CompilerError(
                            "meta: All tokens in tk-aliases must be atomic. "
                            ~ aliasedStuff.nodes[i2].tknstr);
                }
                if (ast.nodes.size > 2) {
                    foreach (child; ast.nodes[2 .. $]) {
                        replaceTkAliases(child, replacement.text, orig.text);
                    }
                }
            }
        } else if (attribs.nodes[i].text == ":variadic") {
            i++;
            if (attribs.nodes[i].type != TknType.litBool) {
                warning(
                        "meta: The :variadic option required a boolean (#t/#f) " ~ attribs.nodes[i].tknstr());
            } else {
                variadic = attribs.nodes[i].text == "#t";
            }
        } else {
            warning("Unknown meta-option. " ~ attribs.nodes[i].tknstr());
        }
    }

    // SUBSECT Create and parse function

    auto meta = new FnMeta(exportName, visibility, aliases, generics, returnType, variadic);
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
