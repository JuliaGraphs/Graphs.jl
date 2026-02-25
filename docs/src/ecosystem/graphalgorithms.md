# Graph algorithms

## Defined by Graphs.jl

_Graphs.jl_ provides a number of graph algorithms, including [Cuts](@ref), [Cycles](@ref), and [Trees](@ref), among many others. The algorithms work on any graph type that conforms to the _Graphs.jl_ API.

## External algorithm packages

Several other packages implement additional graph algorithms:

- [GraphsColoring.jl](https://github.com/JuliaGraphs/GraphsColoring.jl) provides algorithms for graph coloring, _i.e._, assigning colors to vertices such that no two neighboring vertices have the same color.
- [GraphsFlows.jl](https://github.com/JuliaGraphs/GraphsFlows.jl) provides algorithms for graph flows.
- [GraphsMatching.jl](https://github.com/JuliaGraphs/GraphsMatching.jl) provides algorithms for matchings on weighted graphs.
- [GraphsOptim.jl](https://github.com/JuliaGraphs/GraphsOptim.jl) provides algorithms for graph optimization that rely on mathematical programming.

## Interfaces to other graph libraries

Several packages make established graph libraries written in other languages accessible from within Julia and the _Graphs.jl_ ecosystem:

- [IGraphs.jl](https://github.com/JuliaGraphs/IGraphs.jl) is a thin Julia wrapper around the C graphs library [igraph](https://igraph.org).
- [NautyGraphs.jl](https://github.com/JuliaGraphs/NautyGraphs.jl) provides graph structures compatible with the graph isomorphism library [_nauty_](https://pallini.di.uniroma1.it), allowing for efficient isomorphism checking and canonization, as well as computing the properties of graph automorphism groups.

## Dispatching to algorithm implementations in external packages

Apart from providing additional graph types and algorithms, many packages extend existing functions in _Graphs.jl_ with new backends. This can make it easier to use the algorithms from within _Graphs.jl_.

For example, _NautyGraphs.jl_ provides a new backend for graph isomorphism calculations:

```jldoctest
julia> using Graphs, NautyGraphs

julia> g = star_graph(5)
{5, 4} undirected simple Int64 graph

julia> Graphs.Experimental.has_isomorph(g, g, NautyAlg())
true
```

Here, dispatching via `NautyAlg()` implicitly converts `g` to a _nauty_-compatible format and uses _nauty_ for the isomorphism computation.

### Functions extended by IGraphs.jl

A list of functions extended by _IGraphs.jl_ can be obtained with

```@example
import IGraphs
IGraphs.igraphalg_methods()
```

### Functions extended by NautyGraphs.jl

A list of functions extended by _NautyGraphs.jl_ can be obtained with

```@example
import NautyGraphs
NautyGraphs.nautyalg_methods()
```