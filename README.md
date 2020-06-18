# Shaza

Shaza is a statically typed lisp intended for use as an intermediate representation for compilers. This is a hobby project and not intended for serious work.
Similarly to many modern languages, typing is implicit but static. The type of functions and variables can be optionally specified as shown below.

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
``(cast <type> <val>)`` Cast a value to a specific type and trusts the programmer that the type is correct.  
``(convert <type> <val>)`` Converts a value to a specific type.  
``(car <list>)`` Get the car of a list or expression.  
``(cdr <list>)`` Get the cdr of a list or expression.  
``(coll <type> &<vals>)`` Create a collection of elements. Valid values for type are ::map, ::vector, ::list and ::set.  
``(import-sz <path>)`` Import a shaza file.  
``(rt-import-sz <path>)`` Import and parse a shaza file at runtime.  
``(rt-import-dll <path>)`` Import a dll file at runtime.  
``(call-extern <type> <ns> <name> &<args>)`` Call a function from a file that was import at runtime.  
``(call-sys <name> &<args>)`` Call a system-function. An example is the the unix-functions ``read`` and ``write``.__
``(loop <bindings> &<body>)`` Creates a loop which runs until it exits or encounters a call to ``recur``. Shaza does not support tail-recursion (yet).  
``(recur <bindings>)`` Makes a loop run from the beginning with new bindings.__
``(mut <type> &<val>)`` Creates a mutable variable. Valid values for type are ::map, ::vector, ::list, ::set and ::string.__
``(bytesize <val>)`` Returns the size of a value in bytes.__

``(alloc <byte-size>)`` Allocate space in the heap. Returns a reference to ::any. The allocated space will not be garbage-collected.  
``(set! <ref> <type> <val>)`` Set bytes at the given pointer to those of the given value.  
``(get! <ref> <type>)`` Get bytes at the given pointer and convert them to a specific type.  
``(free <adress>)`` Free a variable from the heap.  
``(pointerto <var>)`` Returns a pointer the given variable.__

``(quote <expr>)``  
``(pseudo-quote <expr>)``  
``(unquote <expr>)``  

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

## Other build-ins

``(create <struct-type>)`` Essentially allocates space for a struct. The space will automatically garbage-collected.  
``(str &<vals>)`` Joins a bunch of values into a string.__
``(apply <fn> <collection>)`` Applies a function (fn) to all values in the collection by spreading them. Eg. ``(apply +' [::int32 1 2])`` will return 3. Shaza will expect the function to take multiple arguments.____

``(map <fn> <coll>)``, ``(filter <fn> <coll>)``, ``(reduce <fn> <default> <coll>)``, ``(remove <fn> <coll>)`` exist as in other languages. These variants are lazy, but there are eager variants too, all with the postfix ``'`` (eg. ``(map' <fn> <coll>)``).__
``(first-by <fn> <coll>)`` returns the first value in coll for which the function returns a truthy value.__
``(all? <fn> <coll>)``, ``(any? <fn> <coll>)``, ``(non? <fn> <coll>)`` test predicates on collections. All of them return ::boolean.__

``(open <path> <options-string>)`` opens a file.__
``(close <file>)`` closes a file.__
``(print <val>)``, ``(printf <format> &<vals>)``, ``(fprintf <file> <format> &<vals>)`` print to the console or a file.__
``(read <file or path> <size>)`` reads the given number of bytes from a file.  
``(gets <file>)``, ``(gets)`` reads from a file or from the console.__

``(try <expr> <expr>)`` tries to execute a block of code which might throw errors and uses ``catch`` expressions to catch them.__
``(throw <keyword> <valr>)`` throws an error which is tagged with a keyword. The ``try``-block will use this keyword to find the right ``catch``-block to handle the error.__
``(catch <keyword> <sym> <expr>)`` catches an error and hopefully handles it.__

``(list &<vals>)``, ``(vector &<vals>)``, ``(set &<vals>)``, ``(cr-map &<vals>)`` Functions for creating collections of a specific type.__

``(get <type> <coll> <key>)``, ``(at <coll> <key>)`` tries to find an element in a collection by a given key. Works on lists, strings, vectors and maps. ``get`` also casts the element to the given type.__
``(contains? <coll> <val>)`` returns #t if the value exists in the collection.__
``(indexof <coll> <val>)`` returns the index of the value in the collection or -1 if it was not found.__

## Types

The available types are:  
``::int8 ::int16 ::int32 ::int64 ::int128 ::bigint`` Integer types.  
``::uint8 ::uint16 ::uint32 :uint64 ::uint128 ::biguint`` Unsigned integer types.  
``::float16 ::float32 ::float64 ::float128 ::bigfloat`` Floating point types.  
``::boolean`` Literals #t (true) and #f (false).  
``::string ::keyword`` Text types.  
``::map ::list ::vector ::set ::array ::expression ::sequential`` Collection types  
``::number ::reference ::function ::any`` Other types. Number is the generic type for integers, unsigned ints and floats.  
Of cause there are the user-defined types (created via ``def-struct``). Names with the ``::`` are automatically generated for them.

## Example

```
(et-define ::sequential map
  [::function f ::sequential c]
  (if (empty? c)
    c
    (loop [curr (first c)
           rest-c (rest c)
           res (convert (typeof c) (list))]
      (if (empty? rest-c)
        res
        (recur [(first rest-c)
                (rest rest-c)
                (append res (f curr))])))))
```
