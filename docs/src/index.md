# Package overview

The goal of _Graphs.jl_ is to offer a performant platform for network and graph analysis in Julia. To this end, Graphs offers both (a) a set of simple, concrete graph implementations -- `SimpleGraph` (for undirected graphs) and `SimpleDiGraph` (for directed graphs), and (b) an API for the development of more sophisticated graph implementations under the `AbstractGraph` type.

## Installation

Installation is straightforward. First, enter Pkg mode by hitting `]`, and then run the following command:

```julia-repl
pkg> add Graphs
```

## Basic use

_Graphs.jl_ includes numerous convenience functions for generating functions, such as `path_graph`, which builds a simple undirected [path graph](https://en.wikipedia.org/wiki/Path_graph) of a given length. Once created, these graphs can be easily interrogated and modified.

```julia
julia> g = path_graph(6)

# Number of vertices
julia> nv(g)

# Number of edges
julia> ne(g)

# Add an edge to make the path a loop
julia> add_edge!(g, 1, 6)
```

To see an overview of elementary functions for interacting with graphs, check out [Graph access](@ref) and [Graph construction](@ref).
Detailed tutorials may be found in the [JuliaGraphs Tutorial Notebooks](https://github.com/JuliaGraphs/JuliaGraphsTutorials) repository.

## Ecosystem

_Graphs.jl_ is the central package of the JuliaGraphs ecosystem. Additional functionality like advanced IO and file formats, weighted graphs, property graphs, and optimization-related functions can be found in the following packages:

- [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl) and [MetaGraphsNext.jl](https://github.com/JuliaGraphs/MetaGraphsNext.jl): Graphs with associated meta-data.
- [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl): Weighted graphs.
- [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl): Tools for importing and exporting graph objects using common file types like edgelists, GraphML, Pajek NET, and more.
- [GraphDataFrameBridge.jl](https://github.com/JuliaGraphs/GraphDataFrameBridge.jl): Tools for converting edgelists stored in DataFrames into MetaGraphs.
- [GraphsMatching.jl](https://github.com/JuliaGraphs/GraphsMatching.jl): Matching algorithms.
- [GraphsFlows.jl](https://github.com/JuliaGraphs/GraphsFlows.jl): Flow algorithms.
- [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl): Various extra functions for graph analysis.

## Citing

We encourage you to cite our work if you have used our libraries, tools or datasets. Starring the _Graphs.jl_ repository on GitHub is also appreciated.

The latest citation information may be found in the [CITATION.bib](https://raw.githubusercontent.com/JuliaGraphs/Graphs.jl/master/CITATION.bib) file within the repository.