# Shaza

Shaza is a statically typed lisp intended for use as an intermediate representation
for compilers. This is a hobby project and not intended for serious work.
Similarly to many modern languages, typing is implicit but static.
The type of functions and variables can be optionally specified as shown below.

## Basic commands

``(define-ns <name>)`` 
Define a new namespace. (Not implemented yet)  
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
Define an anonymous function. (Type is optional)  
``(def-struct <name> <bindings>)`` 
Create a new struct type.  
``(struct <bindings>`` 
Create an anonymous struct type. (Not implemented yet)  
``(bit-cast <type> <val>)`` 
Cast a value to a specific type and trusts the programmer that the type is correct. 
(Not implemented yet)  
``(coll <coll-type> &<vals>)`` 
Create a collection of elements. (Not implemented yet)  
``(import-host <path>``  
Import file or module from the host-language.  
``(import-sz <path>)`` 
Import a shaza file. (Not implemented yet)  
``(rt-import-sz <path>)`` 
Import and parse a shaza file at runtime. (Not implemented yet)  
``(rt-import-dll <path>)`` (Not implemented yet)  
Import a dll file at runtime.  
``(call-extern <type> <ns> <name> &<args>)`` 
Call a function from a file that was import at runtime. (Not implemented yet)  
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

Operators are available in 2 forms. One of them relies on automatic 
type recognition, the other lets the user specify the type:

``(+ <val> <val>)``  
``(+' <type> <val> <val>)``

Equivalents are available for the other operators too:  

``+ +'`` Addition  
``- -'`` Subtraction  
``* *'`` Multiplication  
``/ /'`` Dividing  
``% %'`` Modulo  
``<< <<'`` Left bit-shift  
``>> >>'`` Right bit-shift  
``bit-and bit-and'`` Bitwise and  
``bit-or bit-or'`` Bitwise or  
``bit-xor bit-xor'`` Bitwise xor  

## Types

At the moment Shaza offers any type that D has.

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
- ``:alias [...]`` Defines a list of aliases for the function. 
If an alias is used, the name is resolved to point back to the original. 
This option can only be used if the ``meta`` block only includes a single
function. Also, it is currently not tested enough to be used safely.
- ``:export-as <string>`` If set, the functions' name will be converted 
to the given string by the compiler. Only supported for single functions.  

Not implemented:
- ``:checked-calls #t/#f`` Makes sure the functions can only call functions 
created in Shaza, but no D-functions.  
- ``:pure #t/#f`` Ensures the compiler that the functions are functionally pure
or not. The value `#f` is redundant.  
- ``:parameters [...]`` Sets the list of parameters for all functions in scope.
Can be overridden in the signatures.  
- ``:variadic #t/#f`` Makes the last argument of the functions variadic.  
- ``:inline (<lambda>)`` Create an inlined version which can be used by the
compiler.  
- ``:import [...]`` Defines a list of modules that will be imported only for the
functions in that block.  
- ``:optimize #t/#f`` Tells the compiler to optimize the functions or not. 
`#t` is redundant.  
- ``:member-of <type>`` Makes the functions methods of the given type.  
- ``:lazy #t/#f`` Makes the functions work lazily or eagerly. `#f` is redundant.

## Missing features

Near future:  
- ``alias``
- ``lambda`` with automatic type induction  
- tail-recursion (right now, ``recur`` should be used)
- Operators with ``'``  
- Implicit return from ``if``, ``let`` and loops.  
- ``struct``  
- ``define-ns`` (This has not proven necessary yet)  
- ``import-sz``  
- ``bit-cast``  
- ``bytesize, alloc, free, pointerto``  
- Lazy sequences

A byte further in the future:  
- Unit-tests  
- type-specifications on generics  
- Modifiers on functions and vars (private, const, etc.)
- Automatic type induction for functions  
- ``define-macro, define-tk-macro``  
- ``coll`` (This has not proven necessary yet)  
- ``quote, pseudo-quote, unquote``
  (Shaza is transpiled to D at the moment, so doing these is hard.)  
- ``call-extern`` (Shaza can call any D-function directly, so this is not yet important)  
- ``rt-import-sz``  
- ``rt-import-dll``  
- Variadic arguments  

## TODO List

- Replace old names with operators  
- Implement tail-recursion and make compiler turn statements into expressions  
- Test corner-cases of :alias and :export-as meta.
  (What if we use D names?)  
- Make Shaza self-hosting step-by-step.  
- Make code more efficient (there is a lot of copying
  and testing with meta-data)  
- Clean up code  
- Implement tests.  
- Go down the "missing features" list.  
- Clean up code  
- Implement tests.  
- Clean up code  
- Interpreter  
- Clean up code  
- Go down the "missing features" list.  
- Implement tests.  

## Example

```
; A eager map-function using a generic type T.
(define ::T[] (T) map (::delegate:T(T) func ::T[] seq)
    (let (::T[] result [])
        (reduce
            (lambda (elem res) (append res (func elem)))
            result seq)))

; Check if an element is nil using the llr command.
(define ::bool (T) nil? (T elem) (llr elem " is null"))
```
