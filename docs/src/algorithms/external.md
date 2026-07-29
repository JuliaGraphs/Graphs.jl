# Externally implemented algorithms

Some algorithms are part of the _Graphs.jl_ API without being part of the
_Graphs.jl_ implementation. The function and its docstring live here, so that
the name is discoverable and stable, while the methods come from an
implementation package, usually because the algorithm is a wrapper around a
library written in another language, or because it pulls in dependencies that
_Graphs.jl_ does not want.

Calling one of these functions without the implementation package loaded raises
a `MethodError` carrying a hint that names the package to install:

```julia-repl
julia> using Graphs

julia> max_weight_perfect_matching(complete_graph(4), [1, 1, 1, 1, 1, 1], nothing)
ERROR: MethodError: no method matching max_weight_perfect_matching(::SimpleGraph{Int64}, ::Vector{Int64}, ::Nothing)
The function `max_weight_perfect_matching` exists, but no method is defined for this combination of argument types.

`max_weight_perfect_matching` is declared by Graphs.jl but implemented elsewhere: install and load LEMONGraphs.jl to get a method for it.
```

## Index

```@index
Pages = ["external.md"]
```

## Full docs

```@docs
max_weight_perfect_matching
```

## Adding another externally implemented algorithm

The setup is deliberately small, so that exposing a further algorithm is a
mechanical change. In `src/external_algorithms.jl`:

1. Declare the function with a docstring and no methods. The docstring should
   describe the arguments and the return value, and carry an
   `!!! note "Implementation package required"` admonition naming the package
   that provides the methods.

   ```julia
   """
       min_mean_cycle(g, weights, alg)

   Find the directed cycle of `g` minimising the mean weight of its arcs.

   !!! note "Implementation package required"
       Graphs.jl only declares this function; it has no methods of its own.
   """
   function min_mean_cycle end
   ```

2. Register the implementation packages, which is what makes the error hint
   informative:

   ```julia
   @declare_external min_mean_cycle "LEMONGraphs.jl"
   ```

3. Export the name from `src/Graphs.jl`, under the
   `# declared here, implemented by external packages` comment.

4. Add it to the `@docs` block above. `makedocs` runs with `checkdocs=:public`,
   so an exported docstring that is not included in the manual fails the docs
   build.

The implementation package then adds a method, dispatching on its own algorithm
marker so that several backends can coexist:

```julia
# in LEMONGraphs.jl
function Graphs.min_mean_cycle(g::AbstractGraph, weights, ::LEMONAlgorithm)
    # ... convert `g` and call into LEMON ...
end
```

See
[Dispatching to algorithm implementations in external packages](@ref "Dispatching to algorithm implementations in external packages")
for the wider convention around these algorithm markers.

## Reference

```@docs
Graphs.EXTERNAL_ALGORITHMS
Graphs.@declare_external
Graphs.external_algorithm_hint
```
