```
File   <native>
Module <native>
Name(s)                    | Export-name                | Input                  | Output          | Generics      | Description
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
module                     |                            | <Symbol>               | 
when                       |                            | <bool>, <Expr>, <Expr> |                 |               | Compiles to an if-expression
fp                         |                            | <Function>             | Pointer         |               | 
let                        |                            | <Bindings>, <Body>     |                 |               | 
loop                       |                            | <Bindings>, <Body>     |                 |               | 
define                     |                            | <Attr?> <Name> <Val>   |                 |               | 
define                     |                            | <Attr?>, <Name>,       |                 |               | 
                           |                            | <Args>, <Body>         |                 |               | 
lambda                     |                            | <Attr?>, <Args>,       |                 |               | 
                           |                            | <Body>                 |                 |               | 
setv!                      |                            | <Symbol>, <Val>        | 
return                     |                            | <Expr>                 | 
ll                         |                            | <Token...>             | 
llr                        |                            | <Token...>             | ?
new                        |
to                         |
cast                       |
struct                     |
def-struct                 |
def-type                   |
comment                    |
import-sz                  |
import-host                |
rt-import-sz               |
rt-import-host             |
quote                      | 
pseudo-quote
unquote 
meta   
alias


File   stdlib.sz
Module stdlib
Name(s)                    | Export-name                | Input                  | Output          | Generics      | Description
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
keywword                   | keyword                    | string                 | Keyword         |               |
str                        | str                        | T                      | string          | T=any         |
to_s                       | to_s                       | T                      | string          | T=any         |
to-int-valid?              | to_int_valid_Q             | T                      | bool            | T=any         | 
to-uint-valid?             | to_uint_valid_Q            | T                      | bool            | T=any         | 
to-long-valid?             | to_long_valid_Q            | T                      | bool            | T=any         | 
to-ulong-valid?            | to_ulong_valid_Q           | T                      | bool            | T=any         | 
to-float-valid?            | to_float_valid_Q           | T                      | bool            | T=any         | 
to-double-valid?           | to_double_valid_Q          | T                      | bool            | T=any         | 
print!                     | print_E                    | T                      | bool            | T=any         | 
println!                   | println_E                  | T                      | bool            | T=any         | 
error!                     | error_E                    | T                      | bool            | T=any         | 
errorln!                   | errorln_E                  | T                      | bool            | T=any         | 
readln!                    | readln_E                   | T                      | bool            | T=any         | 

File   basics.sz
Module stdlib
Name(s)                    | Export-name                | Input                  | Output          | Generics      | Description
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
if                         | if2                        | bool, T, T             | T               | T=any         | Typical if, all arguments are lazy
if                         | if2                        | bool, T                | T               | T=any         | Typical if, all arguments are lazy
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
+ plus                     | plus                       | N, N...                | N               | N=Number      | 
- sub                      | sub                        | N, N...                | N               | N=Number      | 
* mul                      | mul                        | N, N...                | N               | N=Number      | 
/ div                      | div                        | N, N, N...             | N               | N=Number      | 
% mod                      | mod                        | N, N, N...             | N               | N=Number      | 
++ inc                     | inc                        | N                      | N               | N=Number      | 
-- dec                     | dec                        | N                      | N               | N=Number      | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
& bit-and                  | bit_and                    | N, N                   | N               | N=Integral    | 
| bit-or                   | bit_or                     | N, N                   | N               | N=Integral    | 
^ bit-xor                  | bit_xor                    | N, N                   | N               | N=Integral    | 
<< shl                     | shift_left                 | N, N                   | N               | N=Integral    | 
>> shr                     | shift_right                | N, N                   | N               | N=Integral    | 
~ bit-flip                 | bit_negate                 | N                      | N               | N=Integral    | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
! not                      | not                        | bool                   | bool            |               | 
&& and                     | and                        | bool, bool, bool...    | bool            |               | 
|| or                      | or                         | bool, bool, bool...    | bool            |               | 
^^ xor                     | xor                        | bool, bool             | bool            |               | 
!&& nand                   | nand                       | bool, bool, bool...    | bool            |               | 
!|| nor                    | nor                        | bool, bool, bool...    | bool            |               | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
= == eql?                  | eql_Q                      | T, T                   | bool            | T=any         | 
!= not= not-eql?           | not_eql_Q                  | T, T                   | bool            | T=any         |  
< lt?                      | lt_Q                       | T, T                   | bool            | T=comparable  | 
<= le?                     | le_Q                       | T, T                   | bool            | T=comparable  | 
> gt?                      | gt_Q                       | T, T                   | bool            | T=comparable  | 
>= ge?                     | ge_Q                       | T, T                   | bool            | T=comparable  | 
nil?                       | nil_Q                      | T                      | bool            | T=reference   | 
<=> compare                | compare                    | T, T                   | int             | T=comparable  | 
pos?                       | pos_Q                      | T                      | bool            | N=Number      | 
neg?                       | neg_Q                      | T                      | bool            | N=Number      | 

File   basic_collection.sz
Module stdlib
Name(s)                    | Export-name                | Input                  | Output          | Generics      | Description
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
size                       | size                       | T[]                    | size_t          | T=any         | 
append                     | append                     | T[], T                 | T[]             | T=any         | 
append!                    | append_E                   | T[], T                 | T[]             | T=any         | 
append                     | append                     | T[], T[]               | T[]             | T=any         | 
append!                    | append_E                   | T[], T[]               | T[]             | T=any         | 
prepend                    | prepend                    | T, T[]                 | T[]             | T=any         | 
coll-clone                 | coll_clone                 | T[]                    | T[]             | T=any         | 
keys                       | keys                       | T[]                    | size_t[]        | T=any         | 
assoc!                     | assoc_E                    | T[], size_t, T         | T[]             | T=any         | 
assoc                      | assoc                      | T[], size_t, T         | T[]             | T=any         | 
slice                      | slice                      | T[], size_t            | T[]             | T=any         | 
slice                      | slice                      | T[], size_t, size_t    | Ŧ[]             | T=any         | 
get                        | get                        | T[], size_t            | T               | T=any         | 
cleared                    | cleared                    | T[]                    | T[]             | T=any         | 
resized                    | resized                    | T[], size_t            | T[]             | T=any         | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
vector                     | vector                     | T, T...                | T[]             | T=any         | 
entries                    | entries                    | T[]                    | T[size_t]       | T=any         | 
first                      | first                      | T[]                    | T               | T=any         | 
second                     | second                     | T[]                    | T               | T=any         | 
last                       | last                       | T[]                    | T               | T=any         | 
rest                       | rest                       | T[]                    | T[]             | T=any         | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
empty?                     | empty_Q                    | T[]                    | bool            | T=any         | 
not-empty?                 | not_empty_Q                | T[]                    | bool            | T=any         | 
key-of                     | key_of                     | T[], T                 | size_t          | T=any         | 
key-of                     | key_of                     | T[], T, size_t         | size_t          | T=any         | 
index-of                   | index_of                   | T[], T                 | size_t          | T=any         | 
starts-with?               | starts_with_Q              | T[], T                 | bool            | T=any         | 
starts-with?               | starts_with_Q              | T[], T[]               | bool            | T=any         | 
ends-with?                 | ends_with_Q                | T[], T                 | bool            | T=any         | 
ends-with?                 | ends_with_Q                | T[], T[]               | bool            | T=any         | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
reduce                     | reduce                     | Func, T[], T1          | T1              | T=any, T1=any |
reduce                     | reduce                     | Func, T[]              | T               | T=any         | 
filter                     | filter                     | Pred, T[]              | T[]             | T=any         | 
remove                     | remove                     | Pred, T[]              | T[]             | T=any         | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
any?                       | any_Q                      | Func, T[]              | bool            | T=any         | 
all?                       | all_Q                      | Func, T[]              | bool            | T=any         | 
none?                      | none_Q                     | Func, T[]              | bool            | T=any         | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
includes? in? contains?    | includes_Q                 | T[], T                 | bool            | T=any         | 
includes? in? contains?    | includes_Q                 | T[], T[]               | bool            | T=any         | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
map-into                   | map_into                   | Func, T[], T[]         | T[]             | T=any         | 
map                        | map                        | Func, T[]              | T[]             | T=any         | 
map!                       | map_E                      | Func, T[]              | T[]             | T=any         | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
join                       | join                       | T[]                    | string          | T=any         | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
uniq distinct              | uniq                       | T[]                    | T[]             | T=any         | 
uniq? is-distinct?         | uniq_Q                     | T[]                    | bool            | T=any         | 
      is-unique?           |                            |                        |                 |               | 
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
sort insertionsort         | insertionsort              | T[]                    | bool            | T=comparable  | 

File   math.sz
Module stdlib
Name(s)                    | Export-name                | Input                  | Output          | Generics      | Description
---------------------------+----------------------------+------------------------+-----------------+---------------+-------------
min                        | min                        | T[]                    | T               | T=comparable  | 
max                        | max                        | T[]                    | T               | T=comparable  | 
sum                        | sum                        | T[]                    | T               | T=Number      | 
fib                        | fib                        | ulong                  | ulong           |               | 
divisors                   | divisors                   | ulong                  | ulong[]         |               | 
sum-of-divisors            | sum_of_divisors            | ulong                  | ulong           |               | 
approx-euler               | approx-euler               | double                 | double          |               | 
limit                      | limit                      | T, T                   | T               | T=comparable  | 
limit                      | limit                      | T, T, T                | T               | T=comparable  | 
rseed                      | rseed                      | ulong                  | Random          |               | 
random                     | random                     | ulong                  | Random          |               | 
random                     | random                     | Random                 | Random          |               | 
random                     | random                     | Random, ulong          | Random          |               | 
random                     | random                     | Random, ulong, ulong   | Random          |               | 
ulong-value                | ulong_value                | Random                 | ulong           |               | 
long-value                 | long_value                 | Random                 | long            |               | 
uint-value                 | uint_value                 | Random                 | uint            |               | 
int-value                  | int_value                  | Random                 | int             |               | 
double-value               | double_value               | Random                 | double          |               | 
```