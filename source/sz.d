
module stdlib;

import std.stdio;

import std.conv;

import std.typecons;

import std.string;

import std.algorithm;

import std.array;

int default_int = int.init;

uint default_uint = uint.init;

long default_long = long.init;

ulong default_ulong = ulong.init;

bool default_bool = bool.init;

float default_float = float.init;

double default_double = double.init;

string default_string = "";

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

Int bit_and(Int)(Int i0, Int i1){
    return (i0 & i1);
}
Int bit_or(Int)(Int i0, Int i1){
    return (i0 | i1);
}
Int bit_xor(Int)(Int i0, Int i1){
    return (i0 ^ i1);
}
Int bit_negate(Int)(Int i0){
    return (i0);
}
Int shift_left(Int)(Int i0, Int i1){
    return (i0 << i1);
}
Int shift_right(Int)(Int i0, Int i1){
    return (i0 >> i1);
}

bool eql_Q(T)(T e0, T e1){
    return e0==e1;
}
bool ref_eql(T)(T e0, T e1){
    return e0.ptr == e1.ptr;
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
    if(eql_Q(e0, e1)) {
        return 0;
    } else {
        if(lt_Q(e0, e1)) {
            return -1;
        } else {
            return 1;
        }
    }
}

bool and(lazy bool b0, lazy bool b1){
    return b0&&b1;
}
bool and(lazy bool b0, lazy bool b1, lazy bool b2){
    return b0&&b1&&b2;
}
bool or(lazy bool b0, lazy bool b1){
    return b0||b1;
}
bool or(lazy bool b0, lazy bool b1, lazy bool b2){
    return b0||b1||b2;
}
bool or(lazy bool[] bs){
    if(eql_Q(size(bs), 0)) {
        return false;
    }
    if(eql_Q(size(bs), 1)) {
        return first(bs);
    }
    auto _r = bs;
    jumplbl1:
    if(first(_r)) {
        return true;
    } else {
        _r = rest(bs);
        goto jumplbl1;
    }
}
bool not(bool b0){
    return !b0;
}

T[] append(T)(T[] coll0, T value){
    return coll0~value;
}
T[] append_E(T)(T[] coll0, T value){
    coll0~=value;
    return coll0;
}
T[] prepend(T)(T value, T[] coll0){
    return [value] ~ coll0;
}
T[] append(T)(T[] coll0, T[] coll1){
    T[] res = coll0;
    T[] _rest = coll1;
    jumplbl1:
    if(empty_Q(_rest)) {
        return res;
    } else {
        res = append(coll0, first(coll1));
        _rest = rest(coll1);
        goto jumplbl1;
    }
}
T[] append_E(T)(T[] coll0, T[] coll1){
    T[] res = coll0;
    auto _rest = coll1;
    jumplbl1:
    if(empty_Q(_rest)) {
        return res;
    } else {
        res = append_E(coll0, first(coll1));
        _rest = rest(coll1);
        goto jumplbl1;
    }
}

T[] seq_of(T)(){
    {
        T[] res = [];
        return res;
    }
}
size_t size(T)(T[] coll){
    return coll.length;
}
bool empty_Q(T)(T[] coll){
    return eql_Q(size(coll), 0);
}
T get(T)(T[] coll, size_t index){
    return coll[index];
}
T first(T)(T[] coll){
    return get(coll, 0);
}
T second(T)(T[] coll){
    return get(coll, 1);
}
T last(T)(T[] coll){
    return get(coll, dec(size(coll)));
}
T[] rest(T)(T[] coll){
    return slice(coll, 1);
}
T[] resized(T)(T[] coll, size_t newsize){
    {
        auto cc = coll_clone(coll);
        cc.length = newsize;
        cc;
    }
}
T[] coll_clone(T)(T[] coll){
    return concat(seq_of!T, coll);
}
T[] assoc_E(T)(T[] coll, size_t index, T elem){
    coll[index] = elem;
    return coll;
}
T[] assoc(T)(T[] coll, size_t index, T elem){
    return assoc_E(coll_clone(coll), index, elem);
}
T[] slice(T)(T[] coll, size_t start){
    return coll[start .. $];
}
T[] slice(T)(T[] coll, size_t start, size_t end_offset){
    return coll[start .. $ - end_offset];
}

