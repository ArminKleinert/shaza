module compiler.output.expressions;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.stdlib;

import std.array;

// SECTION List literal to string

// TODO Check
string listLiteralToString(AstCtx ast) {
    if (ast.nodes.size == 0)
        return "[]"; // Empty list

    auto result = appender!string("[");
    for (int i = 0; i < ast.nodes.size; i++) {
        result ~= createOutput(ast[i]);
        if (i < ast.nodes.size - 1)
            result ~= ",";
    }
    result ~= "]";
    return result.get();
}

// SECTION Fucntion call to string

string callToString(AstCtx ast) {
    if (ast_size(ast) == 0) {
        throw new CompilerError("Unexpected empty scope. " ~ ast.tknstr());
    }

    string callingName;
    if (ast.nodes[0].type == keyword(":symbol")) {
        if (FunctionDecl fn = OutputContext.global.findFn(ast.nodes[0].tkn_text))
            callingName = fn.exportName;
        else
            callingName = symbolToString(ast.nodes[0]);
    } else {
        // Ok, if we are not using a name to call a function,
        // it might be a lambda definition.. Just trust the user
        // what could go wrong :D
        callingName = createOutput(ast[0]);
    }

    auto result = callingName ~ callArgsToString(ast, ast.nodes[1 .. $]);
    result = prependReturn(ast.requestReturn, result);
    return result;
}

string callArgsToString(AstCtx actx, AstNode[] args) {
    auto result = appender!string("(");
    for (int i = 0; i < args.size; i++) {
        result ~= createOutput(actx(args[i]));
        if (i < args.size - 1)
            result ~= ", ";
    }
    result ~= ')';
    return result.get();
}

// SECTION setv! (assignment) to string

string simpleSetvToString(string name, AstCtx newVal) {
    return name ~ " = " ~ createOutput(newVal);
}

string attrSetvToString(string name, AstCtx attr, AstCtx newVal) {
    expectType(attr, keyword(":symbol"), keyword(":litKeyword"), keyword(":litString"));

    string s;
    if (attr.type == keyword(":litKeyword"))
        s = keywordToString(attr);
    else if (attr.type == keyword(":litString"))
        s = attr.tkn_text[1 .. $ - 1];
    else
        s = symbolToString(attr);

    return name ~ "." ~ s ~ " = " ~ createOutput(newVal);
}

string setvToString(AstCtx ast) {
    if (ast.nodes.size < 3) {
        throw new CompilerError("setv: Too few arguments. " ~ ast.tknstr());
    }

    auto result = appender("");
    expectType(ast.nodes[1], keyword(":symbol"));
    auto varname = createOutput(ast[1]); // Var name

    if (ast.nodes.size == 3) {
        result ~= simpleSetvToString(varname, ast[2]);
    } else if (ast.nodes.size == 4) {
        result ~= attrSetvToString(varname, ast[2], ast[3]);
    }
    insertSemicolon(result, ast);
    return prependReturn(ast.requestReturn, result.get());
}

// SECTION new-operator

string newToString(AstCtx ast) {
    if (ast.nodes.size < 2) {
        throw new CompilerError("new requires at least one parameter. " ~ ast.tknstr);
    }

    if (ast.nodes[1].type != keyword(":litType")) {
        throw new CompilerError("new: First parameter must be type literal. " ~ ast.nodes[1].tknstr);
    }

    auto result = "new " ~ typeToString(ast[1]) ~ callArgsToString(ast, ast.nodes[2 .. $]);
    result = prependReturn(ast.requestReturn, result);
    return result;
}

// SECTION conversions -> cast and to

string conversionToString(AstCtx ast) {
    if (ast_size(ast) < 3) {
        throw new CompilerError("to: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    auto s = "to!" ~ typeToString(ast.nodes[1]);
    return prependReturn(ast.requestReturn, toOrCastToString(ast, s));
}

string castToString(AstCtx ast) {
    if (ast_size(ast) < 3) {
        throw new CompilerError("cast: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    auto s = "cast(" ~ typeToString(ast.nodes[1]) ~ ")";
    return prependReturn(ast.requestReturn, toOrCastToString(ast, s));
}

string toOrCastToString(AstCtx ast, string start) {
    if (ast_size(ast) < 3) {
        throw new CompilerError("cast: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    expectType(ast.nodes[1], keyword(":litType"));

    auto result = appender(start);
    result ~= "(";
    result ~= createOutput(ast[2]);

    if (ast_size(ast) > 3) {
        foreach (arg; ast.subs[3 .. $]) {
            result ~= ", ";
            result ~= createOutput(arg);
        }
    }

    result ~= ")";
    return result.get();
}

// SECTION Function pointer to string

string functionPointerToString(AstCtx ast) {
    if (ast_size(ast) != 2) {
        throw new CompilerError("fp: Excepts exactly 1 argument. " ~ ast.nodes[0].tknstr());
    }
    if (ast[1].type != keyword(":symbol")) {
        throw new CompilerError("fp: Function name expected. " ~ ast[1].tknstr());
    }

    FunctionDecl fn = OutputContext.global.findFn(ast[1].tkn_text);
    string fnOutName = "";

    if (fn is null) {
        //        throw new CompilerError("fp: Unknown function. " ~ ast[1].tknstr());
        fnOutName = szNameToHostName(ast[1].tkn_text);
    } else {
        fnOutName = fn.exportName;
    }

    return "(std.functional.toDelegate(&" ~ fnOutName ~ "))";
}
