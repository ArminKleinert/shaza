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
bool test_keys(){
{
auto coll = [1,2,3];
auto s = "123";
return and(eql_Q(keys(coll), [0,1,2]), eql_Q(keys(s), [0,1,2]));}
}
bool test_assoc_E(){
{
auto coll = [1,3,3];
auto coll1 = [1,4,5];
return and(eql_Q(assoc_E(coll, 1, 2), [1,2,3]), eql_Q(coll, [1,2,3]), eql_Q(assoc_E(coll1, 0, 5), coll1));}
}
bool test_assoc(){
{
auto coll = [1,3,3];
return and(eql_Q(assoc(coll, 1, 2), [1,2,3]), eql_Q(coll, [1,3,3]));}
}
bool test_slice(){
{
auto coll = [1,2,3,4,5,6];
auto text = "123456";
return and(eql_Q(coll, slice(coll, 0)), eql_Q(slice(coll, 2), slice(coll, 2)), eql_Q(size(slice(coll, 1)), 5), eql_Q(text, slice(text, 0)), eql_Q(slice(text, 2), slice(text, 2)), eql_Q(size(slice(text, 1)), 5));}
}
bool test_slice_1(){
{
auto coll = [1,2,3,4,5,6];
auto text = "123456";
return and(eql_Q(coll, slice(coll, 0, 0)), eql_Q(slice(coll, 2, 0), [3,4,5,6]), eql_Q(slice(coll, 2, 1), [3,4,5]), eql_Q(slice(coll, 2, 1), slice(coll, 2, 1)), eql_Q(size(slice(coll, 1, 1)), 4), eql_Q(text, slice(text, 0, 0)), eql_Q(slice(text, 2, 2), slice(text, 2, 2)), eql_Q(size(slice(text, 1, 1)), 4));}
}
bool test_get(){
{
auto coll = [1,2,3,4];
auto text = "1234";
return and(eql_Q(get(coll, 0), 1), eql_Q(get(coll, 1), 2), eql_Q(get(coll, 2), 3), eql_Q(get(text, 0), '1'), eql_Q(get(text, 1), '2'), eql_Q(get(text, 2), '3'));}
}
private bool is_int_array_Q(int[] a){
return true;
}
bool test_cleared(){
{
auto coll = [1,2,3,4,5];
return and(eql_Q(cleared(coll), []), is_int_array_Q(cleared(coll)), eql_Q(append(cleared(coll), coll), coll));}
}
bool test_resized(){
{
auto coll = [1,1,1];
return and(eql_Q(resized(coll, 0), []), eql_Q(resized(coll, 1), [1]), eql_Q(resized(coll, 4), [1,1,1,0]), eql_Q(resized(resized(coll, 0), 5), [0,0,0,0,0]), is_int_array_Q(resized(coll, 8)));}
}
bool test_vector(){
return and(eql_Q(vector(1, 2, 3, 4), [1,2,3,4]), is_int_array_Q(vector(1, 2, 3)), eql_Q(size(vector(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)), 13));
}
bool test_first(){
{
auto coll = [1,2,3,4];
return and(eql_Q(first(coll), 1), eql_Q(first(coll), get(coll, 0)));}
}
bool test_second(){
{
auto coll = [1,2,3,4];
return and(eql_Q(second(coll), 2), eql_Q(second(coll), get(coll, 1)));}
}
bool test_last(){
{
auto coll = [1,2,3,4];
return eql_Q(last(coll), 4);}
}
bool test_rest(){
return and(eql_Q(rest([1,2,3]), [2,3]), eql_Q(rest([1]), []));
}
bool test_empty(){
return and(empty_Q([]), not(empty_Q([1])), empty_Q(""));
}
bool test_not_empty(){
return and(not_empty_Q([1]), not(not_empty_Q([])), not_empty_Q("1"));
}
bool test_key_of(){
{
auto coll = [15,16,17];
return and(eql_Q(key_of(coll, 16), 1), eql_Q(key_of(coll, 61), 0), eql_Q(key_of(coll, 16, 7), 1), eql_Q(key_of(coll, 61, 7), 7));}
}
bool test_key_of1(){
{
auto coll = "678";
return and(eql_Q(key_of(coll, '6'), 0), eql_Q(key_of(coll, '6', 7), 0), eql_Q(key_of(coll, '9', 7), 7));}
}

auto test_index_of(){
{
auto coll = [15,16,17];
return and(eql_Q(index_of(coll, 16), 1), eql_Q(index_of(coll, 61), -1), eql_Q(index_of(coll, 16), 1), eql_Q(index_of(coll, 61), -1));}
}

auto test_index_of1(){
{
auto coll = "678";
return and(eql_Q(index_of(coll, '6'), 0), eql_Q(index_of(coll, '9'), -1), eql_Q(index_of(coll, '6'), 0), eql_Q(index_of(coll, '9'), -1));}
}

auto test_starts_with(){
{
auto coll = [1,2,3,4];
println_E(starts_with_Q(coll, 1));
println_E(starts_with_Q(rest(coll), 2));
println_E(starts_with_Q(coll, [1,2]));
println_E(not(starts_with_Q(coll, 2)));
println_E(not(starts_with_Q(coll, [1,2,3,4,5])));
println_E(starts_with_Q(coll, coll));
return and(starts_with_Q(coll, 1), starts_with_Q(rest(coll), 2), starts_with_Q(coll, [1,2]), not(starts_with_Q(coll, 2)), not(starts_with_Q(coll, [1,2,3,4,5])), starts_with_Q(coll, coll));}
}

auto test_ends_with(){
{
auto coll = [1,2,3,4];
return and(ends_with_Q(coll, 4), ends_with_Q(slice(coll, 0, 1), 3), ends_with_Q(coll, coll), ends_with_Q(coll, [3,4]));}
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
}


