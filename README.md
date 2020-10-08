# Shaza

Shaza is a statically typed lisp I am making for fun. For simplicity, it compiles straight to D.
It is influenced by Scheme, Clojure, Ruby, C, D and a little Java. Clojure and D incluenced
Shaza more than the others. The influences from Scheme and Ruby lie more in their many 
implementations.  

Very basic features are still missing, which makes writing Shaza harder than I would like it to.
It has progressed far enough that it can be made self-hosting, which is the next goal.  

Every aspect of the compiler, the library and the documentation is going through a grind of 
constant change right now. You have been warned.

## How to use

- Install D and the Dub tool (which should come with D)
- Clone the repository
- Open the command line, cd to the directory you cloned Shaza to
- Write some Shaza source code
- Put the files of the standard library into the same directory
- Run ``dub build --force && ./shaza <shaza-file> <output-directory>``
- If everything works, the compiler should have created a bunch of new `.d` files.
- Put these files into a new or existing D-project and run it.
- Get angry like me when it doesn't work.

## Basic commands

``(module <name>)`` 
Define a new module. Modules are used to bundle files and to determine the names for
the output files.  
``(define <type>? <name> <value>)`` 
Define a variable. The type is optional.  
``(define <type>? <generics>? <name> <bindings> &<body>)`` 
Define a function. The type is optional, as are generic argument types.  
``(define-macro <name> <bindings> &<body>)`` 
Define a macro which operates on the AST (Lisp-style). (Not implemented yet)  
``(define-tk-macro <name> <bindings> &<body>)`` 
Define a macro which operates on the Token-stream (C-style). (Not implemented yet)  

