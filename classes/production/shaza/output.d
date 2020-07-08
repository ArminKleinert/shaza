module output;

import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;

import compiler_types;
import buildins;

/*
enum TknType : byte {
    unknown,
    litInt,
    litUInt,
    litFlt,
    litBool,
    litString,
    litList,
    litMap,
    litKeyword,
    litType,
    symbol,
    buildinFnCall,
    buildinMacroCall,
    scopeOpen,
    scopeClose,
    lstOpen,
    lstTaggedOpen,
    lstClose,
    closedScope,
    closedTaggedList,
    closedList,
    lnComment,
}
*/

string keywordToOutputString(string kwText) {
    return kwText;
}

void writeSimpleLiteral(File f, AstNode ast) {
    Token tkn = ast.tkn;
    string text;
    switch (tkn.type) {
        case TknType.litInt:
        text = to!string( toIntOrNull( tkn.text));
        break ;
        case TknType.litUInt:
        text = to!string( toUIntOrNull( tkn.text));
        break ;
        case TknType.litFlt:
        text = to!string( toFloatOrNull( tkn.text));
        break ;
        case TknType.litBool:
        if (tkn.text == "#t") text = "true"; else text = "false";
        break ;
        case TknType.litString:
        text = tkn.text;
        break ;
        case TknType.litKeyword:
        text = keywordToOutputString( tkn.text);
        break ;
        case TknType.litType:
        // FIXME
        break ;
        default:
        throw new CompilerError( "Token type not allowed as a simple literal.");
    }
    f.write( text);
}

// TODO
void writeFunctionCall(File f, AstNode ast) {
}

// TODO
void writeDefineCall(File f, AstNode ast) {
}

// TODO
void writeEtDefineCall(File f, AstNode ast) {
}

// TODO
void writeDefineMacro(File f, AstNode ast) {
}

// TODO
void writeDefineTkMacro(File f, AstNode ast) {
}

bool isTypedMathOp(string text) {
    return text == "+'" || text == "-'" || text == "*'"
    || text == "/'" || text == "%'" || text == "<<'"
    || text == ">>'" || text == "bit-and'" || text == "bit-or'"
    || text == "bit-xor'" ;
}

bool isMathOp(string text) {
    return text == "+" || text == "-" || text == "*"
    || text == "/" || text == "%" || text == "<<"
    || text == ">>" || text == "bit-and" || text == "bit-or"
    || text == "bit-xor" ;
}

bool isBoolOp(string text) {
    return text == "and" || text == "or" || text == "xor"
    || text == "lsp-and" || text == "lsp-or" || text == "lsp-xor";
}

void writeScope(File f, AstNode ast) {
    Token firstTkn = ast.children[0].tkn;
    if (firstTkn.type == TknType.symbol) {
        if (firstTkn.text == "define") {
            writeDefineCall( f, ast);
        }else if (firstTkn.text == "et-define") {
            writeEtDefineCall( f, ast);
        } else if (firstTkn.text == "define-macro") {
            writeDefineMacro( f, ast);
        } else if (firstTkn.text == "define-tk-macro") {
            writeDefineTkMacro( f, ast);
        } else if (firstTkn.text == "lambda") {
            // TODO
        } else if (firstTkn.text == "t-lambda") {
            // TODO
        } else if (firstTkn.text == "def-struct") {
            // TODO
        } else if (firstTkn.text == "struct") {
            // TODO
        } else if (firstTkn.text == "cast") {
            // TODO
        } else if (firstTkn.text == "convert") {
            // TODO
        } else if (firstTkn.text == "car") {
            // TODO
        } else if (firstTkn.text == "cdr") {
            // TODO
        } else if (firstTkn.text == "coll") {
            // TODO
        } else if (firstTkn.text == "import-sz") {
            // TODO
        } else if (firstTkn.text == "rt-import-sz") {
            // TODO
        } else if (firstTkn.text == "rt-import-dll") {
            // TODO
        } else if (firstTkn.text == "call-extern") {
            // TODO
        } else if (firstTkn.text == "call-sys") {
            // TODO
        } else if (firstTkn.text == "recur") {
            // TODO
        } else if (firstTkn.text == "mut") {
            // TODO
        } else if (firstTkn.text == "alloc") {
            // TODO
        } else if (firstTkn.text == "set!") {
            // TODO
        } else if (firstTkn.text == "get!") {
            // TODO
        } else if (firstTkn.text == "free") {
            // TODO
        } else if (firstTkn.text == "pointerto") {
            // TODO
        } else if (firstTkn.text == "quote") {
            // TODO
        } else if (firstTkn.text == "pseudo-quote") {
            // TODO
        } else if (firstTkn.text == "unquote") {
            // TODO
        } else if (isTypedMathOp(firstTkn.text)) {
            // TODO
        } else if (isMathOp(firstTkn.text)) {
            // TODO
        } else if (isBoolOp(firstTkn.text)) {
            // TODO
        }
        else {
            writeFunctionCall( f, ast);
        }
    }
}

void do_output(File f, AstNode ast) {

}
