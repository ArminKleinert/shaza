module compiler.output.define;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.stdlib;

import std.array;
import std.stdio;

// SECTION Replace anonymous parameter names

void replaceAnonymousNames(AstNode root, string[] anonymousParamNames) {
    import std.algorithm.searching : canFind;

    static const string ss = "0123456789";

    auto getParamIndex(string s) {
        if (s.size == 2 && s[0] == '$' && ss.canFind(s[1])) {
            return s[1] - '0';
        }
        return -1;
    }

    size_t i;

    if ((i = getParamIndex(root.text)) != -1) {
        import compiler.tokenizer;

        root.tkn.text = anonymousParamNames[i];
        root.tkn.type = tknTypeByText(anonymousParamNames[i]);
    }
    foreach (child; root.nodes) {
        replaceAnonymousNames(child, anonymousParamNames);
    }
}

// SECTION Generate text for function bindings.

static const string SHAZA_PARENT_TYPE = "Object";

string[] getVarNamesFromLoopBindings(AstCtx[] bindings) {
    string[] names;

    for (int i = 0; i < bindings.size; i++) {
        //if (bindings[i].type == TknType.symbol) {
        //    names ~= szNameToHostName(symbolToString(bindings[i]));
        //}
        if (bindings[i].type == TknType.litType) {
            i++;
        }
        if (i >= bindings.size) {
            throw new CompilerError("Expected more bindings after " ~ bindings[$ - 1].tknstr());
        }
        if (bindings[i].type == TknType.symbol) {
            names ~= szNameToHostName(symbolToString(bindings[i]));
            i++; // Skip value
        }
    }

    return names;
}

string[] getVarNamesFromBindings(AstNode[] bindings) {
    string[] names;

    for (int i = 0; i < bindings.size; i++) {
        if (bindings[i].type == TknType.litType) {
            i++;
        }
        if (i >= bindings.size) {
            throw new CompilerError("Expected more bindings after " ~ bindings[$ - 1].tknstr());
        }
        if (bindings[i].type == TknType.symbol) {
            names ~= szNameToHostName(symbolToString(bindings[i]));
        }
    }

    return names;
}

string generalFunctionBindingsToString(AstNode[] bindings, FnMeta meta) {
    auto result = appender("(");

    // Write function argument list
    for (int i = 0; i < bindings.size; i++) {
        if (bindings[i].type != TknType.litType) {
            throw new CompilerError("Function bindings: Type expected. " ~ bindings[i].tknstr);
        }
        result ~= typeToString(bindings[i]);

        // Variadic type
        if (i == bindings.size - 2 && meta && meta.variadic) {
            result ~= "[]";
        }

        i++;

        result ~= " ";
        result ~= szNameToHostName(symbolToString(bindings[i])); // Name

        // Variadic argument
        if (i == bindings.size - 1 && meta && meta.variadic) {
            result ~= "...";
        }

        if (i < bindings.size - 2) {
            result ~= ", ";
        }
    }

    result ~= ")";
    return result.get();
}

// SECTION Add function to globally visible functions (May be used for type induction)

FunctionDecl addFunctionFromAst(FnMeta meta, string name, AstNode typeNode,
        AstNode[] bindings, string[] generics) {
    string type = typestring(typeNode);
    return addFunctionFromAst(meta, name, type, bindings, generics);
}

FunctionDecl addFunctionFromAst(FnMeta meta, string name, string type,
        AstNode[] bindings, string[] generics) {
    string[] args;

    // FIXME Update because sometimes the types are now optional
    for (int i = 0; i < bindings.size; i += 2) { // +2 skips name
        args ~= typeToString(bindings[i]);
    }

    return OutputContext.global.addFunc(meta, name, type, args, generics);
}

// SECTION define-instruction

