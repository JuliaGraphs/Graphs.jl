# Graph algorithms

## Defined by Graphs.jl

_Graphs.jl_ provides a number of graph algorithms, including [Cuts](@ref), [Cycles](@ref), and [Trees](@ref), among many others. All algorithms work on any graph type that conforms to the _Graphs.jl_ API.

## External algorithm packages

Several other packages implement additional graph algorithms:

- [GraphsColoring.jl](https://github.com/JuliaGraphs/GraphsColoring.jl) provides algorithms for graph coloring, _i.e._, assigning colors to vertices such that no two neighboring vertices have the same color.
- [GraphsFlows.jl](https://github.com/JuliaGraphs/GraphsFlows.jl) provides algorithms for graph flows.
- [GraphsMatching.jl](https://github.com/JuliaGraphs/GraphsMatching.jl) provides algorithms for matchings on weighted graphs.
- [GraphsOptim.jl](https://github.com/JuliaGraphs/GraphsOptim.jl) provides algorithms for graph optimization that rely on mathematical programming.

## Interfaces to other graph libraries

Several packages make established graph libraries written in other languages accessible from within Julia and the Graphs.jl ecosystem:

- [IGraphs.jl](https://github.com/JuliaGraphs/IGraphs.jl) is a thin Julia wrapper around the C graphs library [igraph](https://igraph.org).
- [NautyGraphs.jl](https://github.com/JuliaGraphs/NautyGraphs.jl) provides graph structures compatible with the graph isomorphism library [_nauty_](https://pallini.di.uniroma1.it), allowing for efficient isomorphism checking and canonization, as well as computing the properties of graph automorphism groups.