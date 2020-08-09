module sz;
import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;
import std.array;
auto abc = "def";
void foo(int i){
}
int bar(){
    return 1;
}
void baz(T)(T arg){
    writeln(arg);
}
N inc(N)(N n){
    return (n + 1);
}
N dec(N)(N n){
    return (n - 1);
}
T applySelf(T)(T elem, T delegate (T e) func){
return func(elem);
}
T applyIf(T)(T elem, T default1, bool delegate (T e) pred, T delegate (T e) func){
if(pred(elem)) {
return func(elem);
} else {
return default1;
}
}
