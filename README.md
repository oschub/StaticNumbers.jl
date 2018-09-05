# FixedNumbers.jl

[![Build Status](https://travis-ci.org/perrutquist/FixedNumbers.jl.svg?branch=master)](https://travis-ci.org/perrutquist/FixedNumbers.jl)
[![codecov.io](http://codecov.io/github/perrutquist/FixedNumbers.jl/coverage.svg?branch=master)](http://codecov.io/github/perrutquist/FixedNumbers.jl?branch=master)

This package provides `Fixed` `Number` datatypes which store their data in a
type parameter.

Data that is passed in type parameters is (usually) handled at compile-time,
rather than at run-time. In certain cases this can lead to
better performance.
For this reason, some functions accept "value type" arguments, `Val{X}()`,
where `X` is an argument that is passed at compile-time.
[manual/performance-tips.html#Types-with-values-as-parameters-1]
[manual/types.html#"Value-types"-1]
`Fixed` is an alternative to `Val` which is specifically
designed to handle numbers.

The difference between `Val` and `Fixed` is that `Fixed` types
promote and convert like their type parameters, so they can be used directly in
arithmetic operations. (For example `Fixed(1) + 1` equals `2`.)
This makes it possible to use them with functions that were not specifically
written to accept value arguments.

Under the surface, there are three `Fixed` datatypes: `FixedInteger`,
`FixedReal`, and `FixedNumber`, subtypes of `Integer`, `Real` and `Number`
respectively. The `Union` type `Fixed` can be used to refer to them all.
For brevity, all three types are displayed as `Fixed(X)`, and it is also
recommended to create them using this syntax.

By default, any operation on a `Fixed` will result in a non-`Fixed` type.
For example, `Fixed(2)+Fixed(2)` gives `4`, not `Fixed(4)`.
But Julia's type inference engine is quite powerful! If `a` and `b` are `Fixed`,
then the type of `Fixed(a+b)` will be inferred.

It is of course also possible to overload methods to return `Fixed` for `Fixed`
inputs. The `@fixednumbers` macro can be used on a small set of `Fixed` numbers
to make certain operations preserve the `Fixed` type when possible.

When creating `Fixed` numbers, it is important to consider whether the type
system will be able to work efficiently. For example, `f(Fixed(x), y)` is
likely slower than `f(x, y)` even when called repeatedly with the same `x`.
A specialized method of `f` is created for this value of `x`, and the function
call itself will be faster. But since the type system will not know the type
of `Fixed(x)` in advance, a dynamic dispatch will happen at each function call.

On the other hand, something like `f(x==0 ? Fixed(0) : x, y)` will typically be
fast. The construct `x==0 ? Fixed(0) : x` will belong to `Union{typeof(x), Fixed(0)}`,
and Julia is able to dispatch efficiently on small type unions.
A shorthand for this construct is `f(x ⩢ 0, y)`.

It is important not to make the set of `Fixed` numbers too large,
as this can lead to a lot of compilation overhead. See:
[manual/performance-tips.html#The-dangers-of-abusing-multiple-dispatch-(aka,-more-on-types-with-values-as-parameters)-1]

There is no `FixedRational` datatype, but a `FixedReal` with a
`Rational` type parameter will convert and promote like its parameter.
For example: `Fixed(1//2) + 1 === 3//2`.

`Fixed` numbers are only fast when fully specified. A `Vector{Fixed}`
is much slower than a `Vector{Int}`.
(A `Vector{FixedInteger{1}}` is fast and requires very little memory,
but on the other hand it can only store the number one.)