bool contains_Q(T)(T[] coll, T value){
    T current = first(coll);
    T[] rest_ = rest(coll);
    jumplbl1:
    if(eql_Q(current, value)) {
        return true;
    } else {
        current = first(rest_);
        rest_ = rest(coll);
        goto jumplbl1;
    }
}
bool starts_with_Q(T)(T[] coll, T e){
    return eql_Q(first(coll), e);
}
bool starts_with_Q(T)(T[] coll, T[] other){
    if(lt_Q(size(coll), size(other))) {
        return false;
    }
    auto _coll0 = rest(coll);
    auto _coll1 = rest(other);
    jumplbl1:
    if(not_eql_Q(first(_coll0), first(_coll1))) {
        return false;
    } else {
        if(empty_Q(_coll1)) {
            return true;
        } else {
            _coll0 = rest(_coll0);
            _coll1 = rest(_coll1);
            goto jumplbl1;
        }
    }
}
bool ends_with_Q(T)(T[] coll, T e){
    return eql_Q(last(coll), e);
}
bool ends_with_Q(T)(T[] coll, T[] other){
    if(lt_Q(size(coll), size(other))) {
        return false;
    } else {
        {
            auto slice_idx = sub(size(coll), size(other));
            auto sliced = slice(coll, slice-idx);
            return starts_with_Q(sliced, other);
        }
    }
}

