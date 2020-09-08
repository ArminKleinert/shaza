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

string[string] parseFully(string script, string sourcedir) {
    auto ctx = new Context();
    ctx.sourcedir = sourcedir;
    ctx = tokenize(ctx, script);
    ctx = buildBasicAst(ctx);
    createOutput(ctx);
    return getAllTexts();
}

void main(string[] args) {
    import std.file;
    import std.path;

    if (args.size != 3) {
        writeln(stderr,
                "At the moment, The compiler takes exactly two arguments (The source file and output directory)");
    }

    string scriptfile = args[1];
    string sourcedir = dirName(scriptfile);

    writeln(sourcedir);

    string txt = readText(scriptfile);
    foreach (k, v; parseFully(txt, sourcedir)) {
        auto file = File(args[2] ~ "/" ~ k ~ ".d", "w");
        file.writeln(v);
        writeln(file);
    }

    //import stdlib;
    import tests;

    tests.main1();

}
