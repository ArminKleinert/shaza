module compiler.ast_converter;

import compiler.output.ll;
import compiler.output.define;
import compiler.output.lambda;
import compiler.output.imports;
import compiler.output.deftype;
import compiler.output.statements;
import compiler.output.expressions;
import compiler.output.meta;

import compiler.types;
import compiler.ast;
import shaza.stdlib;

import compiler.output.create_module;
import compiler.output.helpers;

string[string] getAllTexts() {
    return OutputContext.global.fullModuleTexts;
}

// SECTION Main switch-table for string-creation of ast.

string createOutput(Context ctx) {
    OutputContext.global.sourcedir = ctx.sourcedir;
    return createOutput(AstCtx(ctx.ast, ctx.ast));
}

string createOutput(AstNode ast) {
    return createOutput(AstCtx(ast, ast));
}

string createOutput(AstCtx ast) {
    if (!initialized) {
        initialize(&createOutput, &parseRootNodeIntoContextAndReturnModulename);
    }

    if (isAtom(ast.tkn)) {
        return prependReturn(ast.requestReturn, atomToString(ast));
    }

    if (or(eql_Q(ast.type , keyword(":closedTaggedList")) , eql_Q(ast.type , keyword(":closedList")))) {
        return prependReturn(ast.requestReturn, listLiteralToString(ast));
    }

    if (eql_Q(ast.type, keyword(":closedScope"))) {
        Token firstTkn = ast.nodes[0].tkn;
        if (eql_Q(firstTkn.type, keyword(":symbol"))) {
            switch (firstTkn.text) {
            case "module":
                // Only 1 module declaration per file is allowed and it must be the very first token!
                errorln_E(append("Ignoring unexpected module declaration: " , ast.nodes[0].tknstr()));
                break;
            case "define":
                return generalDefineToString(ast, false, null);
            case "define-fn":
                return generalDefineToString(ast, true, null);
            case "define-macro":
                break; // TODO
            case "define-tk-macro":
                break; // TODO
            case "let":
                return letToString(ast);
            case "setv!":
                return setvToString(ast);
            case "ll":
                return llToString(ast);
            case "llr":
                return llToString(ast);
            case "when":
                return ifToString(ast);
            case "lambda":
                return lambdaToString(ast);
            case "return":
                return returnToString(ast);
            case "new":
                return newToString(ast);
            case "loop":
                return loopToString(ast);
            case "recur":
                return recurToString(ast);
            case "to":
                return conversionToString(ast);
            case "cast":
                return castToString(ast);
            case "comment":
                return "";
            case "def-struct":
                return defStructToString(ast);
            case "def-type":
                return defTypeToString(ast);
            case "struct":
                break; // TODO
            case "import-sz":
                return importShazaToString(ast);
            case "import-host":
                return importHostToString(ast);
            case "rt-import-sz":
                break; // TODO
            case "rt-import-dll":
                break; // TODO
            case "quote":
                break; // TODO
            case "pseudo-quote":
                break; // TODO
            case "unquote":
                break; // TODO
            case "meta":
                return parseMetaGetString(ast);
            case "fp":
                return functionPointerToString(ast);
            case "alias":
                return aliasToString(ast);
            case "include":
                return includeToString(ast);
            default:
                break;
            }
        }
        return callToString(ast);
    }

    if (eql_Q(ast.type , keyword(":root"))) {
        auto modulename = parseRootNodeIntoContextAndReturnModulename(ast);
        return OutputContext.global.fullModuleTexts[modulename];
    }

    return "";
}

string parseRootNodeIntoContextAndReturnModulename(AstNode ast) {
    return parseRootNodeIntoContextAndReturnModulename(AstCtx(ast, ast));
}

string parseRootNodeIntoContextAndReturnModulename(AstCtx ast) {
    string[] rootTexts = [];
    auto modulename = "";
    auto parsingstart = 0;

    // Cornercase: Empty source file
    if (eql_Q(ast.nodes.size, 0))
        return "";

    // Try to find module declaration
    if (eql_Q(ast.nodes[0].type , keyword(":closedScope"))
            && gt_Q(ast.nodes[0].nodes.size , 0) && eql_Q(ast.nodes[0].nodes[0].tkn_text , "module")) {
        string temp = moduleToString(ast.nodes[0]);

        modulename = retrieveModuleName(ast.nodes[0]);
        if (!temp) {
            return modulename; // The module was already imported!
        }

        append_E(rootTexts, temp);
        parsingstart++;
    } else {
        warning("File is missing a module declaration. This is fine for scripts, "
                ~ "but can lead to problems when importing the same file multiple times.");
    }

    foreach (AstNode child; slice(ast.nodes,parsingstart)) {
       append_E(rootTexts, createOutput(ast(child)));
    }
    rootTexts ~= OutputContext.global().globals;
    auto result = "";
    foreach (txt; rootTexts) {
        append_E(result, append(txt, "\n"));
    }
    OutputContext.global.appendToModuleText(modulename, result);
    return modulename;
}
