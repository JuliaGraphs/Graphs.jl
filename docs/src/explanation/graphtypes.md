# Graph types

In addition to providing `SimpleGraph` and `SimpleDiGraph` implementations, _Graphs.jl_ also serves as an interface for custom graph types (see [AbstractGraph Interface](@ref)).

Currently, several other packages implement alternative graph types:

- [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl) provides a structure for (un)directed graphs with the ability to specify weights on edges.
- [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) provides a structure for (un)directed graphs that supports user-defined properties on the graph, vertices, and edges.
- [MetaGraphsNext.jl](https://github.com/JuliaGraphs/MetaGraphsNext.jl) does the same but in a type-stable manner, and with a slightly different interface.
- [StaticGraphs.jl](https://github.com/JuliaGraphs/StaticGraphs.jl) supports very large graph structures in a space- and time-efficient manner, but as the name implies, does not allow modification of the graph once created.

## Which graph type should I use?

These are general guidelines to help you select the proper graph type.

- In general, prefer the native `SimpleGraphs`/`SimpleDiGraphs` structures in _Graphs.jl_.
- If you need edge weights and don't require large numbers of graph modifications, use _SimpleWeightedGraphs.jl_.
- If you need labeling of vertices or edges, use _MetaGraphs.jl_ or _MetaGraphsNext.jl_.
- If you work with very large graphs (billions to tens of billions of edges) and don't need mutability, use _StaticGraphs.jl_.
