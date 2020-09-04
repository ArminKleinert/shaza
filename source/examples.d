module examples;

import stdlib;
import std.string;
import std.stdio;
import std.conv;
import std.functional;
auto abc = "def";

long bcd = long.init;

int defg = 1000;

int bar(){
return 1;
}

auto baz(T)(T arg){
return writeln(arg);
}

bool implicit_return_0(){
return 1;
}

bool implicit_return_1(){
return 1;
}

int does_nothing(){
return 123;
}

void no_return_on_void(){
does_nothing();
}

int implicit_init_return_0(){
return int.init;
}


bool implicit_init_return_1(){
return bool.init;
}


bool implicit_init_test = bool.init;


void let_example(){
{
int i = 10;
auto j = 11;
auto abc = "";
writefln("%s %s %s", i, j, abc);}
}

class MyType {
int n;
this(int _n){
n = _n;
}
MyType clone(){
return new MyType(n);
}
}


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
}
MyTypeWithMoreFields clone(){
return new MyTypeWithMoreFields(m, n, o, p);
}
}


class GenericType(T) {
T entry;
this(T _entry){
entry = _entry;
}
GenericType clone(){
return new GenericType(entry);
}
}


class EmptyType {
this(){
}
EmptyType clone(){
return new EmptyType();
}
}


class MyStruct {
int n;
this(int _n){
n = _n;
}
MyStruct clone(){
return new MyStruct(n);
}
}


class MyStructWithMoreFields {
int m;
int n;
string o;
float p;
this(int _m, int _n, string _o, float _p){
m = _m;
n = _n;
o = _o;
p = _p;
}
MyStructWithMoreFields clone(){
return new MyStructWithMoreFields(m, n, o, p);
}
}


class GenericStruct(T) {
T entry;
this(T _entry){
entry = _entry;
}
GenericStruct clone(){
return new GenericStruct(entry);
}
}


class EmptyStruct {
this(){
}
EmptyStruct clone(){
return new EmptyStruct();
}
}


bool if_test(){
return if2(true, true, false);
}

bool when_test(){
if(true) {
return true;
} else {
return false;
}
}

int tail_recur_test(int n, int res){
return if2(le_Q(n, 1), 1, tail_recur_test(dec(n), res));
}

int when_as_expression(int n){
if(lt_Q(n, 0)) {
return sub(0, n);
} else {
return n;
}
}

int loop_as_expression(int n){
return 1;
}

int let_as_expression(int n){
{
auto a = 1;
auto b = 1;
return a+b;}
}

void setv_attr_test_1(MyType mt){
mt.n = 15;
}

void setv_attr_test_2(MyType mt){
mt.n = 15;
}

void setv_attr_test_3(MyType mt){
mt.n = 15;
}

void setv_attr_test_4(MyType mt){
mt.n = 15;
}

auto chtest1 = '\t';

auto chtest2 = ' ';

auto chtest3 = '\n';

auto chtest4 = 'z';


auto d = delegate int(int i){
return inc(i);
};

int call_lambda(int delegate(int) l){
return l(1);
}

void call_call_lambda(){
writeln(call_lambda(delegate int(int i){
return inc(i);
}));
}

int give_int_and_print(int i){
writeln(i);
return i;
}

bool or_(lazy int i, lazy int j){
return i||j;
}

void docall(){
or_(give_int_and_print(0), give_int_and_print(1));
or_(give_int_and_print(5), give_int_and_print(9));
}

static int static_i_0 = 0;

static int static_i_1 = 0;

immutable(int) immutable_i = 0;

int[] int_array = [];

int* int_pointer = null;

void meta_test_0(T)(T arg){
writeln(arg);
}

void meta_test_1(T1, T2)(T1 arg){
writeln(arg);
}

bool is_nil2_Q(T)(T o){
return o is null;
}

void call_alias(){
is_nil2_Q(null);
}

private void hidden_fn(){
writeln();
}

int awesomeness(){
return 41;
}

void call_awesome_1(){
writeln(awesomeness());
}

void call_awesome_2(){
writeln(awesomeness());
}

