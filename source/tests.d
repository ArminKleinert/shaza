module tests;

import stdlib;
import associative;
import std.functional;

private string typestr(int i) {
    return "int";
}

private string typestr(uint i) {
    return "uint";
}

private string typestr(long i) {
    return "long";
}

private string typestr(ulong i) {
    return "ulong";
}

private string typestr(bool i) {
    return "bool";
}

private string typestr(float i) {
    return "float";
}

private string typestr(double i) {
    return "double";
}

private string typestr(string i) {
    return "string";
}

bool test_defaults() {
    return and(eql_Q(default_int, 0), eql_Q(default_uint, 0),
            eql_Q(default_long, 0), eql_Q(default_ulong, 0), eql_Q(default_bool, false),
            eql_Q(default_float, 0.0), eql_Q(default_double, 0.0), eql_Q(default_string, ""));
}

bool test_default_types() {
    return and(eql_Q(typestr(default_int), "int"), eql_Q(typestr(default_uint),
            "uint"), eql_Q(typestr(default_long), "long"), eql_Q(typestr(default_ulong),
            "ulong"), eql_Q(typestr(default_bool), "bool"), eql_Q(typestr(default_float),
            "float"), eql_Q(typestr(default_double), "double"),
            eql_Q(typestr(default_string), "string"));
}

bool test_addition() {
    return and(eql_Q(plus(default_int, 15), 15), eql_Q(plus(default_uint, 15),
            15), eql_Q(plus(default_long, 15), 15), eql_Q(plus(default_ulong,
            15), 15), eql_Q(plus(default_float, 15), 15), eql_Q(plus(default_double, 15), 15));
}

bool test_addition_2() {
    return and(eql_Q(plus(default_int, 0), 0), eql_Q(plus(default_uint, 0), 0),
            eql_Q(plus(default_long, 0), 0), eql_Q(plus(default_ulong, 0), 0),
            eql_Q(plus(default_float, 0), 0), eql_Q(plus(default_double, 0), 0));
}

bool test_addition_3() {
    return eql_Q(plus(1000, 111), plus(1000, 111));
}

bool test_addition_4() {
    return eql_Q(plus(1000, 111), plus(111, 1000));
}

bool test_addition_5() {
    return and(eql_Q(plus(15, 15, 15, 15), 60), eql_Q(plus(15, 15, 15, -15),
            30), eql_Q(plus(15, 15, 15, -15, -15), 15));
}

bool test_addition_types() {
    return and(eql_Q(typestr(plus(default_int, 0)), "int"),
            eql_Q(typestr(plus(default_uint, 0)), "uint"), eql_Q(typestr(plus(default_long,
                0)), "long"), eql_Q(typestr(plus(default_ulong, 0)), "ulong"),
            eql_Q(typestr(plus(default_float, 0)), "float"),
            eql_Q(typestr(plus(default_double, 0)), "double"));
}

bool test_subtraction() {
    return and(eql_Q(sub(default_int, 15), -15), eql_Q(sub(default_long, 15),
            -15), eql_Q(sub(default_float, 15), -15), eql_Q(sub(default_double, 15), -15));
}

bool test_subtraction_2() {
    return and(eql_Q(sub(default_int, 0), 0), eql_Q(sub(default_uint, 0), 0),
            eql_Q(sub(default_long, 0), 0), eql_Q(sub(default_ulong, 0), 0),
            eql_Q(sub(default_float, 0), 0), eql_Q(sub(default_double, 0), 0));
}

bool test_subtraction_3() {
    return eql_Q(sub(1000, 111), sub(1000, 111));
}

bool test_subtraction_4() {
    return and(eql_Q(sub(15, 15, 15, 15), -30), eql_Q(sub(15, 15, 15, -15),
            0), eql_Q(sub(15, 15, 15, -15, -15), 15));
}

bool test_subtraction_types() {
    return and(eql_Q(typestr(sub(default_int, 0)), "int"),
            eql_Q(typestr(sub(default_uint, 0)), "uint"), eql_Q(typestr(sub(default_long,
                0)), "long"), eql_Q(typestr(sub(default_ulong, 0)), "ulong"),
            eql_Q(typestr(sub(default_float, 0)), "float"),
            eql_Q(typestr(sub(default_double, 0)), "double"));
}

bool test_multiplication() {
    return and(eql_Q(mul(default_int, 15), 0), eql_Q(mul(default_uint, 15), 0),
            eql_Q(mul(default_long, 15), 0), eql_Q(mul(default_ulong, 15), 0),
            eql_Q(mul(default_float, 15), 0), eql_Q(mul(default_double, 15), 0));
}

bool test_multiplication_2() {
    return and(eql_Q(mul(plus(1, default_int), 15), 15), eql_Q(mul(plus(1,
            default_uint), 15), 15), eql_Q(mul(plus(1, default_long), 15), 15),
            eql_Q(mul(plus(1, default_ulong), 15), 15), eql_Q(mul(plus(1,
                default_float), 15), 15), eql_Q(mul(plus(1, default_double), 15), 15));
}

bool test_multiplication_3() {
    return eql_Q(mul(1000, 111), mul(1000, 111));
}

bool test_multiplication_4() {
    return eql_Q(mul(1000, 111), mul(111, 1000));
}

bool test_multiplication_5() {
    return and(eql_Q(mul(2, 2, 2, 2), 16), eql_Q(mul(2, 2, 2, -2), -16),
            eql_Q(mul(2, 2, 2, -2, -2), 32));
}

bool test_multiplication_types() {
    return and(eql_Q(typestr(mul(default_int, 0)), "int"),
            eql_Q(typestr(mul(default_uint, 0)), "uint"), eql_Q(typestr(mul(default_long,
                0)), "long"), eql_Q(typestr(mul(default_ulong, 0)), "ulong"),
            eql_Q(typestr(mul(default_float, 0)), "float"),
            eql_Q(typestr(mul(default_double, 0)), "double"));
}

bool test_division() {
    return and(eql_Q(div(default_int, 15), 0), eql_Q(div(default_uint, 15), 0),
            eql_Q(div(default_long, 15), 0), eql_Q(div(default_ulong, 15), 0),
            eql_Q(div(default_float, 15), 0), eql_Q(div(default_double, 15), 0));
}

bool test_division_2() {
    return and(eql_Q(div(plus(10, default_int), 2), 5), eql_Q(div(plus(10,
            default_uint), 2), 5), eql_Q(div(plus(10, default_long), 2), 5),
            eql_Q(div(plus(10, default_ulong), 2), 5), eql_Q(div(plus(10,
                default_float), 2), 5), eql_Q(div(plus(10, default_double), 2), 5));
}

bool test_division_3() {
    return eql_Q(div(1000, 111), div(1000, 111));
}

bool test_division_4() {
    return and(eql_Q(div(2, 2), 1), eql_Q(div(15, 15), 1));
}

bool test_division_5() {
    return and(eql_Q(div(2, 2, 2, 2), 0), eql_Q(div(32, 2, 2, 2), 4), eql_Q(div(32, 2, 2, 2, 2), 2));
}

