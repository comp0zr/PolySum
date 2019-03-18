"""
Interoperation with the rust implementation.
Useful for benchmarking. See `PolySum.Rs`.
"""
module RustInterop
import ..PolySum: MAIN_PATH, @with_optional_first_argument
export polysum, sum_coefficients, with_coefficients
using ..GmpRationals
using SymPy
using Libdl

const SUM_COEFFICIENTS_PTR  = Ref{Ptr{Nothing}}()
const WITH_COEFFICIENTS_PTR = Ref{Ptr{Nothing}}()

const BigRational = Union{Rational{BigInt}, GmpRational}

include("symbolic.jl")

@with_optional_first_argument I::Type=Rational{BigInt} begin
  """
  wraps the polysum rust library function `polysum_sum_coefficients`,
  which does the same as `PolySum.sum_coefficients`.
  """
  function sum_coefficients(n)
    ref = allocate_mpq_ref(n+1)
    ccall(SUM_COEFFICIENTS_PTR[], Cvoid, (Csize_t, Cmpq_t), n, ref)
    array_from_mpq_ref(I, ref, n+1)
  end
end

"""
wraps the polysum rust library function `polysum_with_coefficients`,
which applies a callback to the sum coefficients obtained from `n`
(see `PolySum.sum_coefficients` for more details). This allows
rust to free the memory after it's used.
"""
function with_coefficients(fn, n)
  with_polynomial(fn, Rational{BigInt}, n)
end

# note that the function is the first argument here
# instead of I to facilitate the use of the `do`
# syntax.
function with_coefficients(fn, I::Type, n)
  func(n,q) = fn(array_from_mpq_ref(I, q, n+1))
  cfunc = @cfunction($func, Cvoid, (Csize_t, Cmpq_t,))
  ccall(WITH_COEFFICIENTS_PTR[], Cvoid, (Csize_t, Ptr{Cvoid}), n, cfunc)
end


# searchs for the compiled rust library libpolysum_c,
# and returns pointers for its functions.
function open_libpolysum_c()
  debug   = joinpath(MAIN_PATH, "Rust", "polysum_c", "target", "debug")
  release = joinpath(MAIN_PATH, "Rust", "polysum_c", "target", "release")
  libpolysum_c_path = find_library(["libpolysum_c"], [release, debug])

  if libpolysum_c_path != ""
    let libpolysum_c = dlopen(libpolysum_c_path)
      (dlsym(libpolysum_c, :polysum_sum_coefficients),
       dlsym(libpolysum_c, :polysum_with_coefficients))
    end
  else
    warn("Could not find the rust library libpolysum_c")
    (Ptr{Nothing}(), Ptr{Nothing}())
  end
end

function __init__()
  (s,w) = open_libpolysum_c()
  SUM_COEFFICIENTS_PTR[]  = s
  WITH_COEFFICIENTS_PTR[] = w
end

end


"""
allows access to the polysum rust library.
e.g. `Rs.sum_coefficients(3)`

It also has a `Rs.polysum` implementation
for consistency's sake. (see `PolySum.polysum`)
"""
const Rs = RustInterop
