module compiler.output.statements;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.std;

import std.array;

// SECTION let-instruction

string letBindingsToString(AstCtx ast, AstNode[] bindings) {
    auto result = appender!string("");
    for (int i = 0; i < bindings.size; i += 2) {
        if (bindings[i].type == TknType.litType) {
            result ~= typeToString(bindings[i]);
            result ~= ' ';
            i++;
        } else {
            result ~= "auto ";
        }
        result ~= szNameToHostName(symbolToString(bindings[i + 0])); // Name
        result ~= " = ";
        result ~= createOutput(ast(bindings[i + 1])); // Value
        result ~= ";\n";
    }
    return result.get();
}

string letToString(AstCtx ast) {
    if (ast.nodes.size < 2)
        throw new CompilerError("let: Too few arguments. " ~ ast.nodes[0].tknstr());
    if (ast.nodes[1].type != TknType.closedList && ast.nodes[1].type != TknType.closedScope)
        throw new CompilerError("let: Bindings must be a list literal. " ~ ast.nodes[1].tknstr());

    AstNode[] bindings = ast.nodes[1].nodes;
    AstNode[] bodyNodes = ast.nodes[2 .. $];

    // "{" without a keyword before it in D source code opens a new scope
    auto result = appender!string("{\n");

    // Write bindings
    result ~= letBindingsToString(ast, bindings);

    // Write code
    foreach (AstNode bodyNode; bodyNodes) {
        result ~= createOutput(ast(bodyNode));
        insertSemicolon(result, bodyNode);
        result ~= "\n";
    }

    result ~= "}";
    return result[];
}

// SECTION if-else

string ifToString(AstCtx ast) {
    auto condition = ast[1];
    auto branchThen = ast[2];
    auto result = appender("");
    result ~= "if(";
    result ~= createOutput(condition);
    result ~= ") {\n";
    result ~= createOutput(branchThen);
    insertSemicolon(result, branchThen);
    result ~= "\n}";

    if (ast.size == 4) {
        auto branchElse = ast[3];
        result ~= " else {\n";
        result ~= createOutput(branchElse);
        insertSemicolon(result, branchElse);
        result ~= "\n}";
    }
    return result.get();
}

// SECTION loop

string loopToString(AstCtx ast) {
    // SUBSECT Error checking

    if (ast.size < 3) {
        throw new CompilerError("Loop: not enough arguments. " ~ ast.nodes[0].tknstr);
    }
    if (ast.nodes[1].type != TknType.closedScope) {
        throw new CompilerError("Loop: First argument must be a scope. " ~ ast.nodes[1].tknstr());
    }

    // SUBSECT Retrieve bindings and body

    auto bindings = ast[1].subs;
    auto bodyNodes = ast.subs[2 .. $];
    auto directBodyNodes = ast.nodes[2 .. $];
    string[] argNames = getVarNamesFromLoopBindings(bindings);

    // SUBSECT Write bindings to result

    auto result = appender("");

    for (auto i = 0; i < bindings.size; i += 2) {
        // Type
        if (bindings[i].type == TknType.litType) {
            result ~= typeToString(bindings[i]);
            i++;
        } else {
            result ~= "auto"; // If no type is given, insert "auto"
        }
        result ~= ' ';

        // Write variable name
        if (bindings[i].type != TknType.symbol) {
            throw new CompilerError("Loop: Variable name must be symbol: " ~ bindings[i].tknstr());
        }
        result ~= symbolToString(bindings[i]);
        result ~= " = ";

        // Write value of variable
        if (bindings.size <= i + 1) {
            throw new CompilerError("Loop: Value for variable expected: " ~ bindings[i].tknstr());
        }
        result ~= createOutput(bindings[i + 1]);
        insertSemicolon(result, bindings[i + 1]);
        result ~= '\n';
    }

    // SUBSECT Add jump-label
    bool doAddLabel = nodesContainRecur(directBodyNodes);
    if (doAddLabel)
        result ~= OutputContext.global.newLabel(argNames);

    // SUBSECT Generate body
    foreach (node; bodyNodes[0 .. $ - 1]) {
        result ~= createOutput(node);
        insertSemicolon(result, node);
        result ~= '\n';
    }
    result ~= createOutput(bodyNodes[$ - 1]);
    insertSemicolon(result, bodyNodes[$ - 1]);

    // SUBSECT Remove label and return
    if (doAddLabel)
        OutputContext.global.removeLastLabel();
    return result.get();
}

// SECTION recur

string recurToString(AstCtx ast) {
    // TODO verification

    auto bindings = ast.subs[1 .. $];
    auto lastLabel = OutputContext.global.getLastJumpLabel();

    if (lastLabel is null) {
        throw new CompilerError("recur: No bounding loop or function.");
    }

    if (bindings.size != lastLabel.vars.size) {
        throw new CompilerError("recur: Too many or too few bindings. " ~ ast.nodes[0].tknstr());
    }

    auto result = appender("");

    for (auto i = 0; i < lastLabel.vars.size; i++) {
        result ~= lastLabel.vars[i];
        result ~= " = ";
        result ~= createOutput(bindings[i]);
        insertSemicolon(result, bindings[i]);
        result ~= '\n';
    }

    result ~= "goto ";
    result ~= lastLabel.text;
    result ~= ';';
    return result.get();
}

// SECTION Return

string returnToString(AstCtx ast) {
    return "return " ~ createOutput(ast[1]) ~ ";";
}