bool test_division_types() {
    return and(eql_Q(typestr(div(default_int, 1)), "int"),
            eql_Q(typestr(div(default_uint, 1)), "uint"), eql_Q(typestr(div(default_long,
                1)), "long"), eql_Q(typestr(div(default_ulong, 1)), "ulong"),
            eql_Q(typestr(div(default_float, 1)), "float"),
            eql_Q(typestr(div(default_double, 1)), "double"));
}

bool test_modulo() {
    return and(eql_Q(mod(default_int, 15), 0), eql_Q(mod(default_uint, 15), 0),
            eql_Q(mod(default_long, 15), 0), eql_Q(mod(default_ulong, 15), 0),
            eql_Q(mod(default_float, 15), 0), eql_Q(mod(default_double, 15), 0));
}

bool test_modulo_2() {
    return and(eql_Q(mod(plus(10, default_int), 2), 0), eql_Q(mod(plus(10,
            default_uint), 2), 0), eql_Q(mod(plus(10, default_long), 2), 0),
            eql_Q(mod(plus(10, default_ulong), 2), 0), eql_Q(mod(plus(10,
                default_float), 2), 0), eql_Q(mod(plus(10, default_double), 2), 0));
}

bool test_modulo_3() {
    return and(eql_Q(mod(plus(10, default_int), 3), 1), eql_Q(mod(plus(10,
            default_uint), 3), 1), eql_Q(mod(plus(10, default_long), 3), 1),
            eql_Q(mod(plus(10, default_ulong), 3), 1), eql_Q(mod(plus(10,
                default_float), 3), 1), eql_Q(mod(plus(10, default_double), 3), 1));
}

bool test_modulo_4() {
    return eql_Q(mod(1000, 111), mod(1000, 111));
}

bool test_modulo_5() {
    return and(eql_Q(mod(40, 30, 7), 3), eql_Q(mod(32, 2, 2, 2), 0), eql_Q(mod(40, 30, 7, 4, 2), 1));
}

bool test_modulo_types() {
    return and(eql_Q(typestr(mod(default_int, 1)), "int"),
            eql_Q(typestr(mod(default_uint, 1)), "uint"), eql_Q(typestr(mod(default_long,
                1)), "long"), eql_Q(typestr(mod(default_ulong, 1)), "ulong"),
            eql_Q(typestr(mod(default_float, 1)), "float"),
            eql_Q(typestr(mod(default_double, 1)), "double"));
}

bool test_inc() {
    return and(eql_Q(inc(default_int), 1), eql_Q(inc(default_uint), 1),
            eql_Q(inc(default_long), 1), eql_Q(inc(default_ulong), 1),
            eql_Q(inc(default_float), 1), eql_Q(inc(default_double), 1));
}

bool test_inc_2() {
    return and(eql_Q(inc(inc(default_int)), 2), eql_Q(inc(inc(default_uint)),
            2), eql_Q(inc(inc(default_long)), 2),
            eql_Q(inc(inc(default_ulong)), 2), eql_Q(inc(inc(default_float)),
                2), eql_Q(inc(inc(default_double)), 2));
}

bool test_inc_3() {
    return eql_Q(inc(1000), inc(1000));
}

bool test_inc_types() {
    return and(eql_Q(typestr(plus(default_int, 0)), "int"),
            eql_Q(typestr(plus(default_uint, 0)), "uint"), eql_Q(typestr(plus(default_long,
                0)), "long"), eql_Q(typestr(plus(default_ulong, 0)), "ulong"),
            eql_Q(typestr(plus(default_float, 0)), "float"),
            eql_Q(typestr(plus(default_double, 0)), "double"));
}

bool test_dec() {
    return and(eql_Q(dec(default_int), -1), eql_Q(dec(default_long), -1),
            eql_Q(dec(default_float), -1), eql_Q(dec(default_double), -1));
}

bool test_dec_2() {
    return and(eql_Q(dec(inc(default_int)), 0), eql_Q(dec(inc(default_uint)),
            0), eql_Q(dec(inc(default_long)), 0),
            eql_Q(dec(inc(default_ulong)), 0), eql_Q(dec(inc(default_float)),
                0), eql_Q(dec(inc(default_double)), 0));
}

bool test_dec_3() {
    return eql_Q(dec(1000), dec(1000));
}

bool test_dec_types() {
    return and(eql_Q(typestr(dec(inc(default_int))), "int"),
            eql_Q(typestr(dec(inc(default_uint))), "uint"), eql_Q(typestr(dec(inc(default_long))),
                "long"), eql_Q(typestr(dec(inc(default_ulong))), "ulong"),
            eql_Q(typestr(dec(inc(default_float))), "float"),
            eql_Q(typestr(dec(inc(default_double))), "double"));
}

bool test_bit_and() {
    return and(eql_Q(bit_and(3, 1), 1), eql_Q(bit_and(3, 3), 3),
            eql_Q(bit_and(3, 0), 0), eql_Q(bit_and(true, 1), 1));
}

bool test_bit_and_2() {
    return eql_Q(bit_and(3, 1), bit_and(3, 1));
}

bool test_bit_or() {
    return and(eql_Q(bit_or(3, 1), 3), eql_Q(bit_or(3, 3), 3), eql_Q(bit_or(3,
            0), 3), eql_Q(bit_or(true, 1), 1));
}

bool test_bit_or_2() {
    return eql_Q(bit_or(3, 1), bit_or(3, 1));
}

bool test_bit_xor() {
    return and(eql_Q(bit_xor(3, 1), 2), eql_Q(bit_xor(3, 3), 0),
            eql_Q(bit_xor(3, 0), 3), eql_Q(bit_xor(true, 1), 0));
}

bool test_bit_xor_2() {
    return eql_Q(bit_xor(33, 3), bit_xor(33, 3));
}

bool test_bit_neg() {
    return true;
}

bool test_bit_shl() {
    return and(eql_Q(shift_left(3, 1), 6), eql_Q(shift_left(0, 3), 0), eql_Q(shift_left(3, 0), 3));
}

bool test_bit_shl_2() {
    return eql_Q(shift_left(33, 1), shift_left(33, 1));
}

bool test_bit_shr() {
    return and(eql_Q(shift_right(6, 1), 3), eql_Q(shift_right(0, 3), 0),
            eql_Q(shift_right(3, 0), 3));
}

bool test_bit_shr_2() {
    return eql_Q(shift_right(33, 1), shift_right(33, 1));
}

bool test_equals() {
    return and(eql_Q(3, 3), eql_Q(3000, 3000), eql_Q("abc", "abc"), eql_Q(true,
            true), eql_Q(false, false), eql_Q([], []), eql_Q(3.0, 3.0));
}

bool test_equals_2() {
    return and(not(eql_Q(3, 3.5)), not(eql_Q(1, 2)), not(eql_Q("abc", "def")),
            not(eql_Q(true, false)), not(eql_Q(false, true)), not(eql_Q(3.0, 3.1)));
}

bool test_not_equals() {
    return and(not(not_eql_Q(3, 3)), not(not_eql_Q(3000, 3000)),
            not(not_eql_Q("abc", "abc")), not(not_eql_Q(true, true)),
            not(not_eql_Q(false, false)), not(not_eql_Q([], [])), not(not_eql_Q(3.0, 3.0)));
}

