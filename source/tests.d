module tests;

import stdlib;
private string typestr(int i){
return "int";
}
private string typestr(uint i){
return "uint";
}
private string typestr(long i){
return "long";
}
private string typestr(ulong i){
return "ulong";
}
private string typestr(bool i){
return "bool";
}
private string typestr(float i){
return "float";
}
private string typestr(double i){
return "double";
}
private string typestr(string i){
return "string";
}

bool test_defaults(){
return and(eql_Q(default_int, 0), eql_Q(default_uint, 0), eql_Q(default_long, 0), eql_Q(default_ulong, 0), eql_Q(default_bool, false), eql_Q(default_float, 0.0), eql_Q(default_double, 0.0), eql_Q(default_string, ""));
}
bool test_default_types(){
return and(eql_Q(typestr(default_int), "int"), eql_Q(typestr(default_uint), "uint"), eql_Q(typestr(default_long), "long"), eql_Q(typestr(default_ulong), "ulong"), eql_Q(typestr(default_bool), "bool"), eql_Q(typestr(default_float), "float"), eql_Q(typestr(default_double), "double"), eql_Q(typestr(default_string), "string"));
}
bool test_addition(){
return and(eql_Q(plus(default_int, 15), 15), eql_Q(plus(default_uint, 15), 15), eql_Q(plus(default_long, 15), 15), eql_Q(plus(default_ulong, 15), 15), eql_Q(plus(default_float, 15), 15), eql_Q(plus(default_double, 15), 15));
}
bool test_addition_2(){
return and(eql_Q(plus(default_int, 0), 0), eql_Q(plus(default_uint, 0), 0), eql_Q(plus(default_long, 0), 0), eql_Q(plus(default_ulong, 0), 0), eql_Q(plus(default_float, 0), 0), eql_Q(plus(default_double, 0), 0));
}
bool test_addition_3(){
return eql_Q(plus(1000, 111), plus(1000, 111));
}
bool test_addition_4(){
return eql_Q(plus(1000, 111), plus(111, 1000));
}
bool test_addition_types(){
return and(eql_Q(typestr(plus(default_int, 0)), "int"), eql_Q(typestr(plus(default_uint, 0)), "uint"), eql_Q(typestr(plus(default_long, 0)), "long"), eql_Q(typestr(plus(default_ulong, 0)), "ulong"), eql_Q(typestr(plus(default_float, 0)), "float"), eql_Q(typestr(plus(default_double, 0)), "double"));
}
bool test_subtraction(){
return and(eql_Q(sub(default_int, 15), -15), eql_Q(sub(default_long, 15), -15), eql_Q(sub(default_float, 15), -15), eql_Q(sub(default_double, 15), -15));
}
bool test_subtraction_2(){
return and(eql_Q(sub(default_int, 0), 0), eql_Q(sub(default_uint, 0), 0), eql_Q(sub(default_long, 0), 0), eql_Q(sub(default_ulong, 0), 0), eql_Q(sub(default_float, 0), 0), eql_Q(sub(default_double, 0), 0));
}
bool test_subtraction_3(){
return eql_Q(sub(1000, 111), sub(1000, 111));
}
bool test_subtraction_types(){
return and(eql_Q(typestr(sub(default_int, 0)), "int"), eql_Q(typestr(sub(default_uint, 0)), "uint"), eql_Q(typestr(sub(default_long, 0)), "long"), eql_Q(typestr(sub(default_ulong, 0)), "ulong"), eql_Q(typestr(sub(default_float, 0)), "float"), eql_Q(typestr(sub(default_double, 0)), "double"));
}
bool test_multiplication(){
return and(eql_Q(mul(default_int, 15), 0), eql_Q(mul(default_uint, 15), 0), eql_Q(mul(default_long, 15), 0), eql_Q(mul(default_ulong, 15), 0), eql_Q(mul(default_float, 15), 0), eql_Q(mul(default_double, 15), 0));
}
bool test_multiplication_2(){
return and(eql_Q(mul(plus(1, default_int), 15), 15), eql_Q(mul(plus(1, default_uint), 15), 15), eql_Q(mul(plus(1, default_long), 15), 15), eql_Q(mul(plus(1, default_ulong), 15), 15), eql_Q(mul(plus(1, default_float), 15), 15), eql_Q(mul(plus(1, default_double), 15), 15));
}
bool test_multiplication_3(){
return eql_Q(mul(1000, 111), mul(1000, 111));
}
bool test_multiplication_4(){
return eql_Q(mul(1000, 111), mul(111, 1000));
}
bool test_multiplication_types(){
return and(eql_Q(typestr(mul(default_int, 0)), "int"), eql_Q(typestr(mul(default_uint, 0)), "uint"), eql_Q(typestr(mul(default_long, 0)), "long"), eql_Q(typestr(mul(default_ulong, 0)), "ulong"), eql_Q(typestr(mul(default_float, 0)), "float"), eql_Q(typestr(mul(default_double, 0)), "double"));
}
bool test_division(){
return and(eql_Q(div(default_int, 15), 0), eql_Q(div(default_uint, 15), 0), eql_Q(div(default_long, 15), 0), eql_Q(div(default_ulong, 15), 0), eql_Q(div(default_float, 15), 0), eql_Q(div(default_double, 15), 0));
}
bool test_division_2(){
return and(eql_Q(div(plus(10, default_int), 2), 5), eql_Q(div(plus(10, default_uint), 2), 5), eql_Q(div(plus(10, default_long), 2), 5), eql_Q(div(plus(10, default_ulong), 2), 5), eql_Q(div(plus(10, default_float), 2), 5), eql_Q(div(plus(10, default_double), 2), 5));
}
bool test_division_3(){
return eql_Q(div(1000, 111), div(1000, 111));
}
bool test_division_types(){
return and(eql_Q(typestr(div(default_int, 1)), "int"), eql_Q(typestr(div(default_uint, 1)), "uint"), eql_Q(typestr(div(default_long, 1)), "long"), eql_Q(typestr(div(default_ulong, 1)), "ulong"), eql_Q(typestr(div(default_float, 1)), "float"), eql_Q(typestr(div(default_double, 1)), "double"));
}
bool test_modulo(){
return and(eql_Q(mod(default_int, 15), 0), eql_Q(mod(default_uint, 15), 0), eql_Q(mod(default_long, 15), 0), eql_Q(mod(default_ulong, 15), 0), eql_Q(mod(default_float, 15), 0), eql_Q(mod(default_double, 15), 0));
}
bool test_modulo_2(){
return and(eql_Q(mod(plus(10, default_int), 2), 0), eql_Q(mod(plus(10, default_uint), 2), 0), eql_Q(mod(plus(10, default_long), 2), 0), eql_Q(mod(plus(10, default_ulong), 2), 0), eql_Q(mod(plus(10, default_float), 2), 0), eql_Q(mod(plus(10, default_double), 2), 0));
}
bool test_modulo_3(){
return and(eql_Q(mod(plus(10, default_int), 3), 1), eql_Q(mod(plus(10, default_uint), 3), 1), eql_Q(mod(plus(10, default_long), 3), 1), eql_Q(mod(plus(10, default_ulong), 3), 1), eql_Q(mod(plus(10, default_float), 3), 1), eql_Q(mod(plus(10, default_double), 3), 1));
}
bool test_modulo_4(){
return eql_Q(mod(1000, 111), mod(1000, 111));
}
bool test_modulo_types(){
return and(eql_Q(typestr(div(default_int, 1)), "int"), eql_Q(typestr(div(default_uint, 1)), "uint"), eql_Q(typestr(div(default_long, 1)), "long"), eql_Q(typestr(div(default_ulong, 1)), "ulong"), eql_Q(typestr(div(default_float, 1)), "float"), eql_Q(typestr(div(default_double, 1)), "double"));
}
bool test_inc(){
return and(eql_Q(inc(default_int), 1), eql_Q(inc(default_uint), 1), eql_Q(inc(default_long), 1), eql_Q(inc(default_ulong), 1), eql_Q(inc(default_float), 1), eql_Q(inc(default_double), 1));
}
bool test_inc_2(){
return and(eql_Q(inc(inc(default_int)), 2), eql_Q(inc(inc(default_uint)), 2), eql_Q(inc(inc(default_long)), 2), eql_Q(inc(inc(default_ulong)), 2), eql_Q(inc(inc(default_float)), 2), eql_Q(inc(inc(default_double)), 2));
}
bool test_inc_3(){
return eql_Q(inc(1000), inc(1000));
}
bool test_inc_types(){
return and(eql_Q(typestr(plus(default_int, 0)), "int"), eql_Q(typestr(plus(default_uint, 0)), "uint"), eql_Q(typestr(plus(default_long, 0)), "long"), eql_Q(typestr(plus(default_ulong, 0)), "ulong"), eql_Q(typestr(plus(default_float, 0)), "float"), eql_Q(typestr(plus(default_double, 0)), "double"));
}
bool test_dec(){
return and(eql_Q(dec(default_int), -1), eql_Q(dec(default_long), -1), eql_Q(dec(default_float), -1), eql_Q(dec(default_double), -1));
}
bool test_dec_2(){
return and(eql_Q(dec(inc(default_int)), 0), eql_Q(dec(inc(default_uint)), 0), eql_Q(dec(inc(default_long)), 0), eql_Q(dec(inc(default_ulong)), 0), eql_Q(dec(inc(default_float)), 0), eql_Q(dec(inc(default_double)), 0));
}
bool test_dec_3(){
return eql_Q(dec(1000), dec(1000));
}
bool test_dec_types(){
return and(eql_Q(typestr(dec(inc(default_int))), "int"), eql_Q(typestr(dec(inc(default_uint))), "uint"), eql_Q(typestr(dec(inc(default_long))), "long"), eql_Q(typestr(dec(inc(default_ulong))), "ulong"), eql_Q(typestr(dec(inc(default_float))), "float"), eql_Q(typestr(dec(inc(default_double))), "double"));
}
bool test_bit_and(){
return and(eql_Q(bit_and(3, 1), 1), eql_Q(bit_and(3, 3), 3), eql_Q(bit_and(3, 0), 0), eql_Q(bit_and(true, 1), 1));
}
bool test_bit_and_2(){
return eql_Q(bit_and(3, 1), bit_and(3, 1));
}
bool test_bit_or(){
return and(eql_Q(bit_or(3, 1), 3), eql_Q(bit_or(3, 3), 3), eql_Q(bit_or(3, 0), 3), eql_Q(bit_or(true, 1), 1));
}
bool test_bit_or_2(){
return eql_Q(bit_or(3, 1), bit_or(3, 1));
}
bool test_bit_xor(){
return and(eql_Q(bit_xor(3, 1), 2), eql_Q(bit_xor(3, 3), 0), eql_Q(bit_xor(3, 0), 3), eql_Q(bit_xor(true, 1), 0));
}
bool test_bit_xor_2(){
return eql_Q(bit_xor(33, 3), bit_xor(33, 3));
}
bool test_bit_neg(){
return true;
}
bool test_bit_shl(){
return and(eql_Q(shift_left(3, 1), 6), eql_Q(shift_left(0, 3), 0), eql_Q(shift_left(3, 0), 3));
}
bool test_bit_shl_2(){
return eql_Q(shift_left(33, 1), shift_left(33, 1));
}
bool test_bit_shr(){
return and(eql_Q(shift_right(6, 1), 3), eql_Q(shift_right(0, 3), 0), eql_Q(shift_right(3, 0), 3));
}
bool test_bit_shr_2(){
return eql_Q(shift_right(33, 1), shift_right(33, 1));
}
bool test_equals(){
return and(eql_Q(3, 3), eql_Q(3000, 3000), eql_Q("abc", "abc"), eql_Q(true, true), eql_Q(false, false), eql_Q([], []), eql_Q(3.0, 3.0));
}
bool test_equals_2(){
return and(not(eql_Q(3, 3.5)), not(eql_Q(1, 2)), not(eql_Q("abc", "def")), not(eql_Q(true, false)), not(eql_Q(false, true)), not(eql_Q(3.0, 3.1)));
}
bool test_not_equals(){
return and(not(not_eql_Q(3, 3)), not(not_eql_Q(3000, 3000)), not(not_eql_Q("abc", "abc")), not(not_eql_Q(true, true)), not(not_eql_Q(false, false)), not(not_eql_Q([], [])), not(not_eql_Q(3.0, 3.0)));
}
bool test_not_equals_2(){
return and(not_eql_Q(3, 3.5), not_eql_Q(1, 2), not_eql_Q("abc", "def"), not_eql_Q(true, false), not_eql_Q(false, true), not_eql_Q(3.0, 3.1));
}
bool test_not_equals_3(){
return and(not_eql_Q(3, 3.5), not_eql_Q(1, 2), not_eql_Q("abc", "def"), not_eql_Q(true, false), not_eql_Q(false, true), not_eql_Q(3.0, 3.1));
}
bool test_comparisons(){
return and(lt_Q(0, 3), gt_Q(3, 0), le_Q(0, 3), le_Q(3, 3), eql_Q(0, 0), ge_Q(3, 0), ge_Q(3, 3), pos_Q(0), pos_Q(1), not(pos_Q(-1)), neg_Q(-1), not(neg_Q(0)), eql_Q(compare(15, 15), 0), eql_Q(compare(15, 0), 1), eql_Q(compare(0, 15), -1));
}
bool test_comparisons_2(){
return and(lt_Q(0.5, 3.5), gt_Q(3.5, 0.5), le_Q(0.5, 3.5), le_Q(3.5, 3.5), eql_Q(0.5, 0.5), ge_Q(3.5, 0.5), ge_Q(3.5, 3.5), pos_Q(0.0), pos_Q(1.5), not(pos_Q(-1.5)), neg_Q(-1.5), not(neg_Q(0.0)), eql_Q(compare(15.5, 15.5), 0), eql_Q(compare(15.5, 0.5), 1), eql_Q(compare(0.5, 15.5), -1));
}
bool test_comparisons_3(){
return and(lt_Q("", "a"), gt_Q("a", ""), le_Q("", "a"), le_Q("", ""), eql_Q("", ""), ge_Q("a", ""), ge_Q("a", "a"), eql_Q(compare("a", "a"), 0), eql_Q(compare("a", ""), 1), eql_Q(compare("", "a"), -1));
}
bool test_bool_not(){
return and(not(not(true)), not(false), not(0));
}
bool test_bool_and(){
return and(and(true, true), not(and(true, false)), not(and(false, true)), not(and(false, false)), and(1, 1), not(and(1, 0)), not(and(0, 1)), not(and(0, 0)), and(true, true, true, true), not(and(true, false, true, true)), not(and(false, true, true, true)), not(and(false, false, false, false)));
}
bool test_bool_nand(){
return and(not(nand(true, true)), nand(true, false), nand(false, true), nand(false, false), not(nand(1, 1)), nand(1, 0), nand(0, 1), nand(0, 0), not(nand(true, true, true, true)), nand(true, false, true, true), nand(false, true, true, true), nand(false, false, false, false));
}
bool test_bool_or(){
return and(or(true, true), or(true, false), or(false, true), not(or(false, false)), or(1, 1), or(1, 0), or(0, 1), not(or(0, 0)), or(true, true, true, true, true), or(true, true, true, true, false), or(false, true, true, true, true), not(or(false, false, false, false)));
}
bool test_bool_nor(){
return and(not(nor(true, true)), not(nor(true, false)), not(nor(false, true)), nor(false, false), not(nor(1, 1)), not(nor(1, 0)), not(nor(0, 1)), nor(0, 0), not(nor(true, true, true, true, true)), not(nor(true, true, true, true, false)), not(nor(false, true, true, true, true)), nor(false, false, false, false));
}
bool test_bool_xor(){
return and(not(xor(true, true)), xor(true, false), xor(false, true), not(xor(false, false)), not(xor(1, 1)), xor(1, 0), xor(0, 1), not(xor(0, 0)));
}
bool test_size(){
return and(eql_Q(size([]), 0), eql_Q(size([1,2,3]), 3), eql_Q(size(""), 0), eql_Q(size("111"), 3));
}
bool test_values(){
{
auto v = [1,2,3];
auto v2 = values(v);
auto s = "123";
auto s2 = values(s);
return and(eql_Q(v, v2), eql_Q(s, s2));}
}
bool test_append(){
{
auto v0 = [1,2,3];
auto v1 = [4,5,6];
auto v2 = append(v0, v1);
auto s0 = "123";
auto s1 = "456";
auto s2 = append(s0, s1);
return and(eql_Q(v0, [1,2,3]), eql_Q(v1, [4,5,6]), eql_Q(v2, [1,2,3,4,5,6]), eql_Q(s0, "123"), eql_Q(s1, "456"), eql_Q(s2, "123456"));}
}
bool test_append_1(){
{
auto v0 = [1,2,3];
auto v1 = append(v0, 4);
auto s0 = "123";
auto s1 = append(s0, '4');
return and(eql_Q(v0, [1,2,3]), eql_Q(v1, [1,2,3,4]), eql_Q(s0, "123"), eql_Q(s1, "1234"));}
}
bool test_append_E(){
{
auto v0 = [1,2,3];
auto v1 = append_E(v0, 4);
auto s0 = "123";
auto s1 = append_E(s0, '4');
return and(eql_Q(v0, [1,2,3,4]), eql_Q(s0, "1234"), eql_Q(v1, [1,2,3,4]), eql_Q(s1, "1234"));}
}
bool test_append_1_E(){
{
auto v0 = [1,2,3];
auto v1 = [4,5,6];
auto v2 = append_E(v0, v1);
auto s0 = "123";
auto s1 = "456";
auto s2 = append_E(s0, s1);
return and(eql_Q(v2, [1,2,3,4,5,6]), eql_Q(v1, [4,5,6]), eql_Q(s2, "123456"), eql_Q(s1, "456"));}
}
bool test_prepend(){
{
auto v0 = [1,2,3];
auto v1 = prepend(4, v0);
auto s0 = "123";
auto s1 = prepend('4', s0);
return and(eql_Q(v0, [1,2,3]), eql_Q(v1, [4,1,2,3]), eql_Q(s0, "123"), eql_Q(s1, "4123"));}
}
bool test_coll_clone(){
{
auto v0 = [1,2,3];
auto v1 = coll_clone(v0);
auto s0 = "123";
auto s1 = coll_clone(s0);
return and(eql_Q(v0, [1,2,3]), eql_Q(v1, [1,2,3]), eql_Q(s0, "123"), eql_Q(s1, "123"));}
}

