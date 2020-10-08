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
    this(string _text) {
        text = _text;
    }

    Keyword with_text(string text) {
        return Keyword(text);
    }

    Keyword clone() {
        return Keyword(text);
    }
}

auto keyword(string text) {
    return Keyword(text);
}

auto str(Keyword kw) {
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

T if2(T)(lazy bool cond, lazy T branchThen, lazy T branchElse) {
    return (cond ? branchThen : branchElse);
}

T if2(T)(lazy bool cond, lazy T branchThen) {
    return (cond ? branchThen : (T.init));
}

private N variadic_helper(N)(N delegate(N, N) accumulator_fn, N n0, N n1, N n2, N[] nums) {
jumplbl1:
    auto acc = accumulator_fn(accumulator_fn(n0, n1), n2);
    auto _rest = nums;
jumplbl2:
    if (_rest.length < 1) {
        return acc;
    } else {
        if (_rest.length == 1) {
            return accumulator_fn(acc, _rest[0]);
        } else {
            {
                auto acc_0 = accumulator_fn(acc, _rest[0]);
                auto _rest_1 = _rest[1 .. $];
                acc = acc_0;
                _rest = _rest_1;
            }
            goto jumplbl2;
        }
    }
}

auto plus(N, N1)(N i0) {
    return i0;
}

auto plus(N, N1)(N i0, N1 i1) {
    return i0 + i1;
}

auto plus(N)(N i0, N i1, N i2, N[] nums...) {
    return variadic_helper(delegate N(N n, N m) { return n + m; }, i0, i1, i2, nums);
}

auto sub(N, N1)(N i0) {
    return -i0;
}

auto sub(N, N1)(N i0, N1 i1) {
    return i0 - i1;
}

auto sub(N)(N i0, N i1, N i2, N[] nums...) {
    return variadic_helper(delegate N(N n, N m) { return n - m; }, i0, i1, i2, nums);
}

auto mul(N, N1)(N i0, N1 i1) {
    return i0 * i1;
}

auto mul(N)(N i0, N i1, N i2, N[] nums...) {
    return variadic_helper(delegate N(N n, N m) { return n * m; }, i0, i1, i2, nums);
}

auto div(N, N1)(N i0, N1 i1) {
    return i0 / i1;
}

auto div(N)(N i0, N i1, N i2, N[] nums...) {
    return variadic_helper(delegate N(N n, N m) { return n / m; }, i0, i1, i2, nums);
}

auto mod(N, N1)(N i0, N1 i1) {
    return i0 % i1;
}

auto mod(N)(N i0, N i1, N i2, N[] nums...) {
    return variadic_helper(delegate N(N n, N m) { return n % m; }, i0, i1, i2, nums);
}

auto inc(N)(N n) {
    return plus(n, 1);
}

auto dec(N)(N n) {
    return sub(n, 1);
}

auto bit_and(Int1, Int2)(Int1 i0, Int2 i1) {
    return i0 & i1;
}

auto bit_or(Int1, Int2)(Int1 i0, Int2 i1) {
    return i0 | i1;
}

auto bit_xor(Int1, Int2)(Int1 i0, Int2 i1) {
    return i0 ^ i1;
}

auto shift_left(Int1, Int2)(Int1 i0, Int2 i1) {
    return i0 << i1;
}

auto shift_right(Int1, Int2)(Int1 i0, Int2 i1) {
    return i0 >> i1;
}

auto bit_negate(Int)(Int i0) {
    return ~i0;
}

bool eql_Q(T, T1)(T e0, T1 e1) {
    return e0 == e1;
}

bool not_eql_Q(T, T1)(T e0, T1 e1) {
    return e0 != e1;
}

bool lt_Q(T, T1)(T e0, T1 e1) {
    return e0 < e1;
}

bool le_Q(T, T1)(T e0, T1 e1) {
    return e0 <= e1;
}

bool gt_Q(T, T1)(T e0, T1 e1) {
    return e0 > e1;
}

bool ge_Q(T, T1)(T e0, T1 e1) {
    return e0 >= e1;
}

bool nil_Q(T, T1)(T e) {
    return e is null;
}

int compare(T, T1)(T e0, T1 e1) {
    return if2(eql_Q(e0, e1), 0, if2(lt_Q(e0, e1), -1, 1));
}

bool pos_Q(T)(T e0) {
    return ge_Q(e0, 0);
}

bool neg_Q(T)(T e0) {
    return lt_Q(e0, 0);
}

bool not(bool b0) {
    return if2(b0, false, true);
}

bool and(lazy bool b0, lazy bool b1) {
    return b0 && b1;
}

bool and(lazy bool b0, lazy bool b1, lazy bool b2, lazy bool[] bs...) {
    if (not(and(b0, b1))) {
        return false;
    } else {
        auto b = b2;
        auto _rest = bs;
    jumplbl1:
        if (not(b)) {
            return false;
        } else {
            if (_rest.length == 0) {
                return true;
            } else {
                {
                    auto b_0 = _rest[0];
                    auto _rest_1 = _rest[1 .. $];
                    b = b_0;
                    _rest = _rest_1;
                }
                goto jumplbl1;
            }
        }
    }
}

bool nand(lazy bool b0, lazy bool b1) {
    return not(and(b0, b1));
}

bool nand(lazy bool b0, lazy bool b1, lazy bool b2, lazy bool[] bs...) {
    return not(and(b0, b1, b2));
}

bool or(lazy bool b0, lazy bool b1) {
    return b0 || b1;
}

bool or(lazy bool b0, lazy bool b1, lazy bool b2, lazy bool[] bs...) {
    if (or(b0, b1)) {
        return true;
    } else {
        auto b = b2;
        auto _rest = bs;
    jumplbl1:
        if (b) {
            return true;
        } else {
            if (_rest.length == 0) {
                return false;
            } else {
                {
                    auto b_0 = _rest[0];
                    auto _rest_1 = _rest[1 .. $];
                    b = b_0;
                    _rest = _rest_1;
                }
                goto jumplbl1;
            }
        }
    }
}

bool nor(lazy bool b0, lazy bool b1) {
    return if2(b0, false, if2(b1, false, true));
}

bool nor(lazy bool b0, lazy bool b1, lazy bool[] bs...) {
    if (b0) {
        return false;
    } else {
        if (b1) {
            return false;
        } else {
            auto b = false;
            auto _rest = bs;
        jumplbl1:
            if (_rest.length == 0) {
                return true;
            } else {
                {
                    auto b_0 = _rest[0];
                    auto _rest_1 = _rest[1 .. $];
                    b = b_0;
                    _rest = _rest_1;
                }
                goto jumplbl1;
            }
        }
    }
}

bool xor(lazy bool b0, lazy bool b1) {
    return or(and(b0, not(b1)), and(not(b0), b1));
}

size_t size(T)(T[] coll) {
    return coll.length;
}

T[] values(T)(T[] coll) {
    return coll;
}

T[] append(T)(T[] coll, T value) {
    return coll ~ value;
}

T[] append_E(T)(ref T[] coll, T value) {
    coll ~= value;
    return coll;
}

T[] append(T)(T[] coll, T[] value) {
    return coll ~ value;
}

T[] append_E(T)(ref T[] coll, T[] value) {
    coll ~= value;
    return coll;
}

T[] prepend(T)(T value, T[] coll) {
    return [value] ~ coll;
}

T[] coll_clone(T)(T[] coll) {
    {
        T[] res = [];
        return append_E(res, coll);
    }
}

size_t[] keys(T)(T[] coll) {
jumplbl1:
    size_t[] n = [];
    size_t temp = 0;
jumplbl2:
    if (eql_Q(temp, size(coll))) {
        return n;
    } else {
        {
            auto n_0 = append_E(n, temp);
            auto temp_1 = inc(temp);
            n = n_0;
            temp = temp_1;
        }
        goto jumplbl2;
    }
}

T[] assoc_E(T)(T[] coll, size_t key, T value) {
    coll[key] = value;
    return coll;
}

T[] assoc(T)(T[] coll, size_t key, T value) {
    return assoc_E(coll_clone(coll), key, value);
}

T[] slice(T)(T[] coll, size_t start) {
    return coll[start .. $];
}

T[] slice(T)(T[] coll, size_t start, size_t end_offset) {
    return coll[start .. $ - end_offset];
}

T get(T)(T[] coll, size_t k) {
    return if2(gt_Q(size(coll), k), coll[k], T.init);
}

T[] cleared(T)(T[] c) {
    {
        T[] output = [];
        return output;
    }
}

T[] resized(T)(T[] coll, size_t newsize) {
    {
        auto cc = coll_clone(coll);
        cc.length = newsize;
        return cc;
    }
}

T[] vector(T)(T first_elem, T[] elements...) {
    return prepend(first_elem, elements);
}

T[K] entries(T, K)(T[] c) {
jumplbl1:
    if (eql_Q(size(c), 0)) {
        {
            T[K] res = [];
            return res;
        }
    }
    auto keyseq = keys(c);
    T[K] res = [];
    auto first_key = get(keyseq, 0);
jumplbl2:
    if (eql_Q(size(keyseq), 1)) {
        return assoc_E(res, first_key, get(c, first_key));
    } else {
        {
            auto keyseq_0 = slice(keyseq, 1);
            auto res_1 = assoc_E(res, first_key, get(c, first_key));
            auto first_key_2 = get(keyseq, 1);
            keyseq = keyseq_0;
            res = res_1;
            first_key = first_key_2;
        }
        goto jumplbl2;
    }
}

T first(T)(T[] c) {
    return get(values(c), 0);
}

T second(T)(T[] c) {
    return get(values(c), 1);
}

T last(T)(T[] c) {
    return get(values(c), dec(size(c)));
}

auto rest(T)(T[] c) {
    return slice(values(c), 1);
}

auto empty_Q(T)(T[] c) {
    return eql_Q(size(c), 0);
}

auto not_empty_Q(T)(T[] c) {
    return not(empty_Q(c));
}

size_t key_of(T)(T[] c, T value, size_t default_key) {
jumplbl1:
    auto r = keys(c);
jumplbl2:
    if (empty_Q(r)) {
        return default_key;
    } else {
        if (eql_Q(get(c, first(r)), value)) {
            return first(r);
        } else {
            {
                auto r_0 = rest(r);
                r = r_0;
            }
            goto jumplbl2;
        }
    }
}

size_t key_of(T)(T[] c, T value) {
    return key_of(c, value, size_t.init);
}

long index_of(T)(T[] c, T value) {
jumplbl1:
    auto r = values(c);
    long i = 0;
jumplbl2:
    if (empty_Q(r)) {
        return -1;
    } else {
        if (eql_Q(first(r), value)) {
            return i;
        } else {
            {
                auto r_0 = rest(r);
                auto i_1 = inc(i);
                r = r_0;
                i = i_1;
            }
            goto jumplbl2;
        }
    }
}

bool starts_with_Q(T)(T[] c, T e) {
    return eql_Q(first(c), e);
}

bool starts_with_Q(T)(T[] c, T[] c1) {
jumplbl1:
    if (empty_Q(c1)) {
        return true;
    } else {
        if (lt_Q(size(c), size(c1))) {
            return false;
        } else {
            if (not_eql_Q(first(c), first(c1))) {
                return false;
            } else {
                {
                    auto c_0 = rest(c);
                    auto c1_1 = rest(c1);
                    c = c_0;
                    c1 = c1_1;
                }
                goto jumplbl1;
            }
        }
    }
}

bool ends_with_Q(T)(T[] c, T e) {
    return eql_Q(last(c), e);
}

bool ends_with_Q(T)(T[] c, T[] c1) {
    if (lt_Q(size(c), size(c1))) {
        return false;
    } else {
        {
            auto slice_idx = sub(size(c), size(c1));
            auto sliced = slice(c, slice_idx);
            return starts_with_Q(sliced, c1);
        }
    }
}

T1 reduce(T, T1)(T1 delegate(T, T1) func, T[] c, T1 res) {
jumplbl1:
    auto _res = res;
    auto _rest = c;
jumplbl2:
    if (empty_Q(_rest)) {
        return _res;
    } else {
        {
            auto _res_0 = func(first(_rest), _res);
            auto _rest_1 = rest(_rest);
            _res = _res_0;
            _rest = _rest_1;
        }
        goto jumplbl2;
    }
}

T reduce(T)(T delegate(T, T) func, T[] c) {
    return if2(gt_Q(size(c), 1), reduce(func, rest(c), first(c)),
            if2(eql_Q(size(c), 1), first(c), T.init));
}

auto filter(T)(bool delegate(T) func, T[] c) {
    return reduce(delegate T[](T e, T[] res) {
        return if2(func(e), append_E(res, e), res);
    }, c, cleared(c));
}

auto remove(T)(bool delegate(T) func, T[] c) {
    return reduce(delegate T[](T e, T[] res) {
        return if2(func(e), res, append_E(res, e));
    }, c, cleared(c));
}

bool any_Q(T)(bool delegate(T) pred, T[] c) {
jumplbl1:
    if (empty_Q(c)) {
        return false;
    } else {
        if (pred(first(c))) {
            return true;
        } else {
            {
                auto pred_0 = pred;
                auto c_1 = rest(c);
                pred = pred_0;
                c = c_1;
            }
            goto jumplbl1;
        }
    }
}

bool all_Q(T)(bool delegate(T) pred, T[] c) {
jumplbl1:
    if (empty_Q(c)) {
        return true;
    } else {
        if (not(pred(first(c)))) {
            return false;
        } else {
            {
                auto pred_0 = pred;
                auto c_1 = rest(c);
                pred = pred_0;
                c = c_1;
            }
            goto jumplbl1;
        }
    }
}

bool none_Q(T)(bool delegate(T) pred, T[] c) {
    return not(any_Q(pred, c));
}

bool includes_Q(T)(T[] c, T e) {
    return any_Q(delegate bool(T t1) { return eql_Q(t1, e); }, c);
}

bool includes_Q(T)(T[] c, T[] other) {
jumplbl1:
    auto _rest = c;
jumplbl2:
    if (lt_Q(size(_rest), size(other))) {
        return false;
    } else {
        if (starts_with_Q(_rest, other)) {
            return true;
        } else {
            {
                auto _rest_0 = rest(_rest);
                _rest = _rest_0;
            }
            goto jumplbl2;
        }
    }
}

bool in_Q(T)(T[] c, T e) {
    return includes_Q(c, e);
}

bool in_Q(T)(T[] c, T[] other) {
    return includes_Q(c, other);
}

bool contains_Q(T)(T[] c, T e) {
    return includes_Q(c, e);
}

bool contains_Q(T)(T[] c, T[] other) {
    return includes_Q(c, other);
}

auto map_into(T)(T delegate(T) func, T[] c, T[] output) {
jumplbl1:
    if (empty_Q(c)) {
        return output;
    } else {
        {
            auto func_0 = func;
            auto c_1 = rest(c);
            auto output_2 = append(output, func(first(c)));
            func = func_0;
            c = c_1;
            output = output_2;
        }
        goto jumplbl1;
    }
}

auto map(T)(T delegate(T) func, T[] c) {
    return map_into(func, c, cleared(c));
}

auto map_E(T)(T delegate(T) func, T[] c) {
jumplbl1:
    auto keys = keys(c);
jumplbl2:
    if (empty_Q(keys)) {
        return c;
    } else {
        {
            assoc_E(c, first(keys), func(get(c, first(keys))));
            {
                auto keys_0 = rest(keys);
                keys = keys_0;
            }
            goto jumplbl2;
        }
    }
}

auto map_entries_into(T)(T delegate(K, T) func, T[] c, T[] output) {
    return append(output, func(first(keys(c)), first(keys(c))));
}

auto map_entries(T)(T delegate(K, T) func, T[] c) {
    return map_entries_into(func, c, cleared(c));
}

auto map_entries_E(T)(T delegate(K, T) func, T[] c) {
jumplbl1:
    auto keys = keys(c);
jumplbl2:
    if (empty_Q(keys)) {
        return c;
    } else {
        {
            assoc_E(c, first(keys), func(first(keys), get(c, first(keys))));
            {
                auto keys_0 = rest(keys);
                keys = keys_0;
            }
            goto jumplbl2;
        }
    }
}

string join(T)(T[] c) {
    return reduce(delegate string(T e, string s) { return append(s, str(e)); }, c, "");
}

private auto uniq_acc(T)(T[] c, T[] output) {
jumplbl1:
    if (empty_Q(c)) {
        return output;
    } else {
        if (gt_Q(index_of(output, first(c)), -1)) {
            {
                auto c_0 = rest(c);
                auto output_1 = output;
                c = c_0;
                output = output_1;
            }
            goto jumplbl1;
        } else {
            {
                auto c_0 = rest(c);
                auto output_1 = append_E(output, first(c));
                c = c_0;
                output = output_1;
            }
            goto jumplbl1;
        }
    }
}

T[] uniq(T)(T[] c) {
    {
        T[] output = [];
        return uniq_acc(c, output);
    }
}

bool uniq_Q(T)(T[] c) {
    return eql_Q(size(c), size(uniq(c)));
}

private auto isort_acc(T)(T[] coll, T[] acc) {
    if (empty_Q(coll)) {
        return acc;
    } else {
        return isort_acc(rest(coll), isort_insert(first(coll), acc));
    }
}

private auto isort_insert(T)(T elem, T[] coll) {
    if (empty_Q(coll)) {
        return [elem];
    } else {
        if (lt_Q(elem, first(coll))) {
            return prepend(elem, coll);
        } else {
            return prepend(first(coll), isort_insert(elem, rest(coll)));
        }
    }
}

auto insertionsort(T)(T[] coll) {
    {
        T[] acc = [];
        return isort_acc(coll, acc);
    }
}

private auto shuffle_sub(T)(T[] coll, T[] target, Random rand) {
jumplbl1:
    if (empty_Q(coll)) {
        return target;
    } else {
        {
            auto v = first(coll);
            auto j = mod(ulong_value(rand), inc(size(target)));
            if (ge_Q(j, size(target))) {
                {
                    auto coll_0 = rest(coll);
                    auto target_1 = append_E(target, v);
                    auto rand_2 = random(rand);
                    coll = coll_0;
                    target = target_1;
                    rand = rand_2;
                }
                goto jumplbl1;
            } else {
                {
                    auto coll_0 = rest(coll);
                    auto target_1 = assoc_E(append_E(target, get(target, j)), j, v);
                    auto rand_2 = random(rand);
                    coll = coll_0;
                    target = target_1;
                    rand = rand_2;
                }
                goto jumplbl1;
            }
        }
    }
}

auto shuffle(T)(T[] coll, Random rand) {
    {
        T[] target = [];
        return shuffle_sub(coll, target, rand);
    }
}

auto shuffle(T)(T[] coll) {
    return shuffle(coll, random(default_seed));
}

T sum(T)(T[] seq) {
    return reduce(delegate T(T l0, T l1) { return plus(l0, l1); }, seq, 0);
}

T min(T)(T[] coll) {
    if (eql_Q(size(coll), 0)) {
        return T.init;
    } else {
        if (eql_Q(size(coll), 1)) {
            return first(coll);
        } else {
            T[] c = rest(coll);
            T res = first(coll);
        jumplbl1:
            if (empty_Q(c)) {
                return res;
            } else {
                if (lt_Q(first(c), res)) {
                    {
                        auto c_0 = rest(c);
                        auto res_1 = first(c);
                        c = c_0;
                        res = res_1;
                    }
                    goto jumplbl1;
                } else {
                    {
                        auto c_0 = rest(c);
                        auto res_1 = res;
                        c = c_0;
                        res = res_1;
                    }
                    goto jumplbl1;
                }
            }
        }
    }
}

T max(T)(T[] coll) {
    if (eql_Q(size(coll), 0)) {
        return T.init;
    } else {
        if (eql_Q(size(coll), 1)) {
            return first(coll);
        } else {
            T[] c = rest(coll);
            T res = first(coll);
        jumplbl1:
            if (empty_Q(c)) {
                return res;
            } else {
                if (gt_Q(first(c), res)) {
                    {
                        auto c_0 = rest(c);
                        auto res_1 = first(c);
                        c = c_0;
                        res = res_1;
                    }
                    goto jumplbl1;
                } else {
                    {
                        auto c_0 = rest(c);
                        auto res_1 = res;
                        c = c_0;
                        res = res_1;
                    }
                    goto jumplbl1;
                }
            }
        }
    }
}

T fib(T)(T _n) {
jumplbl1:
    auto n = _n;
    auto a = 1;
    auto b = 0;
jumplbl2:
    if (eql_Q(n, 0)) {
        return b;
    } else {
        {
            auto n_0 = dec(n);
            auto a_1 = plus(a, b);
            auto b_2 = a;
            n = n_0;
            a = a_1;
            b = b_2;
        }
        goto jumplbl2;
    }
}

ulong[] divisors(ulong l) {
jumplbl1:
    ulong[] res = [];
    auto n = shift_right(l, 1L);
jumplbl2:
    if (eql_Q(n, 0)) {
        return res;
    } else {
        if (eql_Q(mod(l, n), 0)) {
            {
                auto res_0 = append(res, n);
                auto n_1 = dec(n);
                res = res_0;
                n = n_1;
            }
            goto jumplbl2;
        } else {
            {
                auto res_0 = res;
                auto n_1 = dec(n);
                res = res_0;
                n = n_1;
            }
            goto jumplbl2;
        }
    }
}

ulong sum_of_divisors(ulong l) {
jumplbl1:
    ulong res = 0;
    auto n = div(l, 2);
jumplbl2:
    if (eql_Q(n, 0)) {
        return res;
    } else {
        if (eql_Q(mod(l, n), 0)) {
            {
                auto res_0 = plus(res, n);
                auto n_1 = dec(n);
                res = res_0;
                n = n_1;
            }
            goto jumplbl2;
        } else {
            {
                auto res_0 = res;
                auto n_1 = dec(n);
                res = res_0;
                n = n_1;
            }
            goto jumplbl2;
        }
    }
}

double approx_euler(long l) {
    return div(1.0, fib(l));
}

T limit(T)(T val, T max) {
    return if2(gt_Q(val, max), max, val);
}

T limit(T)(T val, T min, T max) {
    return if2(gt_Q(val, max), max, if2(lt_Q(val, min), min, val));
}

import std.bitmanip;
import core.bitop;

BitArray bits_of(T)(T v) {
    {
        void[] vs = [v];
        return BitArray(vs, v.sizeof);
    }
}

BitArray bits_of(void[] vs, size_t bitnum) {
    return BitArray(vs, bitnum);
}

size_t word_count(BitArray ba) {
    return ba.dim();
}

size_t size(BitArray ba) {
    return ba.length();
}

bool get(BitArray ba, size_t i) {
    return ba[i];
}

BitArray bit_array_copy(BitArray bits) {
    return bits.dup();
}

BitArray flip_bit_E(BitArray bits, size_t idx) {
    bits.flip(idx);
    return bits;
}

BitArray flip_all_E(BitArray bits) {
    bits.flip();
    return bits;
}

BitArray reverse_bits_E(BitArray bits) {
    bits.reverse();
    return bits;
}

BitArray set_bit_E(BitArray bits, size_t idx) {
    bits[idx] = true;
    return bits;
}

BitArray unset_bit_E(BitArray bits, size_t idx) {
    bits[idx] = false;
    return bits;
}

BitArray flip_bit(BitArray bits, size_t idx) {
    return flip_bit_E(bits.dup, idx);
}

BitArray flip_all(BitArray bits) {
    return flip_all_E(bits.dup);
}

BitArray reverse_bits(BitArray bits) {
    return reverse_bits_E(bits.dup);
}

BitArray set_bit(BitArray bits, size_t idx) {
    return set_bit_E(bits.dup, idx);
}

BitArray unset_bit(BitArray bits, size_t idx) {
    return unset_bit_E(bits.dup, idx);
}

bool bit_Q(BitArray bits, size_t idx) {
    return get(bits, idx);
}

T rotate_l(T)(T v, uint count) {
    return rol(v, count);
}

T rotate_r(T)(T v, uint count) {
    return ror(v, count);
}

int popcount(uint i) {
    return popcnt(i);
}

int popcount(ulong i) {
    return popcnt(i);
}

struct Random {
    ulong value;
    ulong seed;
    ulong internal_val;
    alias value this;
    this(ulong _value, ulong _seed, ulong _internal_val) {
        value = _value;
        seed = _seed;
        internal_val = _internal_val;
    }

    Random with_value(ulong value) {
        return Random(value, seed, internal_val);
    }

    Random with_seed(ulong seed) {
        return Random(value, seed, internal_val);
    }

    Random with_internal_val(ulong internal_val) {
        return Random(value, seed, internal_val);
    }

    Random clone() {
        return Random(value, seed, internal_val);
    }
}

ulong default_seed = 8678280846964778612;

Random rseed(ulong seed) {
    return Random(inc(seed), seed, inc(seed));
}

Random random(ulong seed) {
    {
        auto seed1 = bit_xor(seed, shift_right(seed, 12));
        auto seed2 = bit_xor(seed1, shift_left(seed1, 25));
        auto seed3 = bit_xor(seed2, shift_right(seed2, 27));
        auto res = bit_xor(seed3, 0x2545F4914F6CDD1D);
        return Random(res, seed, res);
    }
}

Random random(Random r) {
    {
        auto nr = random(r.seed);
        return nr.with_seed(r.internal_val);
    }
}

Random random(Random r, ulong max) {
    {
        auto r2 = random(r);
        return if2(eql_Q(max, 0), r2.with_value(0), r2.with_value(mod(r2.value, max)));
    }
}

Random random(Random r, ulong min, ulong max) {
    {
        auto r2 = random(r, sub(max, min));
        return r2.with_value(plus(r2.value, min));
    }
}

ulong ulong_value(Random r) {
    return r.value;
}

long long_value(Random r) {
    return cast(long)(r.value);
}

uint uint_value(Random r) {
    return cast(uint)(r.value);
}

int int_value(Random r) {
    return cast(int)(r.value);
}

double double_value(Random r) {
    return cast(double)(r.value);
}

string to_s(T)(T e) {
    return to!string(e);
}

bool canConvert(toType, fromType)(fromType e) {
    import std.conv;

    try {
        to!toType(e);
        return true;
    } catch (ConvException ce) {
        return false;
    }
}

bool to_int_valid_Q(T)(T e) {
    return canConvert!int(e);
}

bool to_uint_valid_Q(T)(T e) {
    return canConvert!uint(e);
}

bool to_long_valid_Q(T)(T e) {
    return canConvert!long(e);
}

bool to_ulong_valid_Q(T)(T e) {
    return canConvert!ulong(e);
}

bool to_float_valid_Q(T)(T e) {
    return canConvert!float(e);
}

bool to_double_valid_Q(T)(T e) {
    return canConvert!double(e);
}

string str(T)(T obj) {
    return to!string(obj);
}

void print_E(T)(T text) {
    write(text);
}

void println_E(T)(T text) {
    writeln(text);
}

void error_E(T)(T text) {
    write(stderr, text);
}

void errorln_E(T)(T text) {
    writeln(stderr, text);
}

string readln_E() {
    return stdin.readln;
}
