# this file defines the @with_optional_first_argument macro.

using .Iterators

is_doc_macrocall(ex) = false
is_doc_macrocall(ex::Expr) =
  ex.head == :macrocall &&
  ex.args[1] == GlobalRef(Core, Symbol("@doc"))

is_function_definition(ex) = false
is_function_definition(ex::Expr) = ex.head == :function

name(x::Symbol) = Symbol[x]
name(x::Expr) = x.head == :parameters ? names(x.args) : name(x.args[1])

names(args) = collect(Iterators.flatten(name.(args)))

keywords(args, i::Nothing) = Expr(:parameters)
keywords(args, i::Int64) = args[i]

keyword_set(n::Symbol) = :($n=$n)
keyword_set(x::Expr) = x.head == :... ? x : keyword_set(name(x)[1])

positionals(args) = filter(x->x isa Symbol || x.head != :parameters, args)
keyword_args(args) = keywords(args, findfirst(x->x isa Expr && x.head == :parameters, args))

"""
```
@with_optional_first_argument name=value begin
  ...
end
```

add a optional first argument to all function definitions.
e.g.

```
@with_optional_first_argument a=1 begin
  function f(b)
    a + b
  end
end

f(2) == 3
```
"""
macro with_optional_first_argument(d, body)
  esc(
    quote
      $(
        [
          if is_function_definition(ex)
            quote
              $(with_optional_first_argument(d, ex)...)
            end

          elseif is_doc_macrocall(ex)
            def1, def2 = with_optional_first_argument(d, ex.args[end])

            quote
              $(
                Expr(
                  :macrocall,
                  ex.args[1:end-1]...,
                  def1
                )
              )
              $def2
            end

          else
            ex
          end

          for ex in body.args
        ]...
      )
    end
  )
end


function with_optional_first_argument(d, definition)
  name = definition.args[1].args[1]
  args = definition.args[1].args[2:end]
  body = definition.args[2]
  keys = keyword_args(args)
  kyvs = keyword_set.(keys.args)
  post = positionals(args)
  dvar = d.args[1]
  dval = d.args[2]
  (
   :($name($(args...)) = $name($dval, $(names(post)...); $(kyvs...))),
   :($name($keys, $dvar, $(post...)) = $body)
  )
end