void main1(){
println_E(append("test-defaults      ", to_s(test_defaults())));
println_E(append("test-default-types ", to_s(test_default_types())));
println_E("");
println_E(append("test-add           ", to_s(test_addition())));
println_E(append("test-add-2         ", to_s(test_addition_2())));
println_E(append("test-add-3         ", to_s(test_addition_3())));
println_E(append("test-add-4         ", to_s(test_addition_4())));
println_E(append("test-add-types     ", to_s(test_addition_types())));
println_E(append("test-sub           ", to_s(test_subtraction())));
println_E(append("test-sub-2         ", to_s(test_subtraction_2())));
println_E(append("test-sub-3         ", to_s(test_subtraction_3())));
println_E(append("test-sub-types     ", to_s(test_subtraction_types())));
println_E(append("test-mul           ", to_s(test_multiplication())));
println_E(append("test-mul-2         ", to_s(test_multiplication_2())));
println_E(append("test-mul-3         ", to_s(test_multiplication_3())));
println_E(append("test-mul-4         ", to_s(test_multiplication_4())));
println_E(append("test-mul-types     ", to_s(test_multiplication_types())));
println_E(append("test-div           ", to_s(test_division())));
println_E(append("test-div-2         ", to_s(test_division_2())));
println_E(append("test-div-3         ", to_s(test_division_3())));
println_E(append("test-div-types     ", to_s(test_division_types())));
println_E(append("test-mod           ", to_s(test_modulo())));
println_E(append("test-mod-2         ", to_s(test_modulo_2())));
println_E(append("test-mod-3         ", to_s(test_modulo_3())));
println_E(append("test-mod-4         ", to_s(test_modulo_4())));
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
}


