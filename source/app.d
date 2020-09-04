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
    ctx = tokenize(ctx, script);
    ctx = buildBasicAst(ctx);
    createOutput(ctx.ast);
    return getAllTexts();
}

void main() {
    import std.file;

    string txt = readText("./sz/tests.sz");
    foreach (k, v; parseFully(txt)) {
        auto file = File("source/" ~ k ~ ".d", "w");
        file.writeln(v);
        writeln(file);
    }

    import tests;
    tests.main1();

    //import stdlib;
}
