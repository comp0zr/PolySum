# This file contains the definition of the sum_coefficients function,
# used to obtain the coefficients of the terms of the resulting
# polynomials. It is also exported so that they can be used to
# construct other structures, or otherwise serve as data.

using .Threads

"""
contains the auxiliary types `Optimized` and `Simple`,
used by the `sum_coefficients` function.
"""
module SumCoeffMethods
export Optimized, Simple
"""
Abstract type parent to the types used to
signify which method will be used in the
`sum_coefficients` function.
"""
abstract type CoeffMethod end

"""
orders `sum_coefficients` to use the optmized operations
that considers the particular properties of the matrix
we must operate on.
"""
struct Optimized <: CoeffMethod end

"""
orders `sum_coefficients` to use simpler methods with
slower performance. This is here mostly to test how
useful the optimization are. The method itself,
mostly contained in the function `PolySum.simple_matrix`,
are interesting as they possibly generate more meaningful output.
"""
struct Simple <: CoeffMethod end
end

using .SumCoeffMethods


@with_optional_first_argument I::Type=Rational{BigInt} begin
  """
  `sum_coefficients(I=Rational{BigInt}, n, method=SumCoeffMethods.Optmized)`

  Given a `n`, returns the coefficients of a polynomial `Q`
  such that `Q(x) = sum(i^n for i in 1:x)`; the result is a
  vector `C` such that `C[k]` is the coefficient of the term `x^k`.

  `method` can be either `SumCoeffMethods.Simple` or `SumCoeffMethods.Optmized`.

  `I` is the type of the elements of the resulting matrix.
  """
  function sum_coefficients(n, method=Optimized)
    sum_coefficients(I, n, method)
  end

  function sum_coefficients(n::Integer, method::Type{Optimized})
    optimized_gauss_jordan!(optimized_matrix(I, n))[:,n+2]
  end

  function sum_coefficients(n::Integer, method::Type{Simple})
    A = simple_matrix(I, n)
    A[:, 1:n+1] \ A[:, n+2]
  end

  ## Optmized

  """
  `PolySum.optimized_matrix(n)`

  returns a matrix of type `I` and dimensions (n+1) x (n+2).
  that is equivalent to our purposes to the one returned by
  `PolySum.simple_matrix(n)`, but uses certain properties of the
  operations we will perform to optimize it.
  """
  function optimized_matrix(n::Integer)
    A = zeros(I, n+1, n+2) # initialize matrix

    # The properties to keep in mind for now is the following:
    # 1. Following every non-empty line is an empty one, and
    #    following every empty line is an non-empty one, with
    #    the exception of the last and its previous line, which
    #    are never empty.
    #
    # 2. The first line is empty if n is odd.
    #
    # 3. Any given element A[i,j] has three possible values:
    #    * if j < i, then it is 0.
    #    * if j = n+2, then the element is equal to n!/(n - i + 1)!
    #    * otherwise, if then it is j!/(j - i + 1)!
    #

    if iseven(n)
      # if n is even, then the first line is made up entirely of
      # ones, and the second line is empty, thus we start at
      # the third line after filling the first one.
      next_line = 3
      A[1,:] = ones(I, n+2)
    else
      # If n is odd, the first line is empty and the second line
      # has each of its columns have the same value as their
      # indice (e.g. the third column has value 3), with the
      # exception of the first column (0) and the last. (n)
      # Because the second line is not empty, the third will
      # be, so we skip to the fourth.
      next_line = 4
      @threads for i in 2:n+1
        A[2,i] = i
      end
      A[2,n+2] = n
    end

    for i in next_line:2:(n-1)
      # all the elements in A[i, 1:(i-1)] are 0
      @threads for j in i:(n+1)
        # the non-zero element A[i,j] is equal to j!/(j - i + 1)!
        # since we already calculated A[i-2, j], which is j!/(j - i + 3)!
        # we just need to multiply that value by (j - i + 2) and (j - i + 3).
        m = convert(I, (j - i + 2) * (j - i + 3))
        A[i,j] = A[i-2, j] * m
      end
      # both A[i,n+2] and A[i,n] are equal to n!/(n - j + 1)!
      A[i,n+2] = A[i, n]
    end

    # The last two lines always follow the same pattern
    A[n,n] = one(I)
    A[n,n+2] = one(I)/convert(I, 2)

    A[n+1,n+1] = one(I)
    A[n+1,n+2] = one(I)/convert(I, n+1)

    A
  end

  """
  `PolySum.optimized_gauss_jordan!(A)`

  partial gauss-jordan elimination applied on the matrix `A`,
  modifying it in-place.

  The resulting matrix will not be in the reduced row echelon
  form, however its last column will still be the same as the
  one in the matrix obtained by `gauss_jordan!(falling_matrix(n))`.
  Since that's the only part of the resulting matrix we are
  interested in, this algorithm ignores as much of the rest
  as possible.
  """
  function optimized_gauss_jordan!(A)
    # the input matrix is (n + 1) x (n + 2)
    n = size(A)[1] - 1

    # we know the pivots of the last two rows are
    # already equal to one, and there are no other
    # elements in them apart from the on in the last
    # column, so we separately subtract each row above
    # them by both of them. We only actually operate
    # on the last column, and pretend we zeroed the
    # pivots of the rows above, since we won't be
    # touching them anymore.
    #
    # also of note is that we skip every other
    # row, since we know that they are null.
    #
    @threads for i in (n-1):-2:1
      A[i, n+2] -= A[i, n+1] * A[n+1, n+2]
      A[i, n+2] -= A[i, n] * A[n, n+2]
    end

    # we repeat the above with the other rows,
    # but dividing the last value of each row
    # by its pivot, as we would in a normal
    # gauss-jordan elimination.
    #
    # the reason we made this separation was
    # because we would otherwise skip the second
    # row, which does not follow the empty-then-non-empty
    # rule.
    #
    for i in (n-1):-2:1
      A[i,n+2] /= A[i,i]

      @threads for j in (i-2):-2:1
        p = A[j,i]
        A[j,j] -= A[i,j] * p
        A[j, n+2] -= A[i, n+2] * p
      end
    end
    A
  end

  ## Simple

  """
  `PolySum.simple_matrix(I, n)`

  This function returns a matrix of type `I` and dimensions (n+1) x (n+2).
  It was proved that the last column of the reduced row echelon form of this
  matrix are the coefficients of the sum over the polynomial x^n.
  """
  function simple_matrix(n::Integer)
    A = zeros(I, n+1, n+2) # initialize matrix

    # Any given element A[i,j] has three possible values:
    #   * if j <= i, then it is 0.
    #   * if j = n+2, then the element is equal to n!/(n - i + 1)!
    #   * otherwise, if j > i, then it is j!/(j - i + 1)!
    #

    A[1,:] = ones(I, n+2)

    for i in 2:1:(n+1)
      @threads for j in i:(n+1)
        # the non-zero element A[i,j] is equal to j!/(j - i + 1)!
        # since we already calculated A[i-1, j], which is j!/(j - i + 2)!
        # we just need to multiply that value by (j - i + 2).
        A[i,j] = A[i-1, j] * (j - i + 2)
      end
      # both A[i,n+2] and A[i,n] are equal to n!/(n - j + 1)!
      A[i,n+2] = A[i, n]
    end
    # The element A[n+1, n+2] is n!/0!, which is equal to n!/1!, which is A[n,n+2]
    A[n+1,n+2] = A[n, n+2]
    A
  end
end

