import numpy as np
import sympy as sp

ONE   = sp.sympify(1)
ZERO  = sp.sympify(0)
DTYPE = 'object'

DEFAULT_SYM = sp.symbols('x')


def prepare_matrix(n):
    """
    returns a matrix A where each element A[i,j] has three possible values:
      if j < i, then A[i, j] = 0
      if j = n+1, then A[i, j] = n!/(n - i + 1)!
      otherwise, A[i, j] = j!(j - i + 1)!

    n is assumed to be an integer.
    """
    # initialize a matrix of zeros, then fill first line with ones
    A = np.full((n+1,n+2), ZERO, DTYPE)
    A[0] = np.full(n+2, ONE, DTYPE)
    # use each line to calculate the next one
    for i in range(1, n+1):
        # ignore all elements where j < i, since we know they are zero
        for j in range(i, n+1):
            # this simple multiplication is all we need,
            # since A[i, j] = j!/(j - i + 1)!, and since
            # we already calculated A[i-1, j] = j!/(j - i + 2)!
            A[i,j] = A[i-1,j] * (j - i + 2)
        # the last column is the same as the antepenultimate column...
        A[i,n+1] = A[i,n-1]
    # ...with the exception of A[n, n+1],
    # which repeats last element of the previous line.
    A[n,n+1] = A[n-1,n+1]
    return A

# uncommentated
def _prepare_matrix(n):
    A = np.full((n+1,n+2), ZERO, DTYPE)
    A[0] = np.full(n+2, ONE, DTYPE)
    for i in range(1, n+1):
        for j in range(i, n+1):
            A[i,j] = A[i-1,j] * (j - i + 2)
        A[i,n+1] = A[i,n-1]
    A[n,n+1] = A[n-1,n+1]
    return A


def gauss_jordan(A):
    """
    performs an in-place partial gauss-jordan elimination on A,
    assuming it is already in row echelon form, and turning it
    into its reduced row echelon form.
    """
    n = len(A) - 1
    for i in range(n, -1, -1):
        A[i,n+1] /= A[i,i]
        A[i,i] = ONE
        for j in range(i-1, -1, -1):
            p = A[j,i]
            A[j,i] = ZERO
            A[j, n+1] -= A[i, n+1] * p
    return A


def sum_coefficients(n):
    """
    obtains the coefficients C of the polynomial Q such
    that Q(x) = summation(i^n, (i, 0, x)), where C[k]
    is the coefficient of the term x^(k+1) in Q(x).

    assumes n is an integer.
    """
    A = gauss_jordan(prepare_matrix(n))
    return A[:, n+1]


def polysum_n(n, variable=DEFAULT_SYM):
    """
    returns the polynomial Q in terms of the given variable such
    that Q(x) = summation(i^n, (i,0,x)).

    assumes n is an integer, and the variable defaults to DEFAULT_SYM.
    """
    coeffs = sum_coefficients(n)
    return sum(coeffs[i-1] * variable**i for i in range(1,n+2))


def polysum_sym(P, variable=None):
    """
    returns the polynomial Q in terms of the given variable such
    that Q(x) = summation(P(i), (i, 0, x)).

    assumes P is a sympy object. If variable == None (the default),
    then the function will assume it is the single free symbol in P.
    """
    if variable == None and len(P.free_symbols) == 1:
        variable = tuple(P.free_symbols)[0]
    poly_terms = P.as_poly().as_dict().items()
    return sum(c * polysum_n(n, variable) for ((n,), c) in poly_terms)


def polysum(expr, variable=None):
    """
    returns the polynomial Q in terms of the given variable such
    that Q(x) = summation(P(i), (i, 0, x)), where P depends on
    the given expr:
        if expr is an sympy object, then it is assumed that P == expr.
        otherwise, expr is assumed to be an integer n, and P == variable^n

    If variable == None, then the function will try to infer it depending on expr.
        if expr is an sympy object, then it is assumed that the variable is the single free symbol in expr
        otherwise, the variable will be DEFAULT_SYM.
    """
    if issubclass(type(expr), sp.Basic):
        return polysum_sym(expr, variable)
    else:
        return polysum_n(expr, DEFAULT_SYM if variable == None else variable)