bool test_not_equals_2() {
    return and(not_eql_Q(3, 3.5), not_eql_Q(1, 2), not_eql_Q("abc", "def"),
            not_eql_Q(true, false), not_eql_Q(false, true), not_eql_Q(3.0, 3.1));
}

bool test_not_equals_3() {
    return and(not_eql_Q(3, 3.5), not_eql_Q(1, 2), not_eql_Q("abc", "def"),
            not_eql_Q(true, false), not_eql_Q(false, true), not_eql_Q(3.0, 3.1));
}

bool test_comparisons() {
    return and(lt_Q(0, 3), gt_Q(3, 0), le_Q(0, 3), le_Q(3, 3), eql_Q(0, 0),
            ge_Q(3, 0), ge_Q(3, 3), pos_Q(0), pos_Q(1), not(pos_Q(-1)),
            neg_Q(-1), not(neg_Q(0)), eql_Q(compare(15, 15), 0),
            eql_Q(compare(15, 0), 1), eql_Q(compare(0, 15), -1));
}

bool test_comparisons_2() {
    return and(lt_Q(0.5, 3.5), gt_Q(3.5, 0.5), le_Q(0.5, 3.5), le_Q(3.5, 3.5),
            eql_Q(0.5, 0.5), ge_Q(3.5, 0.5), ge_Q(3.5, 3.5), pos_Q(0.0),
            pos_Q(1.5), not(pos_Q(-1.5)), neg_Q(-1.5), not(neg_Q(0.0)),
            eql_Q(compare(15.5, 15.5), 0), eql_Q(compare(15.5, 0.5), 1),
            eql_Q(compare(0.5, 15.5), -1));
}

bool test_comparisons_3() {
    return and(lt_Q("", "a"), gt_Q("a", ""), le_Q("", "a"), le_Q("", ""),
            eql_Q("", ""), ge_Q("a", ""), ge_Q("a", "a"), eql_Q(compare("a",
                "a"), 0), eql_Q(compare("a", ""), 1), eql_Q(compare("", "a"), -1));
}

bool test_bool_not() {
    return and(not(not(true)), not(false), not(0));
}

bool test_bool_and() {
    return and(and(true, true), not(and(true, false)), not(and(false, true)),
            not(and(false, false)), and(1, 1), not(and(1, 0)), not(and(0,
                1)), not(and(0, 0)), and(true, true, true, true), not(and(true,
                false, true, true)), not(and(false, true, true, true)),
            not(and(false, false, false, false)));
}

bool test_bool_nand() {
    return and(not(nand(true, true)), nand(true, false), nand(false, true),
            nand(false, false), not(nand(1, 1)), nand(1, 0), nand(0, 1),
            nand(0, 0), not(nand(true, true, true, true)), nand(true, false,
                true, true), nand(false, true, true, true), nand(false, false, false, false));
}

bool test_bool_or() {
    return and(or(true, true), or(true, false), or(false, true),
            not(or(false, false)), or(1, 1), or(1, 0), or(0, 1), not(or(0,
                0)), or(true, true, true, true, true), or(true, true, true,
                true, false), or(false, true, true, true, true), not(or(false,
                false, false, false)));
}

bool test_bool_nor() {
    return and(not(nor(true, true)), not(nor(true, false)), not(nor(false,
            true)), nor(false, false), not(nor(1, 1)), not(nor(1, 0)),
            not(nor(0, 1)), nor(0, 0), not(nor(true, true, true, true,
                true)), not(nor(true, true, true, true, false)), not(nor(false,
                true, true, true, true)), nor(false, false, false, false));
}

bool test_bool_xor() {
    return and(not(xor(true, true)), xor(true, false), xor(false, true),
            not(xor(false, false)), not(xor(1, 1)), xor(1, 0), xor(0, 1), not(xor(0, 0)));
}

bool test_size() {
    return and(eql_Q(size([]), 0), eql_Q(size([1, 2, 3]), 3), eql_Q(size(""),
            0), eql_Q(size("111"), 3));
}

bool test_values() {
    {
        auto v = [1, 2, 3];
        auto v2 = values(v);
        auto s = "123";
        auto s2 = values(s);
        return and(eql_Q(v, v2), eql_Q(s, s2));
    }
}

bool test_append() {
    {
        auto v0 = [1, 2, 3];
        auto v1 = [4, 5, 6];
        auto v2 = append(v0, v1);
        auto s0 = "123";
        auto s1 = "456";
        auto s2 = append(s0, s1);
        return and(eql_Q(v0, [1, 2, 3]), eql_Q(v1, [4, 5, 6]), eql_Q(v2, [
                    1, 2, 3, 4, 5, 6
                ]), eql_Q(s0, "123"), eql_Q(s1, "456"), eql_Q(s2, "123456"));
    }
}

bool test_append_1() {
    {
        auto v0 = [1, 2, 3];
        auto v1 = append(v0, 4);
        auto s0 = "123";
        auto s1 = append(s0, '4');
        return and(eql_Q(v0, [1, 2, 3]), eql_Q(v1, [1, 2, 3, 4]), eql_Q(s0,
                "123"), eql_Q(s1, "1234"));
    }
}

bool test_append_E() {
    {
        auto v0 = [1, 2, 3];
        auto v1 = append_E(v0, 4);
        auto s0 = "123";
        auto s1 = append_E(s0, '4');
        return and(eql_Q(v0, [1, 2, 3, 4]), eql_Q(s0, "1234"), eql_Q(v1, [
                    1, 2, 3, 4
                ]), eql_Q(s1, "1234"));
    }
}

bool test_append_1_E() {
    {
        auto v0 = [1, 2, 3];
        auto v1 = [4, 5, 6];
        auto v2 = append_E(v0, v1);
        auto s0 = "123";
        auto s1 = "456";
        auto s2 = append_E(s0, s1);
        return and(eql_Q(v2, [1, 2, 3, 4, 5, 6]), eql_Q(v1, [4, 5, 6]),
                eql_Q(s2, "123456"), eql_Q(s1, "456"));
    }
}

bool test_prepend() {
    {
        auto v0 = [1, 2, 3];
        auto v1 = prepend(4, v0);
        auto s0 = "123";
        auto s1 = prepend('4', s0);
        return and(eql_Q(v0, [1, 2, 3]), eql_Q(v1, [4, 1, 2, 3]), eql_Q(s0,
                "123"), eql_Q(s1, "4123"));
    }
}

bool test_coll_clone() {
    {
        auto v0 = [1, 2, 3];
        auto v1 = coll_clone(v0);
        auto s0 = "123";
        auto s1 = coll_clone(s0);
        return and(eql_Q(v0, [1, 2, 3]), eql_Q(v1, [1, 2, 3]), eql_Q(s0, "123"), eql_Q(s1, "123"));
    }
}

bool test_keys() {
    {
        auto coll = [1, 2, 3];
        auto s = "123";
        return and(eql_Q(keys(coll), [0, 1, 2]), eql_Q(keys(s), [0, 1, 2]));
    }
}

