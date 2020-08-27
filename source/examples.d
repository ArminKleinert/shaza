module examples;

import stdlib;
import std.string;
import std.stdio;
import std.conv;
auto abc = "def";

long bcd = long.init;

int defg = 1000;

int bar(){
return 1;
}

void baz(T)(T arg){
writeln(arg);
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

auto opcall_test = (1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10);


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
MyType with_n(int n){
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
MyTypeWithMoreFields with_m(int m){
return new MyTypeWithMoreFields(m, n, o, p);
}
MyTypeWithMoreFields with_n(int n){
return new MyTypeWithMoreFields(m, n, o, p);
}
MyTypeWithMoreFields with_o(string o){
return new MyTypeWithMoreFields(m, n, o, p);
}
MyTypeWithMoreFields with_p(float p){
return new MyTypeWithMoreFields(m, n, o, p);
}
}


class GenericType(T) {
T entry;
this(T _entry){
entry = _entry;
}
GenericType with_entry(T entry){
return new GenericType(entry);
}
}


class EmptyType {
this(){
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
return ("" ~ i0 ~ "" ~ i1);
}
private string num_fn_2(Num)(Num i0, Num i1){
return ("" ~ i0 ~ "" ~ i1);
}
private Num num_fn_3(Num)(Num i0, Num i1){
return (i0 + i1);
}
private string num_fn_4(N)(N i0, N i1){
return ("" ~ i0 ~ "" ~ i1);
}
private int num_fn_5(Num)(N i0){
return to!int(i0);
}

N plus(N)(N i0, N i1){
return (i0 + i1);
}
N sub(N)(N i0, N i1){
return (i0 - i1);
}
N mul(N)(N i0, N i1){
return (i0 * i1);
}
N div(N)(N i0, N i1){
return (i0 / i1);
}
N mod(N)(N i0, N i1){
return (i0 % i1);
}
N inc(N)(N n){
return plus(n, 1);
}
N dec(N)(N n){
return sub(n, 1);
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
import std.functional;
return accept_func_pointer((std.functional.toDelegate(&export_next)), 1);
}

int apply_func_pointer_2(){
import std.functional;
return accept_func_pointer((std.functional.toDelegate(&export_next)), 1);
}


