# IGraphs integration

_Graphs.jl_ provides an integration with the [`igraph`](https://github.com/igraph/igraph) C library via the [IGraphs.jl](https://github.com/JuliaGraphs/IGraphs.jl) package. This integration allows you to use high-performance implementations of various graph algorithms directly on `Graphs.jl` graph types, or use `IGraph` objects as first-class `AbstractGraph` types.

## Usage

To use the `igraph` integration, you must load both `Graphs.jl` and `IGraphs.jl`:

```julia
using Graphs
using IGraphs
```

When `IGraphs.jl` is loaded, specialized dispatches for several algorithms become available. You can either call them on an `IGraph` object, or pass `IGraphAlgorithm()` as an argument to existing `Graphs.jl` functions to use the `igraph` implementation.

## Interface and Traits

```@docs
Graphs.AbstractIGraph
Graphs.IGraphAlgorithm
Graphs.igraph
```

## Algorithms

The following algorithms have specialized implementations via `igraph`:

```@docs
Graphs.sir_model
Graphs.modularity_matrix
Graphs.community_leiden
Graphs.betweenness_centrality
Graphs.pagerank
Graphs.layout_kamada_kawai
Graphs.layout_fruchterman_reingold
```
