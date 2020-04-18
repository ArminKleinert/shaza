# shaza
Shaza is a statically typed lisp intended for use as an intermediate representation for compilers.

## Basic commands

``(define-ns <name>)`` Define a new namespace.  
``(define <name> <value>)`` Define a variable.  
``(define <name> <bindings> &<body>)`` Define a function.  
``(et-define <name> <value>)`` Define a variable (explicitly typed).  
``(et-define <name> <bindings> &<body>)`` Define a function (explicitly typed).  
``(define-macro <name> <bindings> &<body>)`` Define a macro which operates on the AST (Lisp-style).  
``(define-tk-macro <name> <bindings> &<body>)`` Define a macro which operates on the Token-stream (C-style).  
``(lambda <bindings> &<body>)`` Define an anonymous function.  
``(t-lambda <type> <bindings> &<body>)`` Define an anonymous function (explicitly typed).  
``(def-struct <name> <bindings>)`` Create a new struct type.  
``(struct <bindings>`` Create an anonymous struct type.  
``(cast <type> <val>)`` Cast a value to a specific type.  
``(convert <type> <val>)`` Converts a value to a specific type.  
``(car <list>)`` Get the car of a list or expression.  
``(cdr <list>)`` Get the cdr of a list or expression.  
``(coll <type> &<vals>)`` Create a collection of elements. Valid values for type are :map, :vector, :list and :set.  
``(import-sz <path>)`` Import a shaza file.  
``(rt-import-sz <path>)`` Import and parse a shaza file at runtime.  
``(rt-import-dll <path>)`` Import a dll file at runtime.  
``(call-extern <type> <ns> <name> &<args>)`` Call a function from a file that was import at runtime.  
``(alloc <byte-size>)`` Allocate space in the heap.  
``(free <adress>)`` Free a variable from the heap.  
``(create <struct-type>)`` Essentially allocates space for a struct.  


## Operators

Operators are available in 2 forms. One of them relies on automatic type recognition, the other lets the user specify the type:

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

Boolean operations are available in two forms: The "normal" version and a "lispy" version (with prefix ``lsp-``). The former treats #f, nil and 0 as false. The latter treats any value that is not #f or nil as false and anything else as true. 

``and lsp-and``  
``or lsp-or``  
``xor lsp-xor``  

An important thing to note is that the lispy-version returns the last checked value instead of just #t or #f:  
``(or #f 7)`` => #t  
``(lsp-or #f 7)`` => 7  

## Types

The available types are:
``Int8 Int16 Int32 Int64 Int128 BigInt`` Integer types.  
``UInt8 UInt16 UInt32 UInt64 UInt128 BigUInt`` Unsigned integer types.  
``Float16 Float32 Float64 Float128 BigFloat`` Floating point types.  
``Boolean`` Literals #t and #f.  
``String Keyword`` Text types.  
``Map List Vector Set Array Expression Sequential`` Collection types  
``Number Reference Any``  Other types. Number is the generic type for integers, unsigned ints and floats.  
