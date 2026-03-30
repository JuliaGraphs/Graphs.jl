# Algorithm stubs for VNGraphs.jl integration

"""
    chromatic_number(g, timeout=0)

Return the chromatic number of the graph `g`.
Note: This is a stub provided by `Graphs.jl`. For a concrete implementation,
please use the `VNGraphs.jl` package which provides a fast C implementation
via `very_nauty`.

```julia
using VNGraphs
chromatic_number(g)
```
"""
function chromatic_number(g::AbstractGraph, args...; kwargs...)
    error(
        "chromatic_number is not implemented in Graphs.jl. " *
        "Please load VNGraphs.jl to use the very_nauty implementation.",
    )
end

"""
    edge_chromatic_number(g, timeout=0)

Return the edge chromatic number of the graph `g`.
Note: This is a stub provided by `Graphs.jl`. For a concrete implementation,
please use the `VNGraphs.jl` package which provides a fast C implementation
via `very_nauty`.

```julia
using VNGraphs
edge_chromatic_number(g)
```
"""
function edge_chromatic_number(g::AbstractGraph, args...; kwargs...)
    error(
        "edge_chromatic_number is not implemented in Graphs.jl. " *
        "Please load VNGraphs.jl to use the very_nauty implementation.",
    )
end