bool test_assoc_E() {
    {
        auto coll = [1, 3, 3];
        auto coll1 = [1, 4, 5];
        return and(eql_Q(assoc_E(coll, 1, 2), [1, 2, 3]), eql_Q(coll, [1, 2,
                    3]), eql_Q(assoc_E(coll1, 0, 5), coll1));
    }
}

bool test_assoc() {
    {
        auto coll = [1, 3, 3];
        return and(eql_Q(assoc(coll, 1, 2), [1, 2, 3]), eql_Q(coll, [1, 3, 3]));
    }
}

bool test_slice() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        auto text = "123456";
        return and(eql_Q(coll, slice(coll, 0)), eql_Q(slice(coll, 2),
                slice(coll, 2)), eql_Q(size(slice(coll, 1)), 5), eql_Q(text,
                slice(text, 0)), eql_Q(slice(text, 2), slice(text, 2)),
                eql_Q(size(slice(text, 1)), 5));
    }
}

bool test_slice_1() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        auto text = "123456";
        return and(eql_Q(coll, slice(coll, 0, 0)), eql_Q(slice(coll, 2, 0), [
                    3, 4, 5, 6
                ]), eql_Q(slice(coll, 2, 1), [3, 4, 5]), eql_Q(slice(coll, 2,
                1), slice(coll, 2, 1)), eql_Q(size(slice(coll, 1, 1)), 4),
                eql_Q(text, slice(text, 0, 0)), eql_Q(slice(text, 2, 2),
                    slice(text, 2, 2)), eql_Q(size(slice(text, 1, 1)), 4));
    }
}

bool test_get() {
    {
        auto coll = [1, 2, 3, 4];
        auto text = "1234";
        return and(eql_Q(get(coll, 0), 1), eql_Q(get(coll, 1), 2),
                eql_Q(get(coll, 2), 3), eql_Q(get(text, 0), '1'),
                eql_Q(get(text, 1), '2'), eql_Q(get(text, 2), '3'));
    }
}

private bool is_int_array_Q(int[] a) {
    return true;
}

bool test_cleared() {
    {
        auto coll = [1, 2, 3, 4, 5];
        return and(eql_Q(cleared(coll), []), is_int_array_Q(cleared(coll)),
                eql_Q(append(cleared(coll), coll), coll));
    }
}

bool test_resized() {
    {
        auto coll = [1, 1, 1];
        return and(eql_Q(resized(coll, 0), []), eql_Q(resized(coll, 1), [1]),
                eql_Q(resized(coll, 4), [1, 1, 1, 0]), eql_Q(resized(resized(coll,
                    0), 5), [0, 0, 0, 0, 0]), is_int_array_Q(resized(coll, 8)));
    }
}

bool test_vector() {
    return and(eql_Q(vector(1, 2, 3, 4), [1, 2, 3, 4]),
            is_int_array_Q(vector(1, 2, 3)), eql_Q(size(vector(0, 1, 2, 3, 4,
                5, 6, 7, 8, 9, 10, 11, 12)), 13));
}

bool test_first() {
    {
        auto coll = [1, 2, 3, 4];
        return and(eql_Q(first(coll), 1), eql_Q(first(coll), get(coll, 0)));
    }
}

bool test_second() {
    {
        auto coll = [1, 2, 3, 4];
        return and(eql_Q(second(coll), 2), eql_Q(second(coll), get(coll, 1)));
    }
}

bool test_last() {
    {
        auto coll = [1, 2, 3, 4];
        return eql_Q(last(coll), 4);
    }
}

bool test_rest() {
    return and(eql_Q(rest([1, 2, 3]), [2, 3]), eql_Q(rest([1]), []));
}

bool test_empty() {
    return and(empty_Q([]), not(empty_Q([1])), empty_Q(""));
}

bool test_not_empty() {
    return and(not_empty_Q([1]), not(not_empty_Q([])), not_empty_Q("1"));
}

bool test_key_of() {
    {
        auto coll = [15, 16, 17];
        return and(eql_Q(key_of(coll, 16), 1), eql_Q(key_of(coll, 61), 0),
                eql_Q(key_of(coll, 16, 7), 1), eql_Q(key_of(coll, 61, 7), 7));
    }
}

bool test_key_of1() {
    {
        auto coll = "678";
        return and(eql_Q(key_of(coll, '6'), 0), eql_Q(key_of(coll, '6', 7), 0),
                eql_Q(key_of(coll, '9', 7), 7));
    }
}

bool test_index_of() {
    {
        auto coll = [15, 16, 17];
        return and(eql_Q(index_of(coll, 16), 1), eql_Q(index_of(coll, 61),
                -1), eql_Q(index_of(coll, 16), 1), eql_Q(index_of(coll, 61), -1));
    }
}

bool test_index_of1() {
    {
        auto coll = "678";
        return and(eql_Q(index_of(coll, '6'), 0), eql_Q(index_of(coll, '9'),
                -1), eql_Q(index_of(coll, '6'), 0), eql_Q(index_of(coll, '9'), -1));
    }
}

bool test_starts_with() {
    {
        auto coll = [1, 2, 3, 4];
        return and(starts_with_Q(coll, 1), starts_with_Q(rest(coll), 2),
                starts_with_Q(coll, [1, 2]), not(starts_with_Q(coll, 2)),
                not(starts_with_Q(coll, [1, 2, 3, 4, 5])), starts_with_Q(coll, coll));
    }
}

bool test_ends_with() {
    {
        auto coll = [1, 2, 3, 4];
        return and(ends_with_Q(coll, 4), ends_with_Q(slice(coll, 0, 1), 3),
                ends_with_Q(coll, coll), ends_with_Q(coll, [3, 4]));
    }
}

bool test_reduce() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return eql_Q(reduce(delegate(int i, int j) { return plus(i, j); }, coll, 0), 21);
    }
}

bool test_reduce_1() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return eql_Q(reduce(delegate int(int i, int j) { return plus(i, j); }, coll), 21);
    }
}

bool test_reduce_2() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return eql_Q(reduce(delegate(int i, int j) { return sub(j, i); }, coll), -19);
    }
}

int test_reduce_3_sub(int i, int j) {
    return sub(j, i);
}

bool test_reduce_3() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return eql_Q(reduce((std.functional.toDelegate(&test_reduce_3_sub)), coll), -19);
    }
}

bool test_reduce_4() {
    {
        int[] coll = [1, 2, 3, 4, 5, 6];
        return eql_Q(reduce(delegate string(int i, string s) {
                return append(s, to_s(i));
            }, coll, ""), "123456");
    }
}

bool test_reduce_5() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return eql_Q(reduce(delegate int[][](int i, int[][] res) {
                return append(res, [i]);
            }, coll, []), [[1], [2], [3], [4], [5], [6]]);
    }
}

bool test_filter_odd_helper(int i) {
    return eql_Q(1, mod(i, 2));
}

bool test_filter() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(eql_Q(filter(delegate bool(int i) {
                    return not_eql_Q(0, bit_and(i, 1));
                }, coll), [1, 3, 5]), eql_Q(filter(delegate bool(int i) {
                    return lt_Q(i, 4);
                }, coll), [1, 2, 3]),
                eql_Q(filter((std.functional.toDelegate(&test_filter_odd_helper)),
                    coll), [1, 3, 5]));
    }
}

