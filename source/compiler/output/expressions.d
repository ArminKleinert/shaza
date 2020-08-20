module compiler.output.expressions;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.std;

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
    if (ast.size == 0) {
        throw new CompilerError("Unexpected empty scope. " ~ ast.tknstr());
    }

    string callingName;
    if (ast.nodes[0].type == TknType.symbol) {
        if (FunctionDecl fn = OutputContext.global.findFn(ast.nodes[0].text))
            callingName = fn.exportName;
        else
            callingName = symbolToString(ast.nodes[0]);
    } else {
        // Ok, if we are not using a name to call a function,
        // it might be a lambda definition.. Just trust the user
        // what could go wrong :D
        callingName = createOutput(ast[0]);
    }

    return callingName ~ callArgsToString(ast, ast.nodes[1 .. $]);
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
    expectType(attr, TknType.symbol, TknType.litKeyword, TknType.litString);

    string s;
    if (attr.type == TknType.litKeyword)
        s = keywordToString(attr);
    else if (attr.type == TknType.litString)
        s = attr.text[1 .. $ - 1];
    else
        s = symbolToString(attr);

    return name ~ "." ~ s ~ " = " ~ createOutput(newVal);
}

string setvToString(AstCtx ast) {
    if (ast.nodes.size < 3) {
        throw new CompilerError("setv: Too few arguments. " ~ ast.tknstr());
    }

    auto result = appender("");
    expectType(ast.nodes[1], TknType.symbol);
    auto varname = createOutput(ast[1]); // Var name

    if (ast.nodes.size == 3) {
        result ~= simpleSetvToString(varname, ast[2]);
    } else if (ast.nodes.size == 4) {
        result ~= attrSetvToString(varname, ast[2], ast[3]);
    }
    insertSemicolon(result, ast);
    return result.get();
}

// SECTION new-operator

string newToString(AstCtx ast) {
    if (ast.nodes.size < 2) {
        throw new CompilerError("new requires at least one parameter. " ~ ast.tknstr);
    }

    if (ast.nodes[1].type != TknType.litType) {
        throw new CompilerError("new: First parameter must be type literal. " ~ ast.nodes[1].tknstr);
    }

    return "new " ~ createOutput(ast[1]) ~ callArgsToString(ast, ast.nodes[2 .. $]) ~ ";";
}

// SECTION Operator call (+, -, *, /, &, %, |) for > 2 arguments

string opcallToString(AstCtx ast) {
    string op = szNameToHostName(ast.nodes[1].text);
    auto result = appender("(");
    for (size_t i = 2; i < ast.nodes.size - 1; i++) {
        result ~= createOutput(ast[i]);
        result ~= " ";
        result ~= op;
        result ~= " ";
    }
    result ~= createOutput(ast.subs[ast.size - 1]);
    result ~= ")";
    return result.get();
}

// SECTION conversions -> cast and to

string conversionToString(AstCtx ast) {
    if (ast.size < 3) {
        throw new CompilerError("to: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    auto s = "to!" ~ typeToString(ast.nodes[1]);
    return toOrCastToString(ast, s);
}

string castToString(AstCtx ast) {
    if (ast.size < 3) {
        throw new CompilerError("cast: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    auto s = "cast(" ~ typeToString(ast.nodes[1]) ~ ")";
    return toOrCastToString(ast, s);
}

string toOrCastToString(AstCtx ast, string start) {
    if (ast.size < 3) {
        throw new CompilerError("cast: Not enough arguments. " ~ ast.nodes[0].tknstr());
    }
    expectType(ast.nodes[1], TknType.litType);

    auto result = appender(start);
    result ~= "(";
    result ~= createOutput(ast[2]);

    if (ast.size > 3) {
        foreach (arg; ast.subs[3 .. $]) {
            result ~= ", ";
            result ~= createOutput(arg);
        }
    }

    result ~= ")";
    return result.get();
}