string generalDefineToString(AstCtx ast, bool forceFunctionDef, FnMeta meta) {
    int nameIndex = 1; // Assume that the name symbol is at index 1
    bool isFunctionDef = forceFunctionDef;

    // SUBSECT Try to get type.
    // If none is given, try again later.

    string type = ""; // Infer if not given.
    if (meta !is null) {
        type = meta.returnType;
    }
    if (ast[nameIndex].type == TknType.litType) {
        type = typeToString(ast[nameIndex]);
        nameIndex++; // Type found, name comes later.
    }

    // SUBSECT Generics

    string[] generics = []; // None if not given
    if (ast[nameIndex].type == TknType.closedScope) {
        generics = [];
        isFunctionDef = true;

        auto genericsNodes = ast[nameIndex].nodes;
        foreach (node; genericsNodes) {
            if (node.type != TknType.litType) {
                throw new CompilerError("Expected type: " ~ node.tknstr());
            }
            generics ~= typeToString(node.text);
        }

        nameIndex++;
    }

    // SUBSECT Name

    AstNode nameNode = ast[nameIndex];
    if (nameNode.type != TknType.symbol) {
        string msg = "Token " ~ nameNode.tknstr();
        msg ~= " not allowed as a variable/function name. Token must be a symbol!";
        throw new CompilerError(msg);
    }
    string name = nameNode.text;

    // SUBSECT Check if this is a function declaration

    if (!isFunctionDef && ((nameIndex + 1) < (ast.nodes.size - 1))) {
        isFunctionDef = true;
    }

    // SUBSECT Induce type of variable / return-type of function

    if (type.size == 0) {
        if (!isFunctionDef) {
            type = "auto"; // For variables, use "auto" :)
        } else if (type == "") {
            //string msg = "define: Type induction for function is not safe yet. " ~ nameNode.tknstr();
            //warning(msg);
            type = "auto";
        }
    }

    // SUBSECT Create output text for variables and return

    if (!isFunctionDef) {
        if (meta !is null) {
            // TODO Enable meta for variables
            warning("Metadata ignored because here a variable is defined. " ~ ast[0].tknstr());
        }

        string val;
        if (ast.nodes.size == nameIndex + 1) {
            assert(type != "auto");
            val = type ~ ".init";
        } else {
            val = createOutput(ast[nameIndex + 1]);
        }

        auto result = appender("");
        result ~= type;
        result ~= " ";
        result ~= symbolToString(nameNode);
        result ~= " = ";
        result ~= val; // Value
        result ~= ";\n";
        return result.get();
    }

    // SUBSECT Bindings and body

    // Arguments must be in (...)
    if (ast[nameIndex + 1].type != TknType.closedScope) {
        string msg = "Token " ~ ast[nameIndex + 1].tkn.as_readable;
        msg ~= " not allowed as function argument list. Please surround arguments with '(...)'.";
        throw new CompilerError(msg);
    }

    auto bindings = ast[nameIndex + 1].nodes;
    auto bodyNodes = ast.subs[nameIndex + 2 .. $];
    string[] argNames = []; //getVarNamesFromBindings(bindings);

    // SUBSECT Transform bindings for anonymous names and types

    import std.algorithm.searching : canFind;

    bool usedAnonymousType;
    bool usedAnonymousName;
    AstNode[] bindings2 = [];

    for (auto i = 0; i < bindings.size; i++) {
        // SUBSECT Handle parameter types

        if (bindings[i].text == "::") { // Anonymous type
            auto sym = gensym();
            bindings2 ~= new AstNode(Token(TknType.litType, "::" ~ sym));
            generics ~= sym;
            i++;
        } else if (bindings[i].type == TknType.litType) { // Normal case
            bindings2 ~= bindings[i];
            i++;
        } else if (bindings[i].text == "_") { // Parameter type and name are anonymous; name can still be accessed as $n
            // Write anonymous type
            auto sym = gensym();
            bindings2 ~= new AstNode(Token(TknType.litType, "::" ~ sym));
            generics ~= sym;

            // Write anonymous name
            sym = gensym();
            argNames ~= sym;
            bindings2 ~= new AstNode(Token(TknType.symbol, sym));
            usedAnonymousName = true;

            // Go on
            continue;
        } else if (bindings[i].type == TknType.symbol) {
            // No type given
            auto sym = gensym();
            bindings2 ~= new AstNode(Token(TknType.litType, "::" ~ sym));
            generics ~= sym;

            // Add generic, anonymous type
            // Let the next part handle the parameter name :)
        } else {
            throw new CompilerError("define: Expecting type or symbol. " ~ bindings[i].tknstr());
        }

        if (i >= bindings.size) {
            throw new CompilerError("Expecting more tokens in bindings. " ~ ast[0].tknstr());
        }

        // SUBSECT Handle parameter name

        auto b = bindings[i].text;
        if (bindings[i].type == TknType.symbol) {
            if (b == "$") { // Anonymous
                auto sym = gensym();
                bindings2 ~= new AstNode(Token(TknType.symbol, sym));
                argNames ~= sym;
                usedAnonymousName = true;
            } else {
                bindings2 ~= bindings[i];
                argNames ~= bindings[i].text;
            }
        } else {
            throw new CompilerError("define: Expecting symbol. " ~ bindings[i].tknstr());
        }
    }

    // SUBSECT Deep-replace anonymous names

    if (usedAnonymousName) {
        foreach (node; ast.nodes[3 .. $]) {
            replaceAnonymousNames(node, argNames);
        }
    }

    // SUBSECT Add function to globals

    if (meta is null)
        meta = new FnMeta(szNameToHostName(name), generics, type);
    auto fndeclaration = addFunctionFromAst(meta, name, type, bindings2, generics);

    // SUBSECT Write name and (if given) generic types.

    auto result = appender("");
    if (fndeclaration.visibility != "") {
        result ~= fndeclaration.visibility;
        result ~= ' ';
    }

    result ~= fndeclaration.returnType;
    result ~= ' ';
    result ~= fndeclaration.exportName;

    // If the function has generic arguments.
    if (fndeclaration.generics.size > 0) {
        result ~= '(';
        for (int i = 0; i < fndeclaration.generics.size; i++) {
            result ~= fndeclaration.generics[i]; // Type
            if (i < fndeclaration.generics.size - 1)
                result ~= ", ";
        }
        result ~= ')';
    }

    // SUBSECT Write rest of arguments and body and return

    result ~= generalFunctionBindingsToString(bindings2, meta);
    result ~= defineFnToString(type, argNames, bodyNodes, ast);
    result ~= '\n';

    /*
    foreach (aliasName; fndeclaration.aliases) {
        if (isValidDIdentifier(szNameToHostName(aliasName))){
        result ~= "alias ";
        result ~= szNameToHostName(aliasName);
        result ~= "=";
        result ~= fndeclaration.exportName;
        result ~= ";\n";
    }}
    */

    return result.get();
}

