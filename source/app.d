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
import compiler.output;

// SECTION Main

string parseFully(string script) {
    auto ctx = new Context();
    ctx = tokenize(ctx, script);
    ctx = buildBasicAst(ctx);
    return createOutput(ctx.ast);
}

void main() {
    /*
    import std.file;

    string txt = readText("./sz/stdlib.sz");
    writeln(parseFully(txt));
    */

    import stdlib;
    main1([]);
}