``(ll &<body>)`` 
Allows to directly write the compiler-output without conversion. 
Please use sparingly and with caution.  
``(llr &<body>)`` 
Same as ``ll``, but allows implicit ``return``.  
``(lambda <type>? <bindings> &<body>)`` 
Define an anonymous function. (Type is currently mandatory).  
``(fp <function>)``
Shaza does not yet have first class functions. This is a workaround. ``(fp +)`` 
creates a pointer to the global + function. This is not necessary for lambdas.  
``(def-struct <name> <generics?> <_>? <bindings>)``  
Create a new value type (struct). If the 3rd argument `_` is not there, the first
binding will be treated as an alias (an explanation will be added eventually).
``(def-union <name> <bindings>)``
Create a union type. (union)
``(def-type <name> <generics?> <_>? <bindings>)`` 
Same as `def-struct`, but generates a reference type instead. (class)    
``(struct <bindings>`` 
Create an anonymous struct type. (Not implemented yet)  
``(cast <type> <val>)`` 
Cast a value to a specific type and trusts the programmer that the type is correct.  
``(to <type> <val>)`` 
Tries to convert a variable to the specified type. To convert an int to a string, for example,
you can use `(to ::string 15)`.  
``(import-host <path>)`` 
Import file or module from the host-language.  
``(import-sz <path>)`` 
Import a shaza file. (Not implemented yet)  
``(rt-import-sz <path>)`` 
Import and parse a shaza file at runtime. (Not implemented yet)  
``(rt-import-dll <path>)`` 
Import a dll file at runtime. (Not implemented yet)  
``(loop <bindings> &<body>)`` 
Creates a loop which runs until it exits or encounters a call to ``recur``. 
Shaza does not support tail-recursion (yet).  
``(recur <bindings>)`` 
Makes a loop run from the beginning with new bindings.  
``(bytesize <val>)``
Returns the size of a value in bytes. (Not implemented yet)  

``(alloc <byte-size>)`` 
Allocate space in the heap. Returns a reference to ::void. 
The allocated space will not be garbage-collected. (Not implemented yet)  
``(free <adress>)`` 
Free a variable from the heap. (Not implemented yet)  
``(pointerto <var>)`` 
Returns a pointer the given variable. (Not implemented yet)  

``(quote <expr>)`` (Not implemented yet)  
``(pseudo-quote <expr>)`` (Not implemented yet)  
``(unquote <expr>)`` (Not implemented yet)  

## Operators

Every operator has an alias and an export-name, with which it can be used in D-code.
For example, the binary `&` operator can also be written as `bit-and` or `bit_and` but will
always be called `bit_and` in the output.
Some operators take different amounts of arguments, some are even variadic. Here is a 
little table:

```
Name(s)          | Export-name | Result   | # of arguments   | Meaning
-----------------+-------------+----------+------------------+----------------------------
+ plus           | plus        | Number   | Variadic (min 1) | 
- sub            | sub         | Number   | Variadic (min 1) | 
* mul            | mul         | Number   | variadic (min 2) | 
/ div            | div         | Number   | variadic (min 2) | 
% mod            | mod         | Number   | variadic (min 2) | 
++ inc           | inc         | Number   | 1                | Adds 1 to number (Unchanged)
-- dec           | dec         | Number   | 1                | Lower number by 1 (Unchanged)
-----------------+-------------+----------+------------------+----------------------------
& bit-and        | bit_and     | Integral | 2                | AND integral numbers
| bit-or         | bit_or      | Integral | 2                | OR integral numbers
^ bit-xor        | bit_xor     | Integral | 2                | XOR integral numbers
<< shl           | shift_left  | Integral | 2                | Shift bits of integral
>> shr           | shift_right | Integral | 2                | Shift bits of integral
~ bit-flip       | bit_negate  | Integral | 1                | Flip all bits in an integral
-----------------+-------------+----------+------------------+----------------------------
! not            | not         | bool     | 1                | Negate bool
&& and           | and         | bool     | Variadic (min 2) | AND booleans (lazy)
|| or            | or          | bool     | Variadic (min 2) | OR booleans (lazy)
^^ xor           | xor         | bool     | 2                | XOR booleans (lazy)
!&& nand         | nand        | bool     | Variadic (min 2) | NAND booleans (lazy)
!|| nor          | nor         | bool     | Variadic (min 2) | NOR booleans (lazy)
-----------------+-------------+----------+------------------+----------------------------
= == eql?        | eql_Q       | bool     | 2                | Check equality
!= not= not-eql? | not_eql_Q   | bool     | 2                | Check unequality
< lt?            | lt_Q        | bool     | 2                | A less than B?
<= le?           | le_Q        | bool     | 2                | A less than or equal to B?
> gt?            | gt_Q        | bool     | 2                | A greater than B?
>= ge?           | ge_Q        | bool     | 2                | A greater than or equal to B?
nil?             | nil_Q       | bool     | 1                | Checks for nil (does not work 
                 |             |          |                  | on value types, only references)
-----------------+-------------+----------+------------------+----------------------------
<=>              | compare     | int      | 2                | 1 if A>B, 0 if A==B, -1 if A<B
pos?             | pos_Q       | bool     | 1                | Checks if input is positive
neg?             | neg_Q       | bool     | 1                | Checks if input is negative
```

## Types

At the moment Shaza offers any type that D has.  
Types for Maps, Trees and Lazy sequences are being implemented in Shaza and are WIP.

## Meta-data

With the ``meta`` command, the user can specify a couple
of options to have less overhead if a lot of functions have the 
same return-type, use the same generics and so on. Also, they 
can specify a few additional options which are not supported 
normally in a ``define``.

Implemented:
- ``:generics [...]`` Defines a list of generic types.  
- ``:returns <symbol>`` Declares the return type for all functions in the block.  
- ``:visibility <string>`` Sets the visibility of the functions to 
one of "public", "private", "protected".  

Implemented but not tested enough:
- ``:aliases [...]`` Defines a list of aliases for the function. 
If an alias is used, the name is resolved to point back to the original. 
It is currently not tested enough to be used safely.
- ``:export-as <string>`` If set, the functions' name will be converted 
to the given string by the compiler.  
- ``:tk-aliases [...]`` Defines a list of token-strings which will be replaced 
by some other text. There is an example below. Right now, this is highly 
unsafe and should be used with extreme caution, since it will happily replace
any token if it fits the given name!
- ``:variadic #t/#f`` Makes the last argument of the functions variadic.  

Not implemented:
- ``:checked-calls #t/#f`` Makes sure the functions can only call functions 
created in Shaza, but no D-functions. `#f` is redundant.  
- ``:pure #t/#f`` Ensures the compiler that the functions are functionally pure
or not. The value `#f` is redundant.  
- ``:parameters [...]`` Sets the list of parameters for all functions in scope.
Can be overridden in the signatures.  
- ``:inline (<lambda>)`` Create an inlined version which can be used by the
compiler.  
- ``:import [...]`` Defines a list of modules that will be imported only for the
functions in that block.  
- ``:optimize #t/#f`` Tells the compiler to optimize the functions or not. 
`#t` is redundant.  
- ``:member-of <type>`` Makes the functions methods of the given type.  
- ``:lazy #t/#f`` Makes the functions work lazily or eagerly. `#f` is redundant.
- ``:memoize #t/#f`` Turns on memoization. `#f` is redundant except
if `:pure` is `#t`, in which case the compiler might otherwise try to memoize.  
- ``:doc <string>`` Sets documentation.

## Known issues

- Comments nested in `meta`-blocks, which start with a `;` and are not followed by
  a space character, make the compiler throw errors.

## Missing features

Near future:  
- Make a check for `:export-as` to verify that the name is valid.  
- Make `import-sz` safer.  
- Make compiler check all function names and meta before the actual 
  output of functions!  
- Make compiler print a lot of errors rather than quitting immediately.  
- Implement functions for Maps (or implement Maps with `def-struct`).  
- Implement functional types.  
- Lazy sequences.
- tail-recursion (right now, ``recur`` should be used).  
- Implicit return from ``if``, ``let`` and loops.  
- ``struct``  
- ``bit-cast``  
- ``bytesize, alloc, free, pointerto``  

A byte further in the future:  
- Unit-tests  
- type-specifications on generics  
- Modifiers on functions and vars (private, const, etc.)  
- Automatic type induction for functions.  
- ``define-macro, define-tk-macro``  
- ``quote, pseudo-quote, unquote``
  (Shaza is transpiled to D at the moment, so doing these is hard.)  
- ``call-extern`` (Shaza can call any D-function directly, so this 
  is not yet important)  
- ``rt-import-sz``  
- ``rt-import-dll``  
- Variadic arguments  

## TODO List

- Make `(random rand min max)` work with negative values.
- Implement and fix functions for bit-manipulations (in `math.sz`)
- Enable type induction for lambdas:  
  ``delegate (i) {...}``  
- Write documentation for `meta` and anonymous arguments.
- Make Shaza self-hosting step-by-step.  
- Implement tail-recursion and make compiler turn statements into expressions for real.  
- Test corner-cases of :alias and :export-as meta.
  (What if we use D names?)  
- Make code more efficient (there is a lot of copying
  and testing with meta-data).  
- Clean up code.  
- Go down the "missing features" list.  
- Clean up code.  
- Implement tests.  
- Clean up code.  
- Interpreter.  
- Clean up code.  
- Go down the "missing features" list.  
- Implement tests.  

## Example

```
; Import Shazas' standard library.
(import-sz stdlib)

; A eager sum-function using a generic type T.
; The D-compiler will complain if T does not support addition via +
(define ::T (::T) sum (::T[] seq)
  (reduce
    (lambda ::T (::T l0 ::T l1) (+ l0 l1))
    seq 0))

; An eager sum-function using meta attributes.
(meta (:generics [::T] :returns ::T :aliases [sum-elems])
(define sum (::T[] seq)
  (reduce
    (lambda ::T (::T l0 ::T l1) (+ l0 l1))
    seq 0))
)

; An eager sum-function using an anonymous parameter, return-type induction
; and the fp-command to point to another function. 
(define (::T) sum (::T[] $)
  (reduce (fp plus) $0 0))  

; An even more condensed version of the above. It's getting hard to read now...
; _ means that there is an unnamed argument with an unknown type. 
(define sum (_) (reduce (fp plus) $0 0))

; Check if an element is nil using the llr command.
(define ::bool (::T) nil? (T elem) (llr elem " is null"))

; Give the build-in associative-array type a name which is easier to read.
; ::V[K] is replaced by ::Map everywhere inside the meta-block.
(meta (:tk-aliases [::Map ::V[K] ] :generics [::V ::K])
  (define ::Map get-by-key (::Map m ::K k) (llr "m[k]")))
```