bool test_remove() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(eql_Q(remove(delegate bool(int i) {
                    return not_eql_Q(0, bit_and(i, 1));
                }, coll), [2, 4, 6]), eql_Q(remove(delegate bool(int i) {
                    return lt_Q(i, 4);
                }, coll), [4, 5, 6]),
                eql_Q(remove((std.functional.toDelegate(&test_filter_odd_helper)),
                    coll), [2, 4, 6]));
    }
}

bool test_any_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(any_Q(delegate bool(int i) { return gt_Q(i, 3); }, coll),
                any_Q(delegate bool(int i) { return gt_Q(i, 0); }, coll),
                not(any_Q(delegate bool(int i) { return gt_Q(i, 6); }, coll)),
                not(any_Q(delegate bool(int i) { return gt_Q(i, 0); }, [])));
    }
}

bool test_all_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(not(all_Q(delegate bool(int i) { return gt_Q(i, 3); }, coll)),
                all_Q(delegate bool(int i) { return gt_Q(i, 0); }, coll),
                not(all_Q(delegate bool(int i) { return gt_Q(i, 6); }, coll)),
                all_Q(delegate bool(int i) { return gt_Q(i, 0); }, []));
    }
}

bool test_none_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(not(none_Q(delegate bool(int i) { return gt_Q(i, 3); }, coll)),
                not(none_Q(delegate bool(int i) { return gt_Q(i, 0); }, coll)),
                none_Q(delegate bool(int i) { return gt_Q(i, 6); }, coll),
                none_Q(delegate bool(int i) { return gt_Q(i, 0); }, []));
    }
}

bool test_includes_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(all_Q(delegate bool(int i) { return includes_Q(coll, i); }, [
                    1, 2, 3, 4, 5, 6
                ]), none_Q(delegate bool(int i) { return includes_Q(coll, i); }, [
                    -1, 0, 7, 10
                ]));
    }
}

bool test_includes_1_Q() {
    {
        int[] coll = [];
        return none_Q(delegate bool(int i) { return includes_Q(coll, i); },
                [-1, 0, 1, 2, 3, 4, 5, 6, 7, 10]);
    }
}

bool test_includes_2_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(all_Q(delegate bool(int[] i) { return includes_Q(coll, i); },
                [[1], [], coll, rest(coll)]), none_Q(delegate bool(int[] i) {
                return includes_Q(coll, i);
            }, [[0], append(coll, 1)]));
    }
}

bool test_in_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(all_Q(delegate bool(int i) { return in_Q(coll, i); }, [
                    1, 2, 3, 4, 5, 6
                ]), none_Q(delegate bool(int i) { return in_Q(coll, i); }, [
                    -1, 0, 7, 10
                ]));
    }
}

bool test_in_1_Q() {
    {
        int[] coll = [];
        return none_Q(delegate bool(int i) { return in_Q(coll, i); }, [
                -1, 0, 1, 2, 3, 4, 5, 6, 7, 10
                ]);
    }
}

bool test_in_2_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(all_Q(delegate bool(int[] i) { return in_Q(coll, i); },
                [[1], [], coll, rest(coll)]), none_Q(delegate bool(int[] i) {
                return in_Q(coll, i);
            }, [[0], append(coll, 1)]));
    }
}

bool test_contains_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(all_Q(delegate bool(int i) { return contains_Q(coll, i); }, [
                    1, 2, 3, 4, 5, 6
                ]), none_Q(delegate bool(int i) { return contains_Q(coll, i); }, [
                    -1, 0, 7, 10
                ]));
    }
}

bool test_contains_1_Q() {
    {
        int[] coll = [];
        return none_Q(delegate bool(int i) { return contains_Q(coll, i); },
                [-1, 0, 1, 2, 3, 4, 5, 6, 7, 10]);
    }
}

bool test_contains_2_Q() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(all_Q(delegate bool(int[] i) { return contains_Q(coll, i); },
                [[1], [], coll, rest(coll)]), none_Q(delegate bool(int[] i) {
                return contains_Q(coll, i);
            }, [[0], append(coll, 1)]));
    }
}

bool test_map() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return eql_Q(map(delegate int(int i) { return inc(i); }, coll), [
                2, 3, 4, 5, 6, 7
                ]);
    }
}

bool test_map_into() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        int[] dest = [];
        return eql_Q(map_into(delegate int(int i) { return inc(i); }, coll, dest),
                [2, 3, 4, 5, 6, 7]);
    }
}

bool test_map_into_1() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        auto dest = [1, 2, 3];
        return eql_Q(map_into(delegate int(int i) { return inc(i); }, coll, dest),
                [1, 2, 3, 2, 3, 4, 5, 6, 7]);
    }
}

bool test_map_E() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        return and(eql_Q(map_E(delegate int(int i) { return inc(i); }, coll), [
                    2, 3, 4, 5, 6, 7
                ]), eql_Q(coll, [2, 3, 4, 5, 6, 7]));
    }
}

bool test_join() {
    {
        int[] empty_int_arr = [];
        return and(eql_Q(join(empty_int_arr), ""), eql_Q(join([1, 2, 3]),
                "123"), eql_Q(join([123]), "123"));
    }
}

bool test_uniq() {
    {
        int[] empty_int_arr = [];
        return and(eql_Q(uniq(empty_int_arr), empty_int_arr), eql_Q(uniq([
                    1, 1, 1
                ]), [1]), eql_Q(uniq([1, 2, 3, 1, 2, 3]), [1, 2, 3]),
                eql_Q(uniq([1, 2, 3, 2, 1, 0]), [1, 2, 3, 0]));
    }
}

bool test_distinct() {
    {
        int[] empty_int_arr = [];
        return and(eql_Q(uniq(empty_int_arr), empty_int_arr), eql_Q(uniq([
                    1, 1, 1
                ]), [1]), eql_Q(uniq([1, 2, 3, 1, 2, 3]), [1, 2, 3]),
                eql_Q(uniq([1, 2, 3, 2, 1, 0]), [1, 2, 3, 0]));
    }
}

bool test_uniq_Q() {
    {
        int[] empty_int_arr = [];
        return and(uniq_Q(empty_int_arr), uniq_Q([1, 2, 3, 4]), uniq_Q([1]),
                not(uniq_Q([1, 2, 3, 2])));
    }
}

bool test_is_distinct_Q() {
    {
        int[] empty_int_arr = [];
        return and(uniq_Q(empty_int_arr), uniq_Q([1, 2, 3, 4]), uniq_Q([1]),
                not(uniq_Q([1, 2, 3, 2])));
    }
}

bool test_is_unique_Q() {
    {
        int[] empty_int_arr = [];
        return and(uniq_Q(empty_int_arr), uniq_Q([1, 2, 3, 4]), uniq_Q([1]),
                not(uniq_Q([1, 2, 3, 2])));
    }
}

bool test_sort() {
    {
        int[] coll = [];
        return and(eql_Q(insertionsort(coll), []), eql_Q(insertionsort(coll),
                insertionsort(coll)));
    }
}

