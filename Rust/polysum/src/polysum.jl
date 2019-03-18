#=module M
using SymPy
using PyCall

SymExpr = pyimport("sympy.core.expr")["Expr"]
SymAtom = pyimport("sympy.core.basic")["Atom"]

Base.getproperty(x::Sym, a::Symbol)      = a in fieldnames(Sym)      ? getfield(x, a) : PyObject(x)[a]
Base.getproperty(x::PyObject, a::Symbol) = a in fieldnames(PyObject) ? getfield(x, a) : x[a]

Base.setproperty!(x::Sym,      a::Symbol, v) = a in fieldnames(Sym)      ? setfield!(x, a, v) : PyObject(x)[a] = v
Base.setproperty!(x::PyObject, a::Symbol, v) = a in fieldnames(PyObject) ? setfield!(x, a, v) : x[a] = v

Base.getindex(x::PyObject, i) = x.__getitem__(i)
Base.getindex(x::Sym, i) = PyObject(x).__getitem__(i)
Base.getindex(x::Sym, i::Integer) = PyObject(x).__getitem__(i)

with_item_default(self, i) = "$(self)[$i]"

@pydef mutable struct InfSeq <: SymAtom
  function __init__(self, init, next, repr, with_item=with_item_default)
    self.init = init
    self.next = next
    self.repr = repr
    self.with_item = with_item
    self.values = []
  end

  function __str__(self)
    self.repr
  end

  function str_with_item(self, i)
    self.with_item(self, i)
  end

  function args.get(self)
    return ()
  end

  function func(self, args...)
    self
  end

  function __iter__(self)
    nothing
  end

  function _append(self, value)
    PyObject(self)["values"].append(value)
  end

  function __getitem__(self, i)
    if i isa Sym
      return SymIndex(self, i)
    elseif i isa Integer
      if i == 1
        return self.init
      elseif i > 1
        if length(self.values) == 0
          self._append(self.next(self.init))
        end
        for j in (length(self.values)+1):(i-1)
          self._append(self.next(self.values[j-1]))
        end
        return self.values[i-1]
      end
    end
  end
end


@pydef mutable struct SymIndex <: SymExpr
  function __init__(self, seq, sym)
    self.seq = seq
    self.sym = sym
  end

  function free_symbols.get(self)
    self.sym.free_symbols
  end

  function is_number.get(self)
    false
  end

  function __repr__(self)
    self.seq.str_with_item(self.sym)
  end

  function __str__(self)
    self.seq.str_with_item(self.sym)
  end

  function doit(self, args...)
    newsym = doit(self.sym, args...)
    subs(self, self.sym=>newsym)
  end

  function simplify(self, args...)
    self
  end

  function _subs(self, args...)
    newsym = N(subs(self.sym, args...))
    if newsym != self.sym && newsym isa Sym || newsym isa PyObject
      self.seq[newsym]
    elseif newsym isa Integer
      self.seq.__getitem__(newsym)
    else
      self
    end
  end
end


macro s(x)
  Sym(x)
end

fancy_str(x) = sprint((io,s)->show(io, MIME"text/plain"(), s), Sym(x))

const PositiveIntegers = InfSeq(Sym(1), x->x+1, "(1,2,...)")
varstr(a) = (self, i) -> fancy_str("$(a)_$i")
incvar(a) = x -> Sym("$(a)_$(parse(Int, replace(string(x), "$(a)_"=>""))+1)")
VarSeq(a) = InfSeq(
  Sym("$(a)_1"),
  incvar(a),
  "($(fancy_str("$(a)_1")), $(fancy_str("$(a)_2")), ...)",
  varstr(a)
)

const VARS = VarSeq(:a)

P(x=@s(x), n=@s(n)) = x^n

Q(x=@s(x),n=@s(n); a=VARS) = (@vars i; Sum(a[i]*x^i, (i, 1, n+1)))

po(n) = P()(:n=>n)
ps(n) = Q()(:n=>n).doit()
eq(n) = Eq(po(n), ps(n) - ps(n)(:x=>(Sym(:x)-1)))

diff_eq(n,m,ex=eq(n)) = m == 0 ? ex : diff_eq(n, m-1, diff(ex,:x))

function eqs(n)
  ex = eq(n)
  result = [ex]
  for m in 1:n
    push!(result, diff(result[end], :x))
  end
  result
end

feqs(n) = subs(eqs(n), :x=>1)


function polysum(n::Integer, var=@s(x))
  ex = Sym(0)
  S = solve(feqs(n))
  for i in 1:(n+1)
    ex += S[VARS[i]] * var ^ i
  end
  ex
end

function polysum(s::Sym, var=first(s.free_symbols))
  ex   = Sym(0)
  var  = Sym(var)
  poly = Poly(s, var)
  for ((exp,), constant) in poly.terms()
    ex += constant * polysum(exp, var)
  end
  ex
end

function polysum(ex)
  poly(Poly(ex))
end

end
=#
module M2
using SymPy

function polysum_coef(I, n::Integer)
  A = Matrix{I}(undef, n+1, n+1)
  A[1,:] = ones(I, n+1)

  for i in 2:(n+1)
    for j in 1:(i-1)
      A[i,j] = 0
    end
    for j in i:(n+1)
      A[i,j] = A[i-1, j] * (j - i + 2)
    end
  end
  A
end

function polysum_augm(I, n::Integer)
  b    = Vector{I}(undef, n+1)
  b[1] = 1
  for i in 2:n
    b[i] = b[i-1] * (n - i + 2)
  end
  b[n+1] = b[n]
  b
end

function polysum_mat(I, n::Integer)
  A = polysum_coef(I, n)
  b = polysum_augm(I, n)
  A\b
end

function polysum(n::Integer, var=Sym(:x))
  polysum(Rational{BigInt}, n, var)
end

function polysum(I, n::Integer, var=Sym(:x))
  @assert n >= 0

  vars = [var^i for i in 1:n+1]
  sum(vars .* polysum_mat(I, n))
end

function polysum(s::Sym, var=first(s.free_symbols))
  polysum(Rational{BigInt, s, var})
end

function polysum(I, s::Sym, var=first(s.free_symbols))
  ex   = Sym(0)
  var  = Sym(var)
  poly = Poly(s, var)
  for ((exp,), constant) in poly.terms()
    ex += constant * polysum(I, exp, var)
  end
  ex
end

function polysum(ex)
  poly(Poly(ex))
end

end
