module stdlib;

import std.stdio;
import std.conv;
import std.typecons;
import std.string;
import std.algorithm;
import std.array;
import std.functional;
struct Keyword {
string text;
alias text this;
this(string _text){
text = _text;
}
Keyword with_text(string text){
return Keyword(text);
}
Keyword clone(){
return Keyword(text);
}
}


auto keyword(string text){
return Keyword(text);
}

auto str(Keyword kw){
return kw.text;
}




int default_int = int.init;

uint default_uint = uint.init;

long default_long = long.init;

ulong default_ulong = ulong.init;

bool default_bool = bool.init;

float default_float = 0.0;

double default_double = 0.0;

string default_string = "";

T if2(T)(lazy bool cond, lazy T branchThen, lazy T branchElse){
return (cond?branchThen:branchElse);
}
T if2(T)(lazy bool cond, lazy T branchThen){
return (cond?branchThen:(T.init));
}

private N variadic_helper(N)(N delegate(N,N) accumulator_fn, N n, N[] nums...){
jumplbl1:
if(nums.length==0) {
return n;
} else {
accumulator_fn = accumulator_fn;
n = accumulator_fn(n, nums[0]);
nums = nums[1..$];
goto jumplbl1;
}
}
auto plus(N, N1)(N i0){
return i0;
}
auto plus(N, N1)(N i0, N1 i1){
return i0+i1;
}
auto plus(N)(N[] nums...){
return variadic_helper(delegate N(N n, N m){
return plus(n, m);
}, nums);
}
auto sub(N, N1)(N i0){
return -i0;
}
auto sub(N, N1)(N i0, N1 i1){
return i0-i1;
}
auto sub(N)(N[] nums...){
return variadic_helper(delegate N(N n, N m){
return plus(n, m);
}, nums);
}
auto mul(N, N1)(N i0, N1 i1){
return i0*i1;
}
auto mul(N)(N[] nums...){
return variadic_helper(delegate N(N n, N m){
return plus(n, m);
}, nums);
}
auto div(N, N1)(N i0, N1 i1){
return i0/i1;
}
auto div(N)(N[] nums...){
return variadic_helper(delegate N(N n, N m){
return plus(n, m);
}, nums);
}
auto mod(N, N1)(N i0, N1 i1){
return i0%i1;
}
auto mod(N)(N[] nums...){
return variadic_helper(delegate N(N n, N m){
return plus(n, m);
}, nums);
}

auto inc(N)(N n){
return plus(n, 1);
}
auto dec(N)(N n){
return sub(n, 1);
}

auto bit_and(Int1, Int2)(Int1 i0, Int2 i1){
return i0&i1;
}
auto bit_or(Int1, Int2)(Int1 i0, Int2 i1){
return i0|i1;
}
auto bit_xor(Int1, Int2)(Int1 i0, Int2 i1){
return i0^i1;
}
auto shift_left(Int1, Int2)(Int1 i0, Int2 i1){
return i0<<i1;
}
auto shift_right(Int1, Int2)(Int1 i0, Int2 i1){
return i0>>i1;
}

auto bit_negate(Int)(Int i0){
return ~i0;
}

bool eql_Q(T)(T e0, T e1){
return e0==e1;
}
bool not_eql_Q(T)(T e0, T e1){
return e0!=e1;
}
bool lt_Q(T)(T e0, T e1){
return e0<e1;
}
bool le_Q(T)(T e0, T e1){
return e0<=e1;
}
bool gt_Q(T)(T e0, T e1){
return e0>e1;
}
bool ge_Q(T)(T e0, T e1){
return e0>=e1;
}
bool nil_Q(T)(T e){
return e is null;
}
int compare(T)(T e0, T e1){
return if2(eql_Q(e0, e1), 0, if2(lt_Q(e0, e1), -1, 1));
}
bool pos_Q(T)(T e0){
return ge_Q(e0, 0);
}
bool neg_Q(T)(T e0){
return lt_Q(e0, 0);
}

