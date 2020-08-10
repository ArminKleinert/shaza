import std.string;
import std.stdio;
auto abc = "def";
auto foo = ;
int bar(){
    return 1;
}
void baz(T)(T arg){
    writeln(arg);
}
bool eql_Q(T)(T o0, T o1){
    return o0==o1;
}
bool not_eql_Q(T)(T o0, T o1){
    return o0!=o1;
}
bool lt_Q(T)(T o0, T o1){
    return o0<o1;
}
bool le_Q(T)(T o0, T o1){
    return o0<=o1;
}
bool gt_Q(T)(T o0, T o1){
    return o0>o1;
}
bool ge_Q(T)(T o0, T o1){
    return o0>=o1;
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
class MyType {
    int n;
    this(int _n){
        n = _n;
    }}
class MyTypeWithMoreFields {
    int m;
    int n;
    string o;
    float p;
    this(int _m, int _n, string _o, float _p){
        m = _m;
        n = _n;
        o = _o;
        p = _p;
    }}
class GenericType(T) {
    T entry;
    this(T _entry){
        entry = _entry;
    }}
class EmptyType {
    this(){
    }}
bool ifTest(){
    ;
    if(true) {
        return true;
    } else {
        return false;
    }
}
void infinite_loop(){
    jumplbl1:
    writeln("hey!");
    goto jumplbl1;
}
int finite_loop(){
    int i = 0;
    auto v = 1;
    jumplbl1:
    if(ge_Q(i, 10)) {
        return i;
    } else {
        i = inc(i);
        v = 15;
        goto jumplbl1;
    }
    ;
}