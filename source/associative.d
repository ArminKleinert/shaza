module associative;

import stdlib;

class ArrayMap(K, V) {
K[] keys;
V[] values;
alias keys this;
this(K[] _keys, V[] _values){
keys = _keys;
values = _values;
}
ArrayMap with_keys(K[] keys){
return new ArrayMap(keys, values);
}
ArrayMap with_values(V[] values){
return new ArrayMap(keys, values);
}
ArrayMap clone(){
return new ArrayMap(keys, values);
}
}


ArrayMap!(K,V) create_map(K, V)(K[] ks, V[] vs){
return new ArrayMap!(K,V)(ks, vs);
}
bool map_empty_Q(K, V)(ArrayMap!(K,V) am){
return eql_Q(size(am.keys), 0);
}
V map_get(K, V)(ArrayMap!(K,V) am, K key){
return get(am.values, index_of(am.keys, key));
}
bool has_key_Q(K, V)(ArrayMap!(K,V) am, K key){
return not_eql_Q(index_of(am.keys, key), -1);
}
ArrayMap!(K,V) assoc(K, V)(ArrayMap!(K,V) am, K key, V value){
{
auto i = index_of(am.keys, key);
return if2(eql_Q(i, -1), new ArrayMap!(K,V)(append(am.keys, key), append(am.values, value)), new ArrayMap!(K,V)(clone(keys), assoc(am.values, i, values)));}
}
ArrayMap!(K,V) assoc_E(K, V)(ArrayMap!(K,V) am, K key, V value){
{
auto i = index_of(am.keys, key);
return if2(eql_Q(i, -1), {
append_E(am.keys, key);
append_E(am.values, value);
am;}, {
assoc_E(am.values, i, values);
am;});}
}
ArrayMap!(K,V) keys(K, V)(ArrayMap!(K,V) am){
return clone(am.keys);
}
ArrayMap!(K,V) values(K, V)(ArrayMap!(K,V) am){
return clone(am.values);
}