T[] repeated(T)(T elem, size_t times){
    T[] result = [];
    auto i = times;
    jumplbl1:
    if(le_Q(i, 0)) {
        return result;
    } else {
        result = append(result, elem);
        i = dec(i);
        goto jumplbl1;
    }
}
T[] repeatedly(T)(T delegate() func, size_t times){
    T[] result = [];
    auto i = 0;
    jumplbl1:
    if(ge_Q(i, times)) {
        return result;
    } else {
        result = append(result, func());
        i = inc(i);
        goto jumplbl1;
    }
}
T[] map(T)(T delegate(T) func, T[] coll){
    T[] result = [];
    T[] _rest = coll;
    jumplbl1:
    if(empty_Q(_rest)) {
        return result;
    } else {
        result = append(result, func(first(_rest)));
        _rest = rest(_rest);
        goto jumplbl1;
    }
}
T1 reduce(T, T1)(T1 delegate(T,T1) func, T[] coll, T1 initval){
    T1 result = initval;
    T[] _rest = coll;
    jumplbl1:
    if(empty_Q(_rest)) {
        return result;
    } else {
        result = func(first(_rest), result);
        _rest = rest(_rest);
        goto jumplbl1;
    }
}
T[] remove(T)(bool delegate(T) pred, T[] coll){
    T[] result = [];
    auto _rest = coll;
    jumplbl1:
    if(empty_Q(_rest)) {
        return result;
    } else {
        if(pred(first(_rest))) {
            result = result;
            _rest = rest(_rest);
            goto jumplbl1;
        } else {
            result = append(result, first(_rest));
            _rest = rest(_rest);
            goto jumplbl1;
        }
    }
}
T[] remove(T)(T[] coll, T elem){
    return remove(delegate bool(T v){
        return eql_Q(v, elem);
    });
}
T[] filter(T)(bool delegate(T) pred, T[] coll){
    T[] result = [];
    auto _rest = coll;
    jumplbl1:
    if(empty_Q(_rest)) {
        return result;
    } else {
        if(pred(first(_rest))) {
            result = append(result, first(_rest));
            _rest = rest(_rest);
            goto jumplbl1;
        } else {
            result = result;
            _rest = rest(_rest);
            goto jumplbl1;
        }
    }
}
T[] all_Q(T)(bool delegate(T) pred, T[] coll){
    auto _rest = coll;
    jumplbl1:
    if(empty_Q(_rest)) {
        return true;
    } else {
        if(not(pred(first(_rest)))) {
            return false;
        } else {
            _rest = rest(_rest);
            goto jumplbl1;
        }
    }
}
T[] none_Q(T)(bool delegate(T) pred, T[] coll){
    auto _rest = coll;
    jumplbl1:
    if(empty_Q(_rest)) {
        return true;
    } else {
        if(pred(first(_rest))) {
            return false;
        } else {
            _rest = rest(_rest);
            goto jumplbl1;
        }
    }
}
T[] any_Q(T)(bool delegate(T) pred, T[] coll){
    auto _rest = coll;
    jumplbl1:
    if(empty_Q(_rest)) {
        return false;
    } else {
        if(pred(first(_rest))) {
            return true;
        } else {
            _rest = rest(_rest);
            goto jumplbl1;
        }
    }
}
T[] uniques(T)(T[] coll){
    if(lt_Q(size(coll), 2)) {
        return coll;
    }
    T[] sorted = sort(coll);
    T prev = first(sorted);
    T[] result = [prev];
    jumplbl1:
    if(empty_Q(sorted)) {
        return result;
    } else {
        if(eql_Q(prev, first(sorted))) {
            sorted = rest(sorted);
            prev = prev;
            result = result;
            goto jumplbl1;
        } else {
            sorted = rest(sorted);
            prev = first(sorted);
            result = append(result, prev);
            goto jumplbl1;
        }
    }
}
T[] bin_search(T)(T[] seq, T key){
    if(gt_Q(size(seq), 1)) {
        {
            auto m = div(size(seq), 2);
            if(eql_Q(get(seq, m), key)) {
                return true;
            } else {
                if(lt_Q(key, get(seq, m))) {
                    return bin_search(slice(seq, 0, m), key);
                } else {
                    return bin_search(slice(seq, inc(m)), key);
                }
            }
        }
    } else {
        if(eql_Q(size(seq), 1)) {
            return eql_Q(first(seq), key);
        } else {
            return false;
        }
    }
}
T[] insertionsort(T)(T[] coll){
    {
        T[] acc = [];
        isort_acc(coll, acc);
    }
}
private T[] isort_acc(T)(T[] coll, T[] acc){
    if(empty_Q(coll)) {
        return acc;
    } else {
        isort_acc(rest(coll), isort_insert(first(coll), acc));
    }
}
private T[] isort_insert(T)(T elem, T[] coll){
    if(empty_Q(coll)) {
        return seq_of(elem);
    } else {
        if(lt_Q(elem, first(coll))) {
            prepend(elem, coll);
        } else {
            prepend(first(coll), isort_insert(elem, rest(coll)));
        }
    }
}
private T[] qs_append(T)(T[] c0, T e, T[] c1){
    return append(append(c0, e), c1);
}
T[] quicksort(T)(T[] coll){
    if(empty_Q(coll)) {
        return coll;
    } else {
        {
            auto piv = first(coll);
            return qs_append(filter(delegate T(T x){
                return le_Q(x, piv);
            }, coll), piv, filter(delegate T(T x){
                return gt_Q(x, piv);
            }, coll));
        }
    }
}
string to_s(T)(T e){
    return to!string(e);
}
bool canConvert(toType, fromType)(fromType e) {
    import std.conv;
    try { to!toType(e); return true;
    } catch(ConvException ce) { return false; }}bool to_int_valid_Q(T)(T e){
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
void print_E(T)(T text){
    return write(text);
}
void println_E(T)(T text){
    return writeln(text);
}
void error_E(T)(T text){
    return write(stderr, text);
}
void errorln_E(T)(T text){
    return writeln(stderr, text);
}
string readln_E(T)(){
    return stdin.readln;
}
void main1(string[] args){
    println_E("Hello world!");
}

T sum(T)(T[] seq){
    return reduce(delegate T(T l0, T l1){
        return plus(l0, l1);
    }, seq, 0);
}

T min(T)(T[] coll){
    if(eql_Q(size(coll), 0)) {
        return T.init;
    }
    if(eql_Q(size(coll), 1)) {
        return first(coll);
    }
    T[] c = rest(coll);
    T res = first(coll);
    jumplbl1:
    if(empty_Q(c)) {
        return res;
    } else {
        if(lt_Q(first(c), res)) {
            c = rest(c);
            res = first(c);
            goto jumplbl1;
        } else {
            c = rest(c);
            res = res;
            goto jumplbl1;
        }
    }
}

T max(T)(T[] coll){
    if(eql_Q(size(coll), 0)) {
        return T.init;
    }
    if(eql_Q(size(coll), 1)) {
        return first(coll);
    }
    T[] c = rest(coll);
    T res = first(coll);
    jumplbl1:
    if(empty_Q(c)) {
        return res;
    } else {
        if(gt_Q(first(c), res)) {
            c = rest(c);
            res = first(c);
            goto jumplbl1;
        } else {
            c = rest(c);
            res = res;
            goto jumplbl1;
        }
    }
}

long[] divisors(long l){
    long[] res = [];
    auto n = shift_right(l, 1L);
    jumplbl1:
    if(eql_Q(n, 0)) {
        return res;
    } else {
        if(eql_Q(mod(l, n), 0)) {
            res = append(res, n);
            n = dec(n);
            goto jumplbl1;
        } else {
            res = res;
            n = dec(n);
            goto jumplbl1;
        }
    }
}

long sum_of_divisors(long l){
    long res = 0;
    auto n = div(l, 2);
    jumplbl1:
    if(eql_Q(n, 0)) {
        return res;
    } else {
        if(eql_Q(mod(l, n), 0)) {
            res = plus(res, n);
            n = dec(n);
            goto jumplbl1;
        } else {
            res = res;
            n = dec(n);
            goto jumplbl1;
        }
    }
}

long sum_of_divisors_1(long l){
    return sum(divisors(l));
}

T fib(T)(T _n){
    auto n = _n;
    auto a = 1;
    auto b = 0;
    jumplbl1:
    if(eql_Q(n, 0)) {
        return b;
    } else {
        n = dec(n);
        a = plus(a, b);
        b = a;
        goto jumplbl1;
    }
}

double approx_euler(long l){
    return div(1.0, fib(l));
}



