module PolySum
export sum_coefficients, polysum
using  Requires

const MAIN_PATH = abspath(joinpath(@__DIR__, "..", "..", ".."))

include("macros.jl")
include("coefs.jl")
include("symbolic.jl")
include("gmp_rationals.jl")
include("rust_interop.jl")
include("python_interop.jl")

end
