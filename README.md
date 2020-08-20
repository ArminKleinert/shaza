# Shaza

Shaza is a statically typed lisp I am making for fun. Right now it just transpiles to D.
Many functionalities are still missing though. By now Shaza has everything it needs to 
be made self-hosting.  
By now, Shaza has reached a state at which I'm not totally by it anymore.  
Any D-function can be called directly. The good thing with this is that it makes converting 
D to Shaza is pretty easy. The problem is that Shaza is not a safe language right now.

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
It is currently not tested enough to be used safely.
- ``:export-as <string>`` If set, the functions' name will be converted 
to the given string by the compiler.  

Not implemented:
- ``:checked-calls #t/#f`` Makes sure the functions can only call functions 
created in Shaza, but no D-functions. `#f` is redundant.  
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
- ``:memoize #t/#f`` Turns on memoization. `#f` is redundant except
if `:pure` is `#t`, in which case the compiler might otherwise try to memoize.  
- ``:doc <string>`` Sets documentation.

## Missing features

Near future:  
- ``alias`` command  
- Make a check for `:export-as` to verify that the name is valid  
- Make compiler check all function names and meta before the actual 
  output of functions!  
- Make compiler print a lot of errors rather than quitting immediately.  
- Implement functions for Maps (or implement Maps with `def-struct`).  
- Implement functional types.  
- Lazy sequences.
- tail-recursion (right now, ``recur`` should be used).  
- Operators with ``'``.  
- Implicit return from ``if``, ``let`` and loops.  
- ``struct``  
- ``define-ns`` (This has not proven necessary yet)  
- ``bit-cast``  
- ``bytesize, alloc, free, pointerto``  

A byte further in the future:  
- Unit-tests  
- type-specifications on generics  
- Modifiers on functions and vars (private, const, etc.)
- Automatic type induction for functions.  
- ``lambda`` with automatic type induction.  
- ``define-macro, define-tk-macro``  
- ``coll`` (This has not proven necessary yet)  
- ``quote, pseudo-quote, unquote``
  (Shaza is transpiled to D at the moment, so doing these is hard.)  
- ``call-extern`` (Shaza can call any D-function directly, so this 
  is not yet important)  
- ``rt-import-sz``  
- ``rt-import-dll``  
- Variadic arguments  

## TODO List

- Check this for varargs: 
`void print(A...)(A a) { foreach(t; a) writeln(t); }`  
- Remove `op-call`.  
- Make Shaza self-hosting step-by-step.  
- Disallow 2 `module` calls in one file.  
- Implement tail-recursion and make compiler turn statements into expressions.  
- Test corner-cases of :alias and :export-as meta.
  (What if we use D names?)  
- Make code more efficient (there is a lot of copying
  and testing with meta-data).  
- Clean up code.  
- Implement tests.  
- Go down the "missing features" list.  
- Clean up code.  
- Implement tests.  
- Clean up code.  
- Interpreter.  
- Clean up code.  
- Go down the "missing features" list.  
- Implement tests.  

## Ideas

- `::* ::*0 .. ::*9` for anonymous generic types: `(define ::*1 f (::*1 a ::*1 b) (+ a b))`  
- `%0 .. %9` for anonymous arguments: `(define ::int f (::int ::int) (+ %0 %1))`

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

; A eager sum-function using meta attributes.
(meta (:generics [::T] :returns ::T :aliases ["sum-elems"])
(define sum (::T[] seq)
  (reduce
    (lambda ::T (::T l0 ::T l1) (+ l0 l1))
    seq 0))
)

; Check if an element is nil using the llr command.
(define ::bool (::T) nil? (T elem) (llr elem " is null"))
```
