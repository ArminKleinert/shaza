module compiler.output.define;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.std;

import std.array;

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
            throw new CompilerError( "Expected more bindings after " ~ bindings[$ - 1].tknstr());
        }
        if (bindings[i].type == TknType.symbol) {
            names ~= szNameToHostName( symbolToString( bindings[i]));
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
            throw new CompilerError( "Expected more bindings after " ~ bindings[$ - 1].tknstr());
        }
        if (bindings[i].type == TknType.symbol) {
            names ~= szNameToHostName( symbolToString( bindings[i]));
        }
    }

    return names;
}

string generalFunctionBindingsToString(AstNode[] bindings) {
    auto result = appender( "(");

    // Write function argument list
    for (int i = 0; i < bindings.size; i++) {
        if (bindings[i].type == TknType.litType) {
            result ~= typeToString( bindings[i]);
            i++;
        } else {
            result ~= SHAZA_PARENT_TYPE;
        }
        result ~= " ";
        result ~= szNameToHostName( symbolToString( bindings[i])); // Name

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
    string type = typestring( typeNode);
    return addFunctionFromAst( meta, name, type, bindings, generics);
}

FunctionDecl addFunctionFromAst(FnMeta meta, string name, string type,
AstNode[] bindings, string[] generics) {
    string[] args;

    // FIXME Update because sometimes the types are now optional
    for (int i = 0; i < bindings.size; i += 2) { // +2 skips name
        args ~= typeToString( bindings[i]);
    }

    return OutputContext.global.addFunc( meta, name, type, args, generics);
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
        type = typeToString( ast[nameIndex]);
        nameIndex++; // Type found, name comes later.
    }

    // SUBSECT Generics

    string[] generics = null; // None if not given
    if (ast[nameIndex].type == TknType.closedScope) {
        generics = [];
        isFunctionDef = true;

        auto genericsNodes = ast[nameIndex].nodes;
        foreach (node; genericsNodes) {
            if (node.type != TknType.litType) {
                throw new CompilerError( "Expected type: " ~ node.tknstr());
            }
            generics ~= typeToString( node.text);
        }

        nameIndex++;
    }

    // SUBSECT Name

    AstNode nameNode = ast[nameIndex];
    if (nameNode.type != TknType.symbol) {
        string msg = "Token " ~ nameNode.tknstr();
        msg ~= " not allowed as a variable/function name. Token must be a symbol!";
        throw new CompilerError( msg);
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
            string msg = "Cannot induce return type for function definitions yet: ";
            msg ~= nameNode.tkn.as_readable;
            msg ~= ". Assuming type 'void'.";
            warning( msg);
            type = "void";
        }
    }

    // SUBSECT Create output text for variables and return

    if (!isFunctionDef) {
        if (meta !is null) {
            // TODO Enable meta for variables
            warning( "Metadata ignored because here a variable is defined. " ~ ast[0].tknstr());
        }

        string val;
        if (ast.nodes.size == nameIndex + 1) {
            assert(type != "auto");
            val = type ~ ".init";
        } else {
            val = createOutput( ast[nameIndex + 1]);
        }

        auto result = appender( "");
        result ~= type;
        result ~= " ";
        result ~= symbolToString( nameNode);
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
        throw new CompilerError( msg);
    }

    auto bindings = ast[nameIndex + 1].nodes;
    auto bodyNodes = ast.subs[nameIndex + 2 .. $];
    auto argNames = getVarNamesFromBindings( bindings);

    // Add function to globals
    if (meta is null)
        meta = new FnMeta( szNameToHostName( name), generics, type);
    auto fndeclaration = addFunctionFromAst( meta, name, type, bindings, generics);

    // SUBSECT Write name and (if given) generic types.

    auto result = appender( "");
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

    result ~= generalFunctionBindingsToString( bindings);
    result ~= defineFnToString( type, argNames, bodyNodes, ast);
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
    auto result = appender( "{\n");

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
    bool doAddLabel =false;
    foreach (n; bodyNodes) {
        if (nodeContainsRecur(n)) {
            doAddLabel = true;break ;
        }
    }
    if (doAddLabel) {
        result ~= OutputContext.global.newLabel( argNames);
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