bool test_sort_1() {
    {
        auto coll = [1, 2, 3, 4, 5, 6];
        auto coll_sorted = [1, 2, 3, 4, 5, 6];
        return and(eql_Q(insertionsort(coll), coll_sorted),
                eql_Q(insertionsort(coll), insertionsort(coll)));
    }
}

bool test_sort_2() {
    {
        auto coll = [6, 5, 4, 3, 2, 1];
        auto coll_sorted = [1, 2, 3, 4, 5, 6];
        return and(eql_Q(insertionsort(coll), coll_sorted),
                eql_Q(insertionsort(coll), insertionsort(coll)));
    }
}

bool test_sort_3() {
    {
        auto coll = [3, 4, 6, 3, 2, 1, 8, 9, 10];
        auto coll_sorted = [1, 2, 3, 3, 4, 6, 8, 9, 10];
        return and(eql_Q(insertionsort(coll), coll_sorted),
                eql_Q(insertionsort(coll), insertionsort(coll)));
    }
}

bool test_shuffle() {
    {
        auto coll = [3, 4, 6, 3, 2, 1, 8, 9, 10];
        auto rand = random(default_seed);
        return and(eql_Q(shuffle(cleared(coll), rand), cleared(coll)),
                eql_Q(shuffle([first(coll)], rand), [first(coll)]), not_eql_Q(shuffle(coll,
                    rand), coll), eql_Q(shuffle(coll, rand), shuffle(coll, rand)));
    }
}

bool test_sum() {
    {
        int[] empty_coll = [];
        return and(eql_Q(sum([1, 2, 3]), 6), eql_Q(sum(empty_coll), 0),
                eql_Q(sum([0, 0, 0]), 0), eql_Q(sum([-1, -1, -1, -1]), -4));
    }
}

bool test_min() {
    {
        int[] empty_coll = [];
        return and(eql_Q(min(empty_coll), default_int), eql_Q(min([1]), 1),
                eql_Q(min([1, 2, 3, 4, 5, 6]), 1), eql_Q(min([6, 5, 4, 3, 2, 1]), 1));
    }
}

bool test_max() {
    {
        int[] empty_coll = [];
        return and(eql_Q(max(empty_coll), default_int), eql_Q(max([1]), 1),
                eql_Q(max([1, 2, 3, 4, 5, 6]), 6), eql_Q(max([6, 5, 4, 3, 2, 1]), 6));
    }
}

bool test_limit() {
    return and(eql_Q(limit(0, 0), 0), eql_Q(limit(0, 1), 0), eql_Q(limit(-1,
            0), -1), eql_Q(limit(500, 5), 5), eql_Q(limit(500, 1000), 500));
}

bool test_limit_1() {
    return and(eql_Q(limit(0, 0, 0), 0), eql_Q(limit(0, 0, 1), 0),
            eql_Q(limit(-1, -1, 0), -1), eql_Q(limit(500, 0, 5), 5),
            eql_Q(limit(500, 0, 1000), 500), eql_Q(limit(500, 501, 1000), 501),
            eql_Q(limit(500, -1000, 1000), 500));
}

bool test_divisors() {
    {
        ulong[] temp = [6, 4, 3, 2, 1];
        return and(eql_Q(divisors(12), temp), eql_Q(divisors(0), cleared(temp)));
    }
}

bool test_sum_of_divisors() {
    return and(eql_Q(sum_of_divisors(0), 0), eql_Q(sum_of_divisors(12), 16));
}

bool test_bits_of() {
    return and(eql_Q(bits_of(0), bits_of(0)), eql_Q(size(bits_of(0)), 0),
            eql_Q(size(bits_of(255)), 8));
}

bool test_bits_of_1() {
    {
        byte[] bs = [0];
        auto bitarr = bits_of(bs, 8);
        flip_all_E(bitarr);
        return and(eql_Q(first(bs), 255), eql_Q(bitarr, bits_of(255)));
    }
}

bool test_bit_array_copy() {
    {
        byte[] bs = [0];
        auto bitarr = bit_array_copy(bits_of(bs, 8));
        flip_all_E(bitarr);
        return and(eql_Q(first(bs), 0), eql_Q(bitarr, bits_of(255)));
    }
}

bool test_flip_bit_E() {
    return false;
}

bool test_flip_all_E() {
    return false;
}

bool test_reverse_bits_E() {
    return false;
}

bool test_set_bit_E() {
    return false;
}

bool test_unset_bit_E() {
    return false;
}

bool test_flip_bit() {
    return false;
}

bool test_flip_all() {
    return false;
}

bool test_reverse_bits() {
    return false;
}

bool test_set_bit() {
    return false;
}

bool test_unset_bit() {
    return false;
}

bool test_bit_Q() {
    return false;
}

bool test_rotate_l() {
    return false;
}

bool test_rotate_r() {
    return false;
}

bool test_popcount() {
    return false;
}

bool test_popcount_1() {
    return false;
}

bool test_rseed() {
    {
        auto rand = rseed(0);
        auto rand2 = rseed(1001);
        return and(eql_Q(rand.seed, 0), eql_Q(rand2.seed, 1001));
    }
}

bool test_random() {
    return and(not_eql_Q(long_value(random(0)), 0),
            eql_Q(long_value(random(1)), long_value(random(rseed(1)))),
            eql_Q(long_value(random(default_seed)), long_value(random(default_seed))));
}

bool test_random_1() {
    {
        auto rand = rseed(default_seed);
        return and(eql_Q(ulong_value(random(rand, 0)), 0), le_Q(ulong_value(random(rand, 1)), 1));
    }
}

bool test_random_2() {
    {
        auto rand = rseed(default_seed);
        return and(eql_Q(ulong_value(random(rand, 0, 0)), 0),
                le_Q(ulong_value(random(rand, 0, 1)), 1));
    }
}

bool test_random_3() {
jumplbl1:
    auto rand = random(rseed(2048), 100);
    auto counter = 1000;
jumplbl2:
    if (eql_Q(counter, 0)) {
        return true;
    } else {
        if (ge_Q(ulong_value(rand), 100)) {
            return false;
        } else {
            {
                auto rand_0 = random(rand, 100);
                auto counter_1 = dec(counter);
                rand = rand_0;
                counter = counter_1;
            }
            goto jumplbl2;
        }
    }
}

bool test_random_4() {
jumplbl1:
    auto rand = random(rseed(2048), 50, 100);
    auto counter = 1000;
jumplbl2:
    if (eql_Q(counter, 0)) {
        return true;
    } else {
        if (ge_Q(ulong_value(rand), 100)) {
            return false;
        } else {
            if (lt_Q(ulong_value(rand), 50)) {
                return false;
            } else {
                {
                    auto rand_0 = random(rand, 50, 100);
                    auto counter_1 = dec(counter);
                    rand = rand_0;
                    counter = counter_1;
                }
                goto jumplbl2;
            }
        }
    }
}

import variant;

bool test_variant_0() {
    {
        SzVariant!(int, string) v0 = 1;
        SzVariant!(int, string) v1 = 1;
        return and(eql_Q(v0, v1), eql_Q(v0, 1), eql_Q(v1, 1));
    }
}

