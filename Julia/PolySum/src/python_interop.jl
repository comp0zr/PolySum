"""
Interoperation with the python implementation.
Useful for benchmarking. See `PolySum.Py`.
"""
module PythonInterop
import ..PolySum: MAIN_PATH
using PyCall

const PY_MODULE_REF = Ref{PyObject}()

struct PyModuleGetter end

function Base.getproperty(::PyModuleGetter, f::Symbol)
  Base.getproperty(PY_MODULE_REF[], f)
end

function load_python_module()
  let util = pyimport("importlib.util"),
      path = joinpath(MAIN_PATH, "Python", "polysum.py"),
      spec = util.spec_from_file_location("polysum", path),
      modl = util.module_from_spec(spec);
    spec.loader.exec_module(modl)
    modl
  end
end

function __init__()
  PY_MODULE_REF[] = load_python_module()
end

end


"""
allows access to the polysum python module.
e.g. `Py.polysum(3)`
"""
const Py = PythonInterop.PyModuleGetter()
