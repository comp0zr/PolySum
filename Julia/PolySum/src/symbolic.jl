using SymPy
using PyCall

terms(x::Sym) = PyObject(x).terms()

@with_optional_first_argument I::Type=Rational{BigInt} begin
  """
  Given a polynomial `P`, returns a polynomial `Q` such
  that `Q(x) == sum(P(i) for i in 1:x)` for all integer `x`.

  If given an integer `n`, `P` is assumed to be
  `x^n`, otherwise a sympy expression is required.
  """
  function polysum(n::Integer; var::Sym=Sym(:x))
    @assert n >= 0

    vars = [var^i for i in 1:n+1]
    sum(vars .* sum_coefficients(I, n))
  end


  function polysum(s::Sym; var=first(free_symbols(s)))
    ex   = Sym(0)
    var  = Sym(var)
    poly = Poly(s, var)
    for ((exp,), constant) in terms(poly)
      ex += constant * polysum(I, exp, var=var)
    end
    ex
  end

  function polysum(ex; kwargs...)
    polysum(Sym(ex); kwargs...)
  end
end