alias TestVariant1TestDelegate0 = int delegate();
alias TestVariant1TestDelegate1 = string delegate();
alias TestVariant1TestVariant = SzVariant!(TestVariant1TestDelegate0, TestVariant1TestDelegate1);
bool test_variant_1() {
    {
        TestVariant1TestDelegate0 d0 = delegate int() { return 1; };
        TestVariant1TestVariant v0 = d0;
        TestVariant1TestDelegate1 d1 = delegate string() { return "hi"; };
        TestVariant1TestVariant v1 = d1;
        return and(eql_Q(v0(), 1), eql_Q(v1(), "hi"));
    }
}

bool test_map_empty_Q() {
    {
        auto m = create_map([1, 2], ["", "abc"]);
        int[] empty_ints = [];
        return and(not(map_empty_Q(m)), map_empty_Q(create_map(empty_ints, empty_ints)));
    }
}

bool test_map_get() {
    {
        auto k1 = 1;
        auto k2 = 2;
        auto m1 = create_map([k1, k2], ["", "abc"]);
        auto m2 = create_map(["", "abc"], [k1, k2]);
        return and(eql_Q(map_get(m1, k1), ""), eql_Q(map_get(m1, k2), "abc"),
                eql_Q(map_get(m2, ""), k1), eql_Q(map_get(m2, "abc"), k2));
    }
}

bool test_map_has_key_Q() {
    {
        auto m1 = create_map([1, 2], ["", "abc"]);
        return and(has_key_Q(m1, 1), has_key_Q(m1, 2), not(has_key_Q(m1, 3)),
                not(has_key_Q(m1, 100)));
    }
}

bool test_map_has_key_2_Q() {
    {
        auto m1 = create_map([1, 2], ["", "abc"]);
        return and(and(has_key_Q(m1, 1), includes_Q(m1, 1), contains_Q(m1, 1)),
                nand(has_key_Q(m1, 3), includes_Q(m1, 3), contains_Q(m1, 3)));
    }
}

