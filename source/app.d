import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;

import stdlib;

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

    string scriptfile;
    string sourcedir;

    if (args.size != 3) {
        /*
        auto msg = "At the moment, The compiler takes exactly ";
        msg ~= "two arguments (The source file and output directory)";
        writeln(stderr, msg);
        */
        scriptfile = "./sz/tests.sz";
        sourcedir = "./shaza";
    } else {
        scriptfile = args[1];
        sourcedir = dirName(scriptfile);
    }

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
