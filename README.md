# Shaza

Shaza is a statically typed lisp intended for use as an intermediate representation
for compilers. This is a hobby project and not intended for serious work.
Similarly to many modern languages, typing is implicit but static.
The type of functions and variables can be optionally specified as shown below.

## Basic commands

``(define-ns <name>)`` 
Define a new namespace.  
``(define <type>? <name> <value>)`` 
Define a variable. The type is optional.  
``(define <type>? <generics>? <name> <bindings> &<body>)`` 
Define a function. The type is optional, as are generic argument types.  
``(define-macro <name> <bindings> &<body>)`` 
Define a macro which operates on the AST (Lisp-style).  
``(define-tk-macro <name> <bindings> &<body>)`` 
Define a macro which operates on the Token-stream (C-style).  

``(ll &<body>)`` 
Allows to directly write the compiler-output without conversion. Please use sparingly. 
``(llr &<body>)`` 
Same as ``ll``, but allows implicit ``return``.  
``(lambda <type>? <bindings> &<body>)`` 
Define an anonymous function. (Type is optional)  
``(def-struct <name> <bindings>)`` 
Create a new struct type.  
``(struct <bindings>`` 
Create an anonymous struct type.  
``(bit-cast <type> <val>)`` 
Cast a value to a specific type and trusts the programmer that the type is correct.  
``(coll <coll-type> &<vals>)`` 
Create a collection of elements.  
``(import-host <path>``  
Import file or module from the host-language.  
``(import-sz <path>)`` 
Import a shaza file.  
``(rt-import-sz <path>)`` 
Import and parse a shaza file at runtime.  
``(rt-import-dll <path>)`` 
Import a dll file at runtime.  
``(call-extern <type> <ns> <name> &<args>)`` 
Call a function from a file that was import at runtime.  
``(loop <bindings> &<body>)`` 
Creates a loop which runs until it exits or encounters a call to ``recur``. 
Shaza does not support tail-recursion (yet).  
``(recur <bindings>)`` 
Makes a loop run from the beginning with new bindings.  
``(bytesize <val>)``
Returns the size of a value in bytes.  

``(alloc <byte-size>)`` 
Allocate space in the heap. Returns a reference to ::void. 
The allocated space will not be garbage-collected.  
``(free <adress>)`` 
Free a variable from the heap.  
``(pointerto <var>)`` 
Returns a pointer the given variable.  

``(quote <expr>)``  
``(pseudo-quote <expr>)``  
``(unquote <expr>)``  

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

## Boolean operations

Boolean operations are available in two forms: The "normal" version and a 
"lispy" version (with prefix ``lsp-``). The former treats #f, nil and 0 as false.
The latter treats any value that is not #f or nil as false and anything else as true. 

``and lsp-and``  
``or lsp-or``  
``xor lsp-xor``  

An important thing to note is that the lispy-version returns the last checked 
value instead of just #t or #f:  
``(or #f 7)`` => #t  
``(lsp-or #f 7)`` => 7  

## Types

At the moment Shaza offers any type that D has.

## Missing features

Near future:  
- ``lambda`` (ouch!)  
- ``loop, recur``  
- Operators with ``'``  
- ``lsp-and, lsp-or, lsp-xor``  
- Implicit return from ``if`` and loops.  
- ``def-struct, struct``  
- ``define-ns`` (This has not proven necessary yet)
- ``import-sz``  
- ``bit-cast``  
- ``bytesize, alloc, free, pointerto``  

A byte further in the future:  
- Lazy argument evaluation  
- Automatic type induction for functions  
- ``define-macro, define-tk-macro``  
- ``coll`` (This has not proven necessary yet)  
- ``quote, pseudo-quote, unquote``
  (Shaza is transpiled to D at the moment, so doing these is hard.)  
- ``call-extern`` (Shaza can call any D-function directly)  
- ``rt-import-sz``  
- ``rt-import-dll``  
- Variadic arguments  

## TODO List

- Implement lambdas
- Implement loop and recur  
- Clean up code  
- Implement tests.
- Go down the "missing features" list.  
- Clean up code  
- Implement tests.  
- Make Shaza self-hosting step-by-step.  
- Clean up code  
- Interpreter  
- Clean up code  
- Go down the "missing features" list.  
- Implement tests.  

## Example

```
; A eager map-function using a generic type T.
(define ::T[] (T) map (::"delegate T(T elem)" func ::T[] seq)
    (let (::T[] result [])
        (reduce
            (lambda (elem res) (append res (func elem)))
            result seq)))

; Check if an element is nil using the llr command.
(define ::bool (T) nil? (T elem) (llr elem " is null"))
```