void main1() {
    println_E(append("test-defaults      ", to_s(test_defaults())));
    println_E(append("test-default-types ", to_s(test_default_types())));
    println_E("");
    println_E(append("test-add           ", to_s(test_addition())));
    println_E(append("test-add-2         ", to_s(test_addition_2())));
    println_E(append("test-add-3         ", to_s(test_addition_3())));
    println_E(append("test-add-4         ", to_s(test_addition_4())));
    println_E(append("test-add-5         ", to_s(test_addition_5())));
    println_E(append("test-add-types     ", to_s(test_addition_types())));
    println_E(append("test-sub           ", to_s(test_subtraction())));
    println_E(append("test-sub-2         ", to_s(test_subtraction_2())));
    println_E(append("test-sub-3         ", to_s(test_subtraction_3())));
    println_E(append("test-sub-4         ", to_s(test_subtraction_4())));
    println_E(append("test-sub-types     ", to_s(test_subtraction_types())));
    println_E(append("test-mul           ", to_s(test_multiplication())));
    println_E(append("test-mul-2         ", to_s(test_multiplication_2())));
    println_E(append("test-mul-3         ", to_s(test_multiplication_3())));
    println_E(append("test-mul-4         ", to_s(test_multiplication_4())));
    println_E(append("test-mul-5         ", to_s(test_multiplication_5())));
    println_E(append("test-mul-types     ", to_s(test_multiplication_types())));
    println_E(append("test-div           ", to_s(test_division())));
    println_E(append("test-div-2         ", to_s(test_division_2())));
    println_E(append("test-div-3         ", to_s(test_division_3())));
    println_E(append("test-div-4         ", to_s(test_division_4())));
    println_E(append("test-div-5         ", to_s(test_division_5())));
    println_E(append("test-div-types     ", to_s(test_division_types())));
    println_E(append("test-mod           ", to_s(test_modulo())));
    println_E(append("test-mod-2         ", to_s(test_modulo_2())));
    println_E(append("test-mod-3         ", to_s(test_modulo_3())));
    println_E(append("test-mod-4         ", to_s(test_modulo_4())));
    println_E(append("test-mod-5         ", to_s(test_modulo_5())));
    println_E(append("test-mod-types     ", to_s(test_modulo_types())));
    println_E("");
    println_E(append("test-inc           ", to_s(test_inc())));
    println_E(append("test-inc-2         ", to_s(test_inc_2())));
    println_E(append("test-inc-3         ", to_s(test_inc_3())));
    println_E(append("test-inc-types     ", to_s(test_inc_types())));
    println_E(append("test-dec           ", to_s(test_dec())));
    println_E(append("test-dec-2         ", to_s(test_dec_2())));
    println_E(append("test-dec-3         ", to_s(test_dec_3())));
    println_E(append("test-dec-types     ", to_s(test_dec_types())));
    println_E("");
    println_E(append("test-bit-and       ", to_s(test_bit_and())));
    println_E(append("test-bit-and-2     ", to_s(test_bit_and_2())));
    println_E(append("test-bit-or        ", to_s(test_bit_or())));
    println_E(append("test-bit-and-2     ", to_s(test_bit_and_2())));
    println_E(append("test-bit-xor       ", to_s(test_bit_xor())));
    println_E(append("test-bit-xor-2     ", to_s(test_bit_xor_2())));
    println_E("");
    println_E(append("test-bit-neg       ", to_s(test_bit_neg())));
    println_E(append("test-bit-shl       ", to_s(test_bit_shl())));
    println_E(append("test-bit-shl-2     ", to_s(test_bit_shl_2())));
    println_E(append("test-bit-shr       ", to_s(test_bit_shr())));
    println_E(append("test-bit-shr-2     ", to_s(test_bit_shr_2())));
    println_E("");
    println_E(append("test-equals        ", to_s(test_equals())));
    println_E(append("test-equals-2      ", to_s(test_equals_2())));
    println_E(append("test-not-equals    ", to_s(test_not_equals())));
    println_E(append("test-not-equals-2  ", to_s(test_not_equals_2())));
    println_E("");
    println_E(append("test-comparisons   ", to_s(test_comparisons())));
    println_E(append("test-comparisons-2 ", to_s(test_comparisons_2())));
    println_E(append("test-comparisons-3 ", to_s(test_comparisons_3())));
    println_E("");
    println_E(append("test-bool-not      ", to_s(test_bool_not())));
    println_E(append("test-bool-and      ", to_s(test_bool_and())));
    println_E(append("test-bool-nand     ", to_s(test_bool_nand())));
    println_E(append("test-bool-or       ", to_s(test_bool_or())));
    println_E(append("test-bool-nor      ", to_s(test_bool_nor())));
    println_E(append("test-bool-xor      ", to_s(test_bool_xor())));
    println_E("");
    println_E(append("test-size          ", to_s(test_size())));
    println_E(append("test-values        ", to_s(test_values())));
    println_E(append("test-append        ", to_s(test_append())));
    println_E(append("test-append-1      ", to_s(test_append_1())));
    println_E(append("test-append-!      ", to_s(test_append_E())));
    println_E(append("test-append-!-1    ", to_s(test_append_1_E())));
    println_E(append("test-prepend       ", to_s(test_prepend())));
    println_E(append("test-coll-clone    ", to_s(test_coll_clone())));
    println_E("");
    println_E(append("test-keys          ", to_s(test_keys())));
    println_E(append("test-assoc!        ", to_s(test_assoc_E())));
    println_E(append("test-assoc         ", to_s(test_assoc())));
    println_E(append("test-slice         ", to_s(test_slice())));
    println_E(append("test-slice-1       ", to_s(test_slice_1())));
    println_E(append("test-get           ", to_s(test_get())));
    println_E(append("test-cleared       ", to_s(test_cleared())));
    println_E(append("test-resized       ", to_s(test_resized())));
    println_E(append("test-vector        ", to_s(test_vector())));
    println_E("");
    println_E(append("test-first         ", to_s(test_first())));
    println_E(append("test-second        ", to_s(test_second())));
    println_E(append("test-last          ", to_s(test_last())));
    println_E(append("test-rest          ", to_s(test_rest())));
    println_E(append("test-empty         ", to_s(test_empty())));
    println_E(append("test-not-empty     ", to_s(test_not_empty())));
    println_E(append("test-key-of        ", to_s(test_key_of())));
    println_E(append("test-key-of1       ", to_s(test_key_of1())));
    println_E(append("test-index-of      ", to_s(test_index_of())));
    println_E(append("test-index-of1     ", to_s(test_index_of1())));
    println_E("");
    println_E(append("test-starts-with   ", to_s(test_starts_with())));
    println_E(append("test-ends-with     ", to_s(test_ends_with())));
    println_E(append("test-reduce        ", to_s(test_reduce())));
    println_E(append("test-reduce-1      ", to_s(test_reduce_1())));
    println_E(append("test-reduce-2      ", to_s(test_reduce_2())));
    println_E(append("test-reduce-3      ", to_s(test_reduce_3())));
    println_E(append("test-reduce-4      ", to_s(test_reduce_4())));
    println_E(append("test-reduce-5      ", to_s(test_reduce_5())));
    println_E("");
    println_E(append("test-filter        ", to_s(test_filter())));
    println_E(append("test-remove        ", to_s(test_remove())));
    println_E(append("test-any           ", to_s(test_any_Q())));
    println_E(append("test-all           ", to_s(test_all_Q())));
    println_E(append("test-none          ", to_s(test_none_Q())));
    println_E("");
    println_E(append("test-includes?     ", to_s(test_includes_Q())));
    println_E(append("test-includes-1?   ", to_s(test_includes_1_Q())));
    println_E(append("test-includes-2?   ", to_s(test_includes_2_Q())));
    println_E(append("test-in?           ", to_s(test_includes_Q())));
    println_E(append("test-in-1?         ", to_s(test_includes_1_Q())));
    println_E(append("test-in-2?         ", to_s(test_includes_2_Q())));
    println_E(append("test-contains?     ", to_s(test_includes_Q())));
    println_E(append("test-contains-1?   ", to_s(test_includes_1_Q())));
    println_E(append("test-contains-2?   ", to_s(test_includes_2_Q())));
    println_E("");
    println_E(append("test-map           ", to_s(test_map())));
    println_E(append("test-map-into      ", to_s(test_map_into())));
    println_E(append("test-map-into-1    ", to_s(test_map_into_1())));
    println_E(append("test-map!          ", to_s(test_map_E())));
    println_E("");
    println_E(append("test-join          ", to_s(test_join())));
    println_E("");
    println_E(append("test-uniq          ", to_s(test_uniq())));
    println_E(append("test-distinct      ", to_s(test_distinct())));
    println_E(append("test-uniq?         ", to_s(test_uniq_Q())));
    println_E(append("test-is-distinct?  ", to_s(test_is_distinct_Q())));
    println_E(append("test-is-unique?    ", to_s(test_is_unique_Q())));
    println_E("");
    println_E(append("test-sort          ", to_s(test_sort())));
    println_E(append("test-sort-1        ", to_s(test_sort_1())));
    println_E(append("test-sort-2        ", to_s(test_sort_2())));
    println_E(append("test-sort-3        ", to_s(test_sort_3())));
    println_E("");
    println_E(append("test-sum           ", to_s(test_sum())));
    println_E(append("test-min           ", to_s(test_min())));
    println_E(append("test-max           ", to_s(test_max())));
    println_E(append("test-divisors      ", to_s(test_divisors())));
    println_E("test-sum-of-divisors");
    println_E(append("                   ", to_s(test_sum_of_divisors())));
    println_E("");
    println_E(append("test-limit         ", to_s(test_limit())));
    println_E(append("test-limit-1       ", to_s(test_limit_1())));
    println_E("");
    println_E(append("test-bits-of       ", to_s(test_bits_of())));
    println_E(append("test-bits-of-1     ", to_s(test_bits_of_1())));
    println_E("test-bit-array-copy");
    println_E(append("                   ", to_s(test_bit_array_copy())));
    println_E("");
    println_E(append("test-flip-bit!     ", to_s(test_flip_bit_E())));
    println_E(append("test-flip-all!     ", to_s(test_flip_all_E())));
    println_E(append("test-reverse-bits! ", to_s(test_reverse_bits_E())));
    println_E(append("test-set-bit!      ", to_s(test_set_bit_E())));
    println_E(append("test-unset-bit!    ", to_s(test_unset_bit_E())));
    println_E(append("test-flip-bit      ", to_s(test_flip_bit())));
    println_E(append("test-flip-all      ", to_s(test_flip_all())));
    println_E(append("test-reverse-bits  ", to_s(test_reverse_bits())));
    println_E(append("test-set-bit       ", to_s(test_set_bit())));
    println_E(append("test-unset-bit     ", to_s(test_unset_bit())));
    println_E(append("test-bit?          ", to_s(test_bit_Q())));
    println_E("");
    println_E(append("test-rotate-l      ", to_s(test_rotate_l())));
    println_E(append("test-rotate-r      ", to_s(test_rotate_r())));
    println_E(append("test-popcount      ", to_s(test_popcount())));
    println_E(append("test-popcount-1    ", to_s(test_popcount_1())));
    println_E("");
    println_E(append("test-rseed         ", to_s(test_rseed())));
    println_E(append("test-random        ", to_s(test_random())));
    println_E(append("test-random-1      ", to_s(test_random_1())));
    println_E(append("test-random-2      ", to_s(test_random_2())));
    println_E(append("test-random-3      ", to_s(test_random_3())));
    println_E(append("test-random-4      ", to_s(test_random_4())));
    println_E("");
    println_E(append("test-variant-0     ", to_s(test_variant_0())));
    println_E(append("test-variant-1     ", to_s(test_variant_1())));
    println_E("");
    println_E(append("test-map-empty?    ", to_s(test_map_empty_Q())));
    println_E(append("test-map-get       ", to_s(test_map_get())));
    println_E(append("test-map-has-key?  ", to_s(test_map_has_key_Q())));
    println_E("test-map-has-key-2?");
    println_E(append("                   ", to_s(test_map_has_key_2_Q())));
    println_E(append("test-shuffle       ", to_s(test_shuffle())));
}
