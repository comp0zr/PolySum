"""
Interoperation with the rational number structure
from the GMP c library.
"""
module GmpRationals
using Base.Libc
export GmpRational, array_from_mpq_ref, allocate_mpq_ref, Cmpq_t, Cmpz_t

const MPZ_SIZE = 16
const MPQ_SIZE = 32
const Cmpq_t = Ptr{Cvoid}
const Cmpz_t = Ptr{Cvoid}

const NULL_CSTRING = Cstring(Ptr{Cvoid}())

macro gmpcall(method, args...)
  esc(:(ccall(($(QuoteNode(Symbol("__g$method"))), :libgmp), $(args...))))
end

"""
`GmpRational <: Signed`

A thin layer over a pointer to a GMP rational.
Facilitates conversions to `Rational{BigInt}`
as well as allowing getting its parts as
`BigInt`s via `Base.numerator` and `Base.denominator`.
"""
mutable struct GmpRational <: Signed
  data::Cmpq_t

  function GmpRational()
    data = malloc(MPQ_SIZE)
    @gmpcall(mpq_init, Cvoid, (Cmpq_t,), data)
    new(data)
  end

  function GmpRational(data::Cmpq_t)
    new(data)
  end
end

"""
Converts a reference to a GMP rational number
to a array of the given type, using GmpRational
as and intermediary type. Any type that can
can be converted from a GmpRational is valid.
"""
function array_from_mpq_ref(T::Type, ref::Cmpq_t, n::Integer)
  result = Vector{T}(undef, n)
  for i in 1:n
    result[i] = GmpRational(ref + MPQ_SIZE * (i - 1))
  end
  result
end

"""
Allocates a GMP rational type and returns a
pointer to it.
"""
function allocate_mpq_ref(n::Int)
  malloc(MPQ_SIZE * n)
end


function load_big_int(data::Cmpz_t)
  Base.unsafe_load(Base.unsafe_convert(Ptr{BigInt}, data), 1)
end

function Base.numerator(q::GmpRational)
  load_big_int(q.data)
end

function Base.denominator(q::GmpRational)
  load_big_int(q.data + MPZ_SIZE)
end

function Base.convert(::Type{Cmpq_t}, q::GmpRational)
  q.data
end

function Base.convert(::Type{Rational{BigInt}}, q::GmpRational)
  numerator(q) // denominator(q)
end

function Base.convert(::Type{Float64}, q::GmpRational)
  Float64(@gmpcall(mpq_get_d, Cdouble, (Cmpq_t,), q))
end

function Base.unsafe_convert(::Type{Cmpq_t}, q::GmpRational)
  q.data
end

function Base.string(q::GmpRational)
  unsafe_string(
    @gmpcall(mpq_get_str, Cstring, (Cstring, Cint, Cmpq_t), NULL_CSTRING, 10, q)
  )
end

end

