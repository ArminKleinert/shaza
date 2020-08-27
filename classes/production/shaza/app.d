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

    //string txt = readText("./sz/examples.sz");
    string txt = "(module none)
    ; Test anonymous types and parameter names

(define anon-params-0 (::int) (+ $0 1))
(define anon-params-1 (::int ::int) (+ $0 $1))
(define anon-params-2 (::int ::int ::int ::int) (+ (- (+ $0 $1) $2) $3))
(define anon-params-nested (::int ::int) (lambda ::int () (+ $0 $1)))

(define anon-types-0 (i) (+ i 1))
(define anon-types-1 (i j) (+ i j))
(define anon-types-2 (i ::int j) (+ i j))";
    foreach (k, v; parseFully(txt)) {
        auto file = File("source/" ~ k ~ ".d", "w");
        file.writeln(v);
        writeln(file);
    }

    import tests;

    tests.main1();

    //import stdlib;
}
