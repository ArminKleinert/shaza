## Little repository for out-of-order ideas

### Type-constraints

```
Any integer ::any:i
Any unsigned ::any:u
Any floating ::any:f
Any numeric ::any:num

Any reference ::any:ref
Any value type ::any:val
Any array ::any:arr
Any string ::any:str

Any with D-operator...
::any:d+
::any:d-
(d*, d/, d%, d&, d|, d~, d^, d&&, d||) ...

Any for which a function is defined...
::any:+ For function +
::any:map Any type for which `map` exists.

Any which is comparable to...
::any(<(othertype))
::any(>(othertype))
(<= == >= != <=>)...

Referencing same type:
::any(>($)) Comparable to self type via. >

Multiple constraints:
::any(ref:-:<=>(string)) Any type which is a reference type, which has 
                         operator `-` and is also comparable to string.

Conbining with other modifiers:
Lazy unsigned ::lazy:any(u)
Lazy reference to a variable which is comparable to integer ::lazy:ref:any(>(i))

Or maybe in meta?
; ::T is any array type.
(meta (:generics [::T=::any(arr)]
  (define ::T foo (::T a) (at a 0)))
```