bool not(bool b0){
return if2(b0, false, true);
}
bool and(lazy bool b0, lazy bool b1){
return b0&&b1;
}
bool and(lazy bool b0, lazy bool b1, lazy bool b2, lazy bool[] bs...){
if(not(and(b0, b1))) {
return false;
} else {
auto b = b2;
auto _rest = bs;
jumplbl1:
if(not(b)) {
return false;
} else {
if(_rest.length==0) {
return true;
} else {
b = _rest[0];
_rest = _rest[1..$];
goto jumplbl1;
}
}
}
}
bool nand(lazy bool b0, lazy bool b1){
return not(and(b0, b1));
}
bool nand(lazy bool b0, lazy bool b1, lazy bool b2, lazy bool[] bs...){
return not(and(b0, b1, b2));
}
bool or(lazy bool b0, lazy bool b1){
return b0||b1;
}
bool or(lazy bool b0, lazy bool b1, lazy bool b2, lazy bool[] bs...){
if(or(b0, b1)) {
return true;
} else {
auto b = b2;
auto _rest = bs;
jumplbl1:
if(b) {
return true;
} else {
if(_rest.length==0) {
return false;
} else {
b = _rest[0];
_rest = _rest[1..$];
goto jumplbl1;
}
}
}
}
bool nor(lazy bool b0, lazy bool b1){
return if2(b0, false, if2(b1, false, true));
}
bool nor(lazy bool b0, lazy bool b1, lazy bool[] bs...){
if(b0) {
return false;
} else {
if(b1) {
return false;
} else {
auto b = false;
auto _rest = bs;
jumplbl1:
if(_rest.length==0) {
return true;
} else {
b = _rest[0];
_rest = _rest[1..$];
goto jumplbl1;
}
}
}
}
bool xor(lazy bool b0, lazy bool b1){
return or(and(b0, not(b1)), and(not(b0), b1));
}





size_t size(T)(T[] coll){
return coll.length;
}
T[] values(T)(T[] coll){
return coll;
}
T[] append(T)(T[] coll, T value){
return coll~value;
}
T[] append_E(T)(ref T[] coll, T value){
coll~=value;
return coll;
}
T[] append(T)(T[] coll, T[] value){
return coll~value;
}
T[] append_E(T)(ref T[] coll, T[] value){
coll~=value;
return coll;
}
T[] prepend(T)(T value, T[] coll){
return [value]~coll;
}
T[] coll_clone(T)(T[] coll){
{
T[] res = [];
return append_E(res, coll);}
}
size_t[] keys(T)(T[] coll){
jumplbl1:
size_t[] n = [];
size_t temp = 0;
jumplbl2:
if(eql_Q(temp, size(coll))) {
return n;
} else {
n = append_E(n, temp);
temp = inc(temp);
goto jumplbl2;
}
}
T[] assoc_E(T)(T[] coll, size_t key, T value){
coll[key] = value;
return coll;
}
T[] assoc(T)(T[] coll, size_t key, T value){
return assoc_E(coll_clone(coll), key, value);
}
T[] slice(T)(T[] coll, size_t start){
return coll[start .. $];
}
T[] slice(T)(T[] coll, size_t start, size_t end_offset){
return coll[start .. $ - end_offset];
}
T get(T)(T[] coll, size_t k){
return if2(gt_Q(size(coll), k), coll[k], T.init);
}
T[] cleared(T)(T[] c){
{
T[] output = [];
return output;}
}
T[] resized(T)(T[] coll, size_t newsize){
{
auto cc = coll_clone(coll);
cc.length = newsize;
return cc;}
}

