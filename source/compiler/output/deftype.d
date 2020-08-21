module compiler.output.deftype;

import compiler.output.helpers;
import compiler.output.define;
import compiler.types;
import shaza.std;

import std.array;

// SECTION Code for def-struct

// This should really be made into a macro once possible...
string defStructToString(AstNode ast) {
    // SUBSECT Error checking stuff

    if (ast.size < 2) {
        auto msg = "def-struct: Not enough parameters. ";
        throw new CompilerError(msg ~ ast.tknstr);
    }

    // SUBSECT Get type name

    AstNode typeNode = ast.nodes[1]; // Type name

    if (typeNode.type != TknType.symbol) {
        auto msg = "def-struct: First argument must be a symbol. ";
        throw new CompilerError(msg ~ typeNode.tknstr);
    }

    // SUBSECT find generics (if given) and fields

    AstNode generics; // Optional
    AstNode[] attrList;

    // If the type is not empty
    if (ast.nodes.size > 2) {
        // If the type has generics
        if (ast.nodes[2].type == TknType.closedScope) {
            generics = ast.nodes[2];
            attrList = ast.nodes[3 .. $];
        } else {
            attrList = ast.nodes[2 .. $];
        }
    }

    if (attrList.size % 2 != 0) {
        auto msg = "def-struct: fields must be a sequence of types and symbols.";
        throw new CompilerError(msg ~ typeNode.tknstr);
    }

    // SUBSECT Retrieve field types and field names

    string[] fieldTypes = [];
    string[] fieldNames = [];
    for (auto i = 0; i < attrList.size; i += 2) {
        fieldTypes ~= typeToString(attrList[i]);
        fieldNames ~= symbolToString(attrList[i + 1]);
    }

    // SUBSECT Write header

    // Start class definition text
    string typename = symbolToString(typeNode);
    auto result = appender("class ");
    result ~= typename; // Write typename

    // SUBSECT Generate list of generics (if given).
    if (generics !is null) {
        result ~= "(";
        for (int i = 0; i < generics.size; i++) {
            result ~= typeToString(generics.nodes[i]);
            if (i < generics.size - 1)
                result ~= ", ";
        }
        result ~= ")";
    }

    result ~= " {\n";

    // SUBSECT Write list of attributes

    for (auto i = 0; i < fieldTypes.size; i++) {
        result ~= fieldTypes[i];
        result ~= ' ';
        result ~= fieldNames[i];
        result ~= ";\n";
    }

    // SUBSECT Write constructor

    // Name
    result ~= "this(";
    // Write constructor arguments; Arguments have a '_' in front of the name.
    for (auto i = 0; i < fieldTypes.size; i++) {
        result ~= fieldTypes[i];
        result ~= " _";
        result ~= fieldNames[i];
        if (i < fieldTypes.size - 1)
            result ~= ", ";
    }
    result ~= "){\n";
    // Write constructor body
    foreach (field; fieldNames) {
        result ~= field;
        result ~= " = _";
        result ~= field;
        result ~= ";\n";
    }
    result ~= "}\n";

    // SUBSECT Write setters

    for (auto i = 0; i < fieldNames.size; i++) {
        result ~= typename;
        result ~= " with_" ~ szNameToHostName(fieldNames[i]);
        result ~= '(' ~ fieldTypes[i] ~ ' ' ~ szNameToHostName(fieldNames[i]);
        result ~= "){\n";
        result ~= "return new " ~ typename;
        result ~= "(";

        for (auto j = 0; j < fieldNames.size; j++) {
            result ~= szNameToHostName(fieldNames[j]);
            if (j < fieldNames.size - 1)
                result ~= ", ";
        }

        result ~= ");\n}\n";
    }

    // Close class
    result ~= "}\n\n";

    return result.get();
}
