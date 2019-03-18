# PolySum

This implements a new method to find a polynomial equivalent to the sum
of the `k`th first integers raised to the `n`th power. In other words,
let `x^n` be the input of this program, then it outputs a polynomial `Q`
in terms of `x` such that:

```julia
Q(k) = 1^n + 2^n + 3^n + ... + (k-1)^n + k^n
```

It's similar to [Schultz's method](https://www.jstor.org/stable/2320260)
where one obtains a system of equations and solves it to obtain the
coefficients of the desired polynomial. However, this method was derived
differently, and obtains an alternative matrix.

# How

Given a Matrix `A` with dimensions `(n+1) x (n+2)` where each element `A[i, j]`<sup>\*</sup> can have one of three values
  * if `j < i`, then `A[i, j]` is 0.
  * if `j == n+2`, then `A[i, j]` is `n!/(n - i + 1)!`.
  * otherwise, `A[i, j]` is `j!/(j - i + 1)!`.

And if we obtain `B`, the reduced row echelon form of `A`,
then the last column of `B` is a vector `C` of the coefficients
of the `Q`, where `C[k]` is the coefficient of term `x^k` in `Q(x)`.

The algorithm then is divided into two parts: Making `A`, then
applying Gauss-Jordan elimination on `A`, which yields the
coefficients.

\*: with index starting from 1.

# Implementations

There are currently three implementations, each with their
own set of features and limitations.

## Python

This implementation is meant to be simple and readable, close to
the algorithm and without any drastic optimizations.

## Julia

Tries to explore as many optimizations as possible while still
remaining generic. Allows precision to be sacrificed for speed with
the use of floating-point numbers instead of arbitrary precision
rationals.

## Rust

Intended to leverage static compilation and the mutability of the
arbitrary precision numbers to achieve the most performance. Less
exploratory and meant to show the algorithm in action at its peak.

# Extensions

This algorithm can be extended in two ways:

* to allow different intervals to be used:
```julia
Q(k) = i^n + (2i)^n + (3i)^n + ... + ((k-1)*i)^n + (k*i)^n
```
* to allow polynomials with two or more terms and with coefficients different from 1
  to be used as a single input, instead of having to be used separately.

Both of those things can be done outside of the algorithm, but it's worth exploring
how they would fare integrated into it.
