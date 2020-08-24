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
return and(eql_Q(default_int, 0), and(eql_Q(default_uint, 0), and(eql_Q(default_long, 0), and(eql_Q(default_ulong, 0), and(eql_Q(default_bool, false), and(eql_Q(default_float, 0.0), and(eql_Q(default_double, 0.0), eql_Q(default_string, ""))))))));
}
bool test_default_types(){
return and(eql_Q(typestr(default_int), "int"), and(eql_Q(typestr(default_uint), "uint"), and(eql_Q(typestr(default_long), "long"), and(eql_Q(typestr(default_ulong), "ulong"), and(eql_Q(typestr(default_bool), "bool"), and(eql_Q(typestr(default_float), "float"), and(eql_Q(typestr(default_double), "double"), eql_Q(typestr(default_string), "string"))))))));
}
bool test_addition(){
return and(eql_Q(plus(default_int, 15), 15), and(eql_Q(plus(default_uint, 15), 15), and(eql_Q(plus(default_long, 15), 15), and(eql_Q(plus(default_ulong, 15), 15), and(eql_Q(plus(default_float, 15), 15), eql_Q(plus(default_double, 15), 15))))));
}
bool test_addition_2(){
return and(eql_Q(plus(default_int, 0), 0), and(eql_Q(plus(default_uint, 0), 0), and(eql_Q(plus(default_long, 0), 0), and(eql_Q(plus(default_ulong, 0), 0), and(eql_Q(plus(default_float, 0), 0), eql_Q(plus(default_double, 0), 0))))));
}
bool test_addition_3(){
return eql_Q(plus(1000, 111), plus(1000, 111));
}
bool test_addition_4(){
return eql_Q(plus(1000, 111), plus(111, 1000));
}
bool test_addition_types(){
return and(eql_Q(typestr(plus(default_int, 0)), "int"), and(eql_Q(typestr(plus(default_uint, 0)), "uint"), and(eql_Q(typestr(plus(default_long, 0)), "long"), and(eql_Q(typestr(plus(default_ulong, 0)), "ulong"), and(eql_Q(typestr(plus(default_float, 0)), "float"), eql_Q(typestr(plus(default_double, 0)), "double"))))));
}
bool test_subtraction(){
return and(eql_Q(sub(default_int, 15), -15), and(eql_Q(sub(default_long, 15), -15), and(eql_Q(sub(default_float, 15), -15), eql_Q(sub(default_double, 15), -15))));
}
bool test_subtraction_2(){
return and(eql_Q(sub(default_int, 0), 0), and(eql_Q(sub(default_uint, 0), 0), and(eql_Q(sub(default_long, 0), 0), and(eql_Q(sub(default_ulong, 0), 0), and(eql_Q(sub(default_float, 0), 0), eql_Q(sub(default_double, 0), 0))))));
}
bool test_subtraction_3(){
return eql_Q(sub(1000, 111), sub(1000, 111));
}
bool test_subtraction_types(){
return and(eql_Q(typestr(sub(default_int, 0)), "int"), and(eql_Q(typestr(sub(default_uint, 0)), "uint"), and(eql_Q(typestr(sub(default_long, 0)), "long"), and(eql_Q(typestr(sub(default_ulong, 0)), "ulong"), and(eql_Q(typestr(sub(default_float, 0)), "float"), eql_Q(typestr(sub(default_double, 0)), "double"))))));
}
bool test_multiplication(){
return and(eql_Q(mul(default_int, 15), 15), and(eql_Q(mul(default_uint, 15), 15), and(eql_Q(mul(default_long, 15), 15), and(eql_Q(mul(default_ulong, 15), 15), and(eql_Q(mul(default_float, 15), 15), eql_Q(mul(default_double, 15), 15))))));
}
bool test_multiplication_2(){
return and(eql_Q(mul(plus(1, default_int), 15), 15), and(eql_Q(mul(plus(1, default_uint), 15), 15), and(eql_Q(mul(plus(1, default_long), 15), 15), and(eql_Q(mul(plus(1, default_ulong), 15), 15), and(eql_Q(mul(plus(1, default_float), 15), 15), eql_Q(mul(plus(1, default_double), 15), 15))))));
}
bool test_multiplication_3(){
return eql_Q(mul(1000, 111), mul(1000, 111));
}
bool test_multiplication_4(){
return eql_Q(mul(1000, 111), mul(111, 1000));
}
bool test_multiplication_types(){
return and(eql_Q(typestr(mul(default_int, 0)), "int"), and(eql_Q(typestr(mul(default_uint, 0)), "uint"), and(eql_Q(typestr(mul(default_long, 0)), "long"), and(eql_Q(typestr(mul(default_ulong, 0)), "ulong"), and(eql_Q(typestr(mul(default_float, 0)), "float"), eql_Q(typestr(mul(default_double, 0)), "double"))))));
}
bool test_division(){
return and(eql_Q(div(default_int, 15), 0), and(eql_Q(div(default_uint, 15), 0), and(eql_Q(div(default_long, 15), 0), and(eql_Q(div(default_ulong, 15), 0), and(eql_Q(div(default_float, 15), 0), eql_Q(div(default_double, 15), 0))))));
}
bool test_division_2(){
return and(eql_Q(div(plus(10, default_int), 2), 5), and(eql_Q(div(plus(10, default_uint), 2), 5), and(eql_Q(div(plus(10, default_long), 2), 5), and(eql_Q(div(plus(10, default_ulong), 2), 5), and(eql_Q(div(plus(10, default_float), 2), 5), eql_Q(div(plus(10, default_double), 2), 5))))));
}
bool test_division_3(){
return eql_Q(div(1000, 111), div(1000, 111));
}
bool test_division_types(){
return and(eql_Q(typestr(div(default_int, 1)), "int"), and(eql_Q(typestr(div(default_uint, 1)), "uint"), and(eql_Q(typestr(div(default_long, 1)), "long"), and(eql_Q(typestr(div(default_ulong, 1)), "ulong"), and(eql_Q(typestr(div(default_float, 1)), "float"), eql_Q(typestr(div(default_double, 1)), "double"))))));
}
bool test_modulo(){
return and(eql_Q(mod(default_int, 15), 0), and(eql_Q(mod(default_uint, 15), 0), and(eql_Q(mod(default_long, 15), 0), and(eql_Q(mod(default_ulong, 15), 0), and(eql_Q(mod(default_float, 15), 0), eql_Q(mod(default_double, 15), 0))))));
}
bool test_modulo_2(){
return and(eql_Q(mod(plus(10, default_int), 2), 0), and(eql_Q(mod(plus(10, default_uint), 2), 0), and(eql_Q(mod(plus(10, default_long), 2), 0), and(eql_Q(mod(plus(10, default_ulong), 2), 0), and(eql_Q(mod(plus(10, default_float), 2), 0), eql_Q(mod(plus(10, default_double), 2), 0))))));
}
bool test_modulo_3(){
return and(eql_Q(mod(plus(10, default_int), 3), 1), and(eql_Q(mod(plus(10, default_uint), 3), 1), and(eql_Q(mod(plus(10, default_long), 3), 1), and(eql_Q(mod(plus(10, default_ulong), 3), 1), and(eql_Q(mod(plus(10, default_float), 3), 1), eql_Q(mod(plus(10, default_double), 3), 1))))));
}
bool test_modulo_4(){
return eql_Q(mod(1000, 111), mod(1000, 111));
}
bool test_modulo_types(){
return and(eql_Q(typestr(div(default_int, 1)), "int"), and(eql_Q(typestr(div(default_uint, 1)), "uint"), and(eql_Q(typestr(div(default_long, 1)), "long"), and(eql_Q(typestr(div(default_ulong, 1)), "ulong"), and(eql_Q(typestr(div(default_float, 1)), "float"), eql_Q(typestr(div(default_double, 1)), "double"))))));
}
bool test_inc(){
return and(eql_Q(inc(default_int), 1), and(eql_Q(inc(default_uint), 1), and(eql_Q(inc(default_long), 1), and(eql_Q(inc(default_ulong), 1), and(eql_Q(inc(default_float), 1), eql_Q(inc(default_double), 1))))));
}
bool test_inc_2(){
return and(eql_Q(inc(inc(default_int)), 2), and(eql_Q(inc(inc(default_uint)), 2), and(eql_Q(inc(inc(default_long)), 2), and(eql_Q(inc(inc(default_ulong)), 2), and(eql_Q(inc(inc(default_float)), 2), eql_Q(inc(inc(default_double)), 2))))));
}
bool test_inc_3(){
return eql_Q(inc(1000), inc(1000));
}
bool test_inc_types(){
return and(eql_Q(typestr(plus(default_int, 0)), "int"), and(eql_Q(typestr(plus(default_uint, 0)), "uint"), and(eql_Q(typestr(plus(default_long, 0)), "long"), and(eql_Q(typestr(plus(default_ulong, 0)), "ulong"), and(eql_Q(typestr(plus(default_float, 0)), "float"), eql_Q(typestr(plus(default_double, 0)), "double"))))));
}
bool test_dec(){
return and(eql_Q(dec(default_int), -1), and(eql_Q(dec(default_long), -1), and(eql_Q(dec(default_float), -1), eql_Q(dec(default_double), -1))));
}
bool test_dec_2(){
return and(eql_Q(dec(inc(default_int)), 0), and(eql_Q(dec(inc(default_uint)), 0), and(eql_Q(dec(inc(default_long)), 0), and(eql_Q(dec(inc(default_ulong)), 0), and(eql_Q(dec(inc(default_float)), 0), eql_Q(dec(inc(default_double)), 0))))));
}
bool test_dec_3(){
return eql_Q(dec(1000), dec(1000));
}
bool test_dec_types(){
return and(eql_Q(typestr(dec(inc(default_int))), "int"), and(eql_Q(typestr(dec(inc(default_uint))), "uint"), and(eql_Q(typestr(dec(inc(default_long))), "long"), and(eql_Q(typestr(dec(inc(default_ulong))), "ulong"), and(eql_Q(typestr(dec(inc(default_float))), "float"), eql_Q(typestr(dec(inc(default_double))), "double"))))));
}
bool test_bit_and(){
return and(eql_Q(bit_and(3, 1), 1), and(eql_Q(bit_and(3, 3), 3), and(eql_Q(bit_and(3, 0), 0), eql_Q(bit_and(true, 1), 1))));
}
bool test_bit_and_2(){
return eql_Q(bit_and(3, 1), bit_and(3, 1));
}
bool test_bit_or(){
return and(eql_Q(bit_or(3, 1), 3), and(eql_Q(bit_or(3, 3), 3), and(eql_Q(bit_or(3, 0), 3), eql_Q(bit_or(true, 1), 1))));
}
bool test_bit_or_2(){
return eql_Q(bit_or(3, 1), bit_or(3, 1));
}
bool test_bit_xor(){
return and(eql_Q(bit_xor(3, 1), 2), and(eql_Q(bit_xor(3, 3), 0), and(eql_Q(bit_xor(3, 0), 3), eql_Q(bit_xor(true, 1), 0))));
}
bool test_bit_xor_2(){
return eql_Q(bit_xor(33, 3), bit_xor(33, 3));
}
bool test_bit_shl(){
return and(eql_Q(shift_left(3, 1), 6), and(eql_Q(shift_left(0, 3), 0), eql_Q(shift_left(3, 0), 3)));
}
bool test_bit_shl_2(){
return eql_Q(shift_left(33, 1), shift_left(33, 1));
}
bool test_bit_shr(){
return and(eql_Q(shift_right(6, 1), 3), and(eql_Q(shift_right(0, 3), 0), eql_Q(shift_right(3, 0), 3)));
}
bool test_bit_shr_2(){
return eql_Q(shift_right(33, 1), shift_right(33, 1));
}
bool test_equals(){
return and(eql_Q(3, 3), and(eql_Q(3000, 3000), and(eql_Q("abc", "abc"), and(eql_Q(true, true), and(eql_Q(false, false), eql_Q(3.0, 3.0))))));
}
bool test_ref_equals(){
{
auto a = 3;
auto b = 3000;
auto c = "abc";
auto d = true;
auto e = false;
auto f = 3.0;
return and(ref_eql(a, a), and(ref_eql(b, b), and(ref_eql(c, c), and(ref_eql(d, d), and(ref_eql(e, e), ref_eql(f, f))))));}
}

