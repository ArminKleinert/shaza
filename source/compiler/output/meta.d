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
    if (tkn_text(root) == orig) {
        import compiler.tokenizer;

        root.tkn.text = replacement;
        root.tkn.type = tkn_type_by_text(replacement);
    }
    foreach (child; root.nodes) {
        replaceTkAliases(child, replacement, orig);
    }
}

string parseMetaGetString(AstCtx ast) {
    return parseMetaGetString(ast, null);
}

string parseMetaGetString(AstCtx ast, FnMeta parentMeta) {
    if (ast_size(ast) < 3) {
        throw new CompilerError("meta: Too few arguments. " ~ ast.nodes[0].tknstr());
    }

    auto attribs = ast.nodes[1];
    auto wrapped = ast.nodes[2 .. $];

    // Crash if attribute list is invalid
    expectType(attribs, keyword(":closedScope"));

    // SUBSECT Parse attributes

    // Default values
    string visibility = "";
    string[] generics = [];
    string[] aliases = [];
    string exportName = null;
    string returnType = null;
    bool variadic = false;

    // Currently accepted options are :generics, :visibility, :aliases, :export-as
    for (auto i = 0; i < ast_size(attribs); i++) {
        expectType(attribs.nodes[i], keyword(":litKeyword"));
        if (tkn_text(attribs.nodes[i]) == ":generics") {
            i++;
            expectType(attribs.nodes[i], keyword(":litList"), keyword(":closedList"));
            foreach (genNode; attribs.nodes[i].nodes) {
                expectType(genNode, keyword(":litType"));
                generics ~= typeToString(genNode);
            }
        } else if (tkn_text(attribs.nodes[i]) == ":visibility") {
            i++;
            expectType(attribs.nodes[i], keyword(":litKeyword"));
            visibility = keywordToString(attribs.nodes[i]);
        } else if (tkn_text(attribs.nodes[i]) == ":returns") {
            i++;
            expectType(attribs.nodes[i], keyword(":litType"));
            returnType = typeToString(attribs.nodes[i]);
        } else if (tkn_text(attribs.nodes[i]) == ":aliases") {
            i++;
            //if (wrapped.size > 1) {
            //    stderr.writeln(
            //            ":aliases only allowed for one function per meta-block. " ~ attribs.nodes[i].tknstr());
            //} else {
            expectType(attribs.nodes[i], keyword(":litList"), keyword(":closedList"));
            foreach (aliasNode; attribs.nodes[i].nodes) {
                expectType(aliasNode, keyword(":symbol"));
                aliases ~= tkn_text(aliasNode);
            }
            //}
        } else if (tkn_text(attribs.nodes[i]) == ":export-as") {
            i++;
            //if (wrapped.size > 1) {
            //    stderr.writeln(
            //            ":export-as only allowed for one function per meta-block. " ~ attribs.nodes[i].tknstr());
            //} else {
            expectType(attribs.nodes[i], keyword(":litString"));
            exportName = tkn_text(attribs.nodes[i])[1 .. $ - 1];
            //}
        } else if (tkn_text(attribs.nodes[i]) == ":tk-aliases") {
            i++;
            if (attribs.nodes[i].type != keyword(":closedList")) {
                throw new CompilerError(
                        "meta: Expected list for attribute tk-aliases. " ~ attribs.nodes[i].tknstr);
            } else if (ast_size(attribs.nodes[i]) % 2 != 0) {
                throw new CompilerError(
                        "meta: tk-aliases requires even number of arguments. "
                        ~ attribs.nodes[i].tknstr);
            }

            AstNode aliasedStuff = attribs.nodes[i];
            AstNode replacement, orig;
            for (auto i2 = 0; i2 < ast_size(aliasedStuff); i2 += 2) {
                orig = aliasedStuff.nodes[i2];
                replacement = aliasedStuff.nodes[i2 + 1];
                if (!isAtom(orig.tkn) || !isAtom(replacement.tkn)) {
                    throw new CompilerError(
                            "meta: All tokens in tk-aliases must be atomic. "
                            ~ aliasedStuff.nodes[i2].tknstr);
                }
                if (ast.nodes.size > 2) {
                    foreach (child; ast.nodes[2 .. $]) {
                        replaceTkAliases(child, tkn_text(replacement), tkn_text(orig));
                    }
                }
            }
        } else if (tkn_text(attribs.nodes[i]) == ":variadic") {
            i++;
            if (attribs.nodes[i].type != keyword(":litBool")) {
                warning(
                        "meta: The :variadic option required a boolean (#t/#f) " ~ attribs.nodes[i].tknstr());
            } else {
                variadic = tkn_text(attribs.nodes[i]) == "#t";
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
        if (tkn_text(c.nodes[0]) == "meta") {
            result ~= parseMetaGetString(ast(c), meta);
        } else if (tkn_text(c.nodes[0]) != "define" && tkn_text(c.nodes[0]) != "define-fn") {
            string msg = "meta can only be used on function definitions. Otherwise, it is ignored. ";
            warning(msg ~ ast.nodes[0].tknstr());
            result ~= createOutput(ast(c));
        } else {
            auto forceIsFn = tkn_text(c) == "define-fn";
            result ~= generalDefineToString(ast(c), forceIsFn, meta);
        }
    }

    return result.get();
}