T[] vector(T)(T first_elem, T[] elements...){
return prepend(first_elem, elements);
}
T[K] entries(T, K)(T[] c){
jumplbl1:
if(eql_Q(size(c), 0)) {
{
T[K] res = [];
return res;}
}
auto keyseq = keys(c);
T[K] res = [];
auto first_key = get(keyseq, 0);
jumplbl2:
if(eql_Q(size(keyseq), 1)) {
return assoc_E(res, first_key, get(c, first_key));
} else {
keyseq = slice(keyseq, 1);
res = assoc_E(res, first_key, get(c, first_key));
first_key = get(keyseq, 1);
goto jumplbl2;
}
}
T first(T)(T[] c){
return get(values(c), 0);
}
T second(T)(T[] c){
return get(values(c), 1);
}
T last(T)(T[] c){
return get(values(c), dec(size(c)));
}
auto rest(T)(T[] c){
return slice(values(c), 1);
}
auto empty_Q(T)(T[] c){
return eql_Q(size(c), 0);
}
auto not_empty_Q(T)(T[] c){
return not(empty_Q(c));
}
size_t key_of(T)(T[] c, T value, size_t default_key){
jumplbl1:
auto r = keys(c);
jumplbl2:
if(empty_Q(r)) {
return default_key;
} else {
if(eql_Q(get(c, first(r)), value)) {
return first(r);
} else {
r = rest(r);
goto jumplbl2;
}
}
}
size_t key_of(T)(T[] c, T value){
return key_of(c, value, size_t.init);
}
size_t index_of(T)(T[] c, T value){
jumplbl1:
auto r = values(c);
size_t i = 0;
jumplbl2:
if(empty_Q(r)) {
return -1;
} else {
if(eql_Q(first(r), value)) {
return i;
} else {
r = rest(r);
i = inc(i);
goto jumplbl2;
}
}
}
bool starts_with_Q(T)(T[] c, T e){
return eql_Q(first(c), e);
}
bool starts_with_Q(T)(T[] c, T[] c1){
jumplbl1:
if(empty_Q(c1)) {
return true;
} else {
if(lt_Q(size(c), size(c1))) {
return false;
} else {
if(not_eql_Q(first(c), first(c1))) {
return false;
} else {
c = rest(c);
c1 = rest(c1);
goto jumplbl1;
}
}
}
}
bool ends_with_Q(T)(T[] c, T e){
return eql_Q(last(c), e);
}
bool ends_with_Q(T)(T[] c, T[] c1){
if(lt_Q(size(c), size(c1))) {
return false;
} else {
{
auto slice_idx = sub(size(c), size(c1));
auto sliced = slice(c, slice_idx);
return starts_with_Q(sliced, c1);}
}
}
T1 reduce(T, T1)(T delegate(T,T1) func, T[] c, T1 res){
jumplbl1:
auto _res = res;
auto _rest = c;
jumplbl2:
println_E(_rest);
println_E(_res);
if(empty_Q(_rest)) {
return res;
} else {
_res = func(first(_rest), _res);
_rest = rest(_rest);
goto jumplbl2;
}
}
T1 reduce(T, T1)(T delegate(T,T1) func, T[] c){
return if2(gt_Q(size(c), 1), reduce(func, rest(c), first(c)), if2(eql_Q(size(c), 1), first(c)), T.init);
}
auto filter(T)(T[] delegate(T) func, T[] c){
return reduce(delegate T[](T e, T[] res){
return if2(func(e), append_E(res, e), res);
}, c, cleared(c));
}
auto remove(T)(T[] delegate(T) func, T[] c){
return reduce(delegate T[](T e, T[] res){
return if2(func(e), res, append_E(res, e));
}, c, cleared(c));
}
bool any_Q(T)(bool delegate(T) pred, T[] c){
jumplbl1:
if(empty_Q(c)) {
return false;
} else {
if(pred(first(c))) {
return true;
} else {
pred = pred;
c = rest(c);
goto jumplbl1;
}
}
}
bool all_Q(T)(bool delegate(T) pred, T[] c){
jumplbl1:
if(empty_Q(c)) {
return true;
} else {
if(not(pred(first(c)))) {
return true;
} else {
pred = pred;
c = rest(c);
goto jumplbl1;
}
}
}
bool none_Q(T)(bool delegate(T) pred, T[] c){
return not(any_Q(pred, c));
}
bool includes_Q(T)(T[] c, T e){
return any_Q(delegate bool(T t1){
return eql_Q(t1, e);
}, c);
}
bool includes_Q(T)(T[] c, T[] other){
jumplbl1:
auto _rest = c;
jumplbl2:
if(lt_Q(size(_rest), size(other))) {
return false;
} else {
if(starts_with_Q(_rest, other)) {
return true;
} else {
_rest = rest(_rest);
goto jumplbl2;
}
}
}
bool in_Q(T)(T[] c, T e){
return includes_Q(c, e);
}
bool in_Q(T)(T[] c, T[] other){
return includes_Q(c, other);
}
bool contains_Q(T)(T[] c, T e){
return includes_Q(c, e);
}
bool contains_Q(T)(T[] c, T[] other){
return includes_Q(c, other);
}
auto map_into(T)(T delegate(T) func, T[] c, T[] output){
return append(output, func(first(c)));
}
auto map(T)(T delegate(T) func, T[] c){
return map_into(func, c, cleared(c));
}
auto map_E(T)(T delegate(T) func, T[] c){
jumplbl1:
auto keys = keys(c);
jumplbl2:
if(empty_Q(keys)) {
return c;
} else {
{
assoc_E(c, first(keys), func(get(c, first(keys))));
keys = rest(keys);
goto jumplbl2;}
}
}
auto map_entries_into(T)(T delegate(K,T) func, T[] c, T[] output){
return append(output, func(first(keys(c)), first(keys(c))));
}
auto map_entries(T)(T delegate(K,T) func, T[] c){
return map_entries_into(func, c, cleared(c));
}
auto map_entries_E(T)(T delegate(K,T) func, T[] c){
jumplbl1:
auto keys = keys(c);
jumplbl2:
if(empty_Q(keys)) {
return c;
} else {
{
assoc_E(c, first(keys), func(first(keys), get(c, first(keys))));
keys = rest(keys);
goto jumplbl2;}
}
}
private auto uniq_acc(T)(T[] c, T[] output){
jumplbl1:
if(empty_Q(c)) {
return output;
} else {
if(gt_Q(index_of(output, first(c)), -1)) {
return output;
} else {
c = rest(c);
output = append_E(output);
goto jumplbl1;
}
}
}
T[] uniq(T)(T[] c){
{
T[] output = [];
return uniq_acc(c, output, element);}
}
bool uniq_Q(T)(T[] c){
return eql_Q(size(c), size(uniq(c)));
}
private auto isort_acc(T)(T[] coll, T[] acc){
if(empty_Q(coll)) {
return acc;
} else {
return isort_acc(rest(coll), isort_insert(first(coll), acc));
}
}
private auto isort_insert(T)(T elem, T[] coll){
if(empty_Q(coll)) {
return [elem];
} else {
if(lt_Q(elem, first(coll))) {
return prepend(elem, coll);
} else {
return prepend(first(coll), isort_insert(elem, rest(coll)));
}
}
}
auto insertionsort(T)(T[] coll){
{
T[] acc = [];
return isort_acc(coll, acc);}
}


string to_s(T)(T e){
return to!string(e);
}

bool canConvert(toType, fromType)(fromType e) {
import std.conv;
try { to!toType(e); return true;
} catch(ConvException ce) { return false; }}
bool to_int_valid_Q(T)(T e){
return canConvert!int(e);
}
bool to_uint_valid_Q(T)(T e){
return canConvert!uint(e);
}
bool to_long_valid_Q(T)(T e){
return canConvert!long(e);
}
bool to_ulong_valid_Q(T)(T e){
return canConvert!ulong(e);
}
bool to_float_valid_Q(T)(T e){
return canConvert!float(e);
}
bool to_double_valid_Q(T)(T e){
return canConvert!double(e);
}

string str(T)(T obj){
return to!string(obj);
}

void print_E(T)(T text){
write(text);
}

void println_E(T)(T text){
writeln(text);
}

void error_E(T)(T text){
write(stderr, text);
}

void errorln_E(T)(T text){
writeln(stderr, text);
}

string readln_E(){
return stdin.readln;
}