void main(){
println_E(append("test-defaults ", to_s(test_defaults())));
println_E(append("test-default-types ", to_s(test_default_types())));
println_E(append("test-addition ", to_s(test_addition())));
println_E(append("test-addition-2 ", to_s(test_addition_2())));
println_E(append("test-addition-3 ", to_s(test_addition_3())));
println_E(append("test-addition-4 ", to_s(test_addition_4())));
println_E(append("test-addition-types ", to_s(test_addition_types())));
println_E(append("test-subtraction ", to_s(test_subtraction())));
println_E(append("test-subtraction-2 ", to_s(test_subtraction_2())));
println_E(append("test-subtraction-3 ", to_s(test_subtraction_3())));
println_E(append("test-subtraction-types ", to_s(test_subtraction_types())));
println_E(append("test-multiplication ", to_s(test_multiplication())));
println_E(append("test-multiplication-2 ", to_s(test_multiplication_2())));
println_E(append("test-multiplication-3 ", to_s(test_multiplication_3())));
println_E(append("test-multiplication-4 ", to_s(test_multiplication_4())));
println_E(append("test-multiplication-types ", to_s(test_multiplication_types())));
println_E(append("test-division ", to_s(test_division())));
println_E(append("test-division-2 ", to_s(test_division_2())));
println_E(append("test-division-3 ", to_s(test_division_3())));
println_E(append("test-division-types ", to_s(test_division_types())));
println_E(append("test-modulo", to_s(test_modulo())));
println_E(append("test-modulo-2 ", to_s(test_modulo_2())));
println_E(append("test-modulo-3 ", to_s(test_modulo_3())));
println_E(append("test-modulo-4 ", to_s(test_modulo_4())));
println_E(append("test-modulo-types ", to_s(test_modulo_types())));
println_E(append("test-inc ", to_s(test_inc())));
println_E(append("test-inc-2 ", to_s(test_inc_2())));
println_E(append("test-inc-3 ", to_s(test_inc_3())));
println_E(append("test-inc-types ", to_s(test_inc_types())));
println_E(append("test-dec ", to_s(test_dec())));
println_E(append("test-dec-2 ", to_s(test_dec_2())));
println_E(append("test-dec-3 ", to_s(test_dec_3())));
println_E(append("test-dec-types ", to_s(test_dec_types())));
println_E(append("test-bit-and ", to_s(test_bit_and())));
println_E(append("test-bit-and-2 ", to_s(test_bit_and_2())));
println_E(append("test-bit-or ", to_s(test_bit_or())));
println_E(append("test-bit-and-2 ", to_s(test_bit_and_2())));
println_E(append("test-bit-xor ", to_s(test_bit_xor())));
println_E(append("test-bit-xor-2 ", to_s(test_bit_xor_2())));
println_E(append("test-bit-shl ", to_s(test_bit_shl())));
println_E(append("test-bit-shl-2 ", to_s(test_bit_shl_2())));
println_E(append("test-bit-shr ", to_s(test_bit_shr())));
println_E(append("test-bit-shr-2 ", to_s(test_bit_shr_2())));
println_E(append("test-equals ", to_s(test_equals())));
println_E(append("test-ref-equals ", to_s(test_ref_equals())));
}