private string num_fn_1(Num)(Num i0, Num i1){
return ~i0~~i1;
}
private string num_fn_2(Num)(Num i0, Num i1){
return ~i0~~i1;
}
private Num num_fn_3(Num)(Num i0, Num i1){
return plus(i0, i1);
}
private string num_fn_4(N)(N i0, N i1){
return ~i0~~i1;
}
private int num_fn_5(Num)(N i0){
return to!int(i0);
}

string[] returnAList(){
return ["a","b","c"];
}

void recur_test(){
jumplbl1:
writeln("hey!");
goto jumplbl1;
}

int loop_recur_test(){
jumplbl1:
int i = 0;
auto v = 1;
jumplbl2:
if(i<10) {
return i;
} else {
i = inc(i);
v = 15;
goto jumplbl2;
}
}

bool and(lazy bool b0, lazy bool b1){
return b0&&b1;
}
bool and(lazy bool b0, lazy bool b1, lazy bool b2){
return b0&&b1&&b2;
}

bool check(bool b){
return b;
}

V[K] get_by_key(V, K)(V[K] m, K k){
return m[k];
}

int export_next(int i){
return i+1;
}

int accept_func_pointer(int delegate(int) f, int i0){
return f(i0);
}

int apply_func_pointer(){
return accept_func_pointer((std.functional.toDelegate(&export_next)), 1);
}

int apply_func_pointer_alias(){
return accept_func_pointer((std.functional.toDelegate(&export_next)), 1);
}

int accept_anonymous_func_type(FUNC)(FUNC f, int i0){
return f(i0);
}

int apply_func_pointer_anonymous_func_type(){
return accept_func_pointer((std.functional.toDelegate(&export_next)), 1);
}

auto plus2(T)(T i){
return plus(i, i);
}

void test_plus2(){
writeln(plus2(8));
}

auto byauto(T)(){
return T.init;
}

auto auto_fn(){
return plus(1, 2.0);
}

auto addAny(T, T1)(T i, T1 j){
return i+j;
}

auto anon_params_1(_gensym_637348207335596875, _gensym_637348207335596905)(_gensym_637348207335596875 _gensym_637348207335596891, _gensym_637348207335596905 _gensym_637348207335596917){
return _gensym_637348207335596891+_gensym_637348207335596917;
}

auto anon_params_2(int _gensym_637348207335597914, float _gensym_637348207335597929, int _gensym_637348207335597941){
return _gensym_637348207335597914+_gensym_637348207335597929+_gensym_637348207335597941;
}

auto anon_params_nested(int _gensym_637348207335599333){
return delegate int(){
return _gensym_637348207335599333;
};
}

auto anon_types_0(_gensym_637348207335599852)(_gensym_637348207335599852 i){
return i+1;
}

auto anon_types_1(_gensym_637348207335599912)(_gensym_637348207335599912 i, int j){
return i+j;
}

auto anon_types_2(_gensym_637348207335599986, _gensym_637348207335600002)(_gensym_637348207335599986 i, _gensym_637348207335600002 j){
return i+j;
}

auto anon_types_3(_gensym_637348207335600073)(_gensym_637348207335600073 i, int j){
return i+j;
}

auto anon_types_4(_gensym_637348207335600139, _gensym_637348207335600154)(_gensym_637348207335600139 i, _gensym_637348207335600154 j){
return i+j;
}

alias alias1 = int;
alias alias2 = byauto;


auto includedFunction(int i){
return i;
}


auto varargs1(int[] i...){
return println_E(i);
}

auto not_varargs(int i){
return println_E(i);
}

auto foo15(){
return println_E(delegate (int i){
return plus(i, i);
}(5));
}

T sum(T)(T[] seq){
return reduce(delegate T(T l0, T l1){
return plus(l0, l1);
}, seq, 0);
}

T sum(T)(T[] seq){
return reduce(delegate T(T l0, T l1){
return plus(l0, l1);
}, seq, 0);
}

auto sum(T)(T[] _gensym_637348207335611630){
return reduce((std.functional.toDelegate(&plus)), _gensym_637348207335611630, 0);
}

auto sum(_gensym_637348207335612197)(_gensym_637348207335612197 _gensym_637348207335612211){
return reduce((std.functional.toDelegate(&plus)), _gensym_637348207335612211, 0);
}


