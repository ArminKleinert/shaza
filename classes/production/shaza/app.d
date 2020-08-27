import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;

import shaza.buildins;
import shaza.std;

import compiler.types;
import compiler.tokenizer;
import compiler.ast;
import compiler.ast_converter;

// SECTION Main

string[string] parseFully(string script) {
    auto ctx = new Context();
    ctx = tokenize( ctx, script);
    ctx = buildBasicAst( ctx);
    createOutput( ctx.ast);
    return getAllTexts();
}


int export_next(int i){
    return i+1;
}

int accept_func_pointer(int delegate(int) f, int i0){
    return f(i0);
}

int apply_func_pointer(){
    import std.functional;
    return accept_func_pointer((std.functional.toDelegate(&export_next)), 1);
}

int apply_func_pointer_2(){
    import std.functional;
    return accept_func_pointer((std.functional.toDelegate(&export_next)), 1);
}

void main() {
    import std.file;


    string txt = readText("./sz/examples.sz");
    foreach (k, v; parseFully(txt)) {
        auto file = File("source/" ~ k ~ ".d", "w");
        file.writeln(v);
        writeln(file);
    }


    import tests;
    tests.main1();

    writeln(apply_func_pointer());
    writeln(apply_func_pointer_2());

    //import stdlib;
}