// SUBSECT Helper for body of the define-instruction

string defineFnToString(string type, string[] argNames, AstCtx[] bodyNodes, AstCtx ast) {
    auto result = appender("{\n");

    // If the body is empty, return the default value of the return-type
    // or, if the type is void, leave an empty body
    if (bodyNodes.size == 0) {
        if (type == "void")
            return result.get();
        result ~= "return ";
        result ~= type;
        result ~= ".init;\n}\n";
        return result.get();
    }

    // Add jump-label
    bool doAddLabel = false;
    foreach (n; bodyNodes) {
        if (nodeContainsRecur(n)) {
            doAddLabel = true;
            break;
        }
    }
    if (doAddLabel) {
        result ~= OutputContext.global.newLabel(argNames);
    }

    // Write all but the last statement
    foreach (bodyNode; bodyNodes[0 .. $ - 1]) {
        result ~= createOutput(bodyNode);
        insertSemicolon(result, bodyNode);
        result ~= '\n';
    }

    auto lastStmt = bodyNodes[bodyNodes.size - 1];
    auto _needReturn = type != "void";
    result ~= createOutput(lastStmt.needReturn(_needReturn));
    insertSemicolon(result, lastStmt);

    // Pop jump label
    if (doAddLabel)
        OutputContext.global.removeLastLabel();

    result ~= "\n}";
    return result.get();
}
