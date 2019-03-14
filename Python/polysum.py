import numpy as np
import sympy as sp
from fractions import Fraction
from collections import namedtuple


PolySumValues = namedtuple('PolySumValues', ('zero', 'one', 'dtype'))


VALUES = {
    'fraction': PolySumValues(Fraction(0,1), Fraction(1,1), 'object'),
    'float64' : PolySumValues(np.float64(0), np.float64(1), 'float64'),
    'symbolic': PolySumValues(sp.sympify(0), sp.sympify(1), 'object'),
}

DEFAULT_SYM = sp.symbols('x')
DEFAULT_VTYPE = 'symbolic'


def prepare_matrix(n: int, v):
    A = np.full((n+1,n+2), v.zero, v.dtype)
    A[0] = np.full(n+2, v.one, v.dtype)
    #
    for i in range(1, n+1):
        for j in range(i, n+1):
            A[i,j] = A[i-1,j] * (j - i + 2)
        A[i,n+1] = A[i,n-1]
    A[n,n+1] = A[n-1,n+1]
    return A


def gauss_jordan(A: np.ndarray, v):
    n = len(A) - 1
    for i in range(n, -1, -1):
        A[i,n+1] /= A[i,i]
        A[i,i] = v.one
        for j in range(i-1, -1, -1):
            p = A[j,i]
            A[j,i] = v.zero
            A[j, n+1] -= A[i, n+1] * p
    return A


def polysum_coefficients(n: int, vtype=DEFAULT_VTYPE):
    v = VALUES.get(vtype, vtype)
    A = gauss_jordan(prepare_matrix(n, v), v)
    return A[:, n+1]


def polysum_n(n: int, vtype=DEFAULT_VTYPE, x=DEFAULT_SYM):
    coeffs = polysum_coefficients(n, vtype)
    return sum(coeffs[i-1] * x**i for i in range(1,n+2))


def polysum_sym(expr, vtype=DEFAULT_VTYPE, x=None):
    if x == None and len(expr.free_symbols) == 1:
      x = tuple(expr.free_symbols)[0]
    #
    poly_terms = expr.as_poly().as_dict().items()
    return sum(c * polysum_n(n, vtype, x) for ((n,), c) in poly_terms)


def polysum(expr, vtype=DEFAULT_VTYPE, x=None):
    if type(expr) == int:
        return polysum_n(expr, vtype, DEFAULT_SYM if x == None else x)
    else:
        return polysum_sym(expr, vtype, x)


