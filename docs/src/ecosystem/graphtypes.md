# Graph types

## Defined by Graphs.jl

_Graphs.jl_ provides two concrete graph types: [`SimpleGraph`](@ref) is an undirected graph, and [`SimpleDiGraph`](@ref) is its directed counterpart. Both of these types can be parameterized to specify how vertices are identified (by default, `SimpleGraph` and `SimpleDiGraph` use the system default integer type, usually `Int64`).

A graph _G_ is described by a set of vertices _V_ and edges _E_: _G = {V, E}_. _V_ is an integer range `1:n`; _E_ is represented using forward (and, for directed graphs, backward) adjacency lists indexed by vertices. Edges may also be accessed via an iterator that yields `Edge` types containing `(src<:Integer, dst<:Integer)` values. Both vertices and edges may be integers of any type, and the smallest type that fits the data is recommended in order to save memory.

Graphs are created using `SimpleGraph()` or `SimpleDiGraph()`, see [Graph construction](@ref) for details.

Multiple edges between two given vertices are not allowed: an attempt to add an edge that already exists in a graph will not raise an error. This event can be detected using the return value of [`add_edge!`](@ref).

Note that graphs in which the number of vertices equals or approaches the `typemax` of the underlying graph element (_e.g._, a `SimpleGraph{UInt8}` with 127 vertices) may encounter arithmetic overflow errors in some functions, which should be reported as bugs. To be safe, please ensure that your graph is sized with some capacity to spare.

## Available in the wider ecosystem

In addition to providing `SimpleGraph` and `SimpleDiGraph` implementations, _Graphs.jl_ also serves as an interface for custom graph types (see [AbstractGraph interface](@ref)).

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
