# Graphs.jl

The goal of *Graphs.jl* is to offer a performant platform for network and graph analysis in Julia. To this end, Graphs offers both (a) a set of simple, concrete graph implementations -- `SimpleGraph` (for undirected graphs) and `SimpleDiGraph` (for directed graphs), and (b) an API for the development of more sophisticated graph implementations under the `AbstractGraph` type.

As such, *Graphs.jl* is the central package of the JuliaGraphs ecosystem. Additional functionality like advanced IO and file formats, weighted graphs, property graphs, and optimization related functions can be found in the following packages:
  * [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl): extra functions for graph analysis.
  * [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl): graphs with associated meta-data.
  * [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl): weighted graphs.
  * [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl): tools for importing and exporting graph objects using common file types like edgelists, GraphML, Pajek NET, and more.
  * [GraphDataFrameBridge.jl](https://github.com/JuliaGraphs/GraphDataFrameBridge.jl): Tools for converting edgelists stored in DataFrames into graphs (`MetaGraphs`, `MetaDiGraphs`).


## Basic library examples

The *Graphs.jl* libraries includes numerous convenience functions for generating functions detailed in [Making and Modifying Graphs](@ref), such as `path_graph`, which makes a simple undirected [path graph](https://en.wikipedia.org/wiki/Path_graph) of a given length. Once created, these graphs can be easily interrogated and modified.

```julia
julia> g = path_graph(6)

# Number of vertices
julia> nv(g)

# Number of edges
julia> ne(g)

# Add an edge to make the path a loop
julia> add_edge!(g, 1, 6)
```

For an overview of basic functions for interacting with graphs, check out [Accessing Graph Properties](@ref) and [Making and Modifying Graphs](@ref). Detailed tutorials may be found in the [JuliaGraphs Tutorial Notebooks](https://github.com/JuliaGraphs/JuliaGraphsTutorials) repository.
