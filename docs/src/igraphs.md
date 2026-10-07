# IGraphs integration (igraph C library)

`IGraphs.jl` (https://github.com/JuliaGraphs/IGraphs.jl) is the idiomatic
Julia wrapper around the C `igraph` library (see JuliaGraphs/Graphs.jl#446).

## Design pattern (proof of concept)

To avoid a hard binary dependency, `Graphs.jl` only declares:

 `Graphs.isomorphism_igraph`, and `Graphs.to_igraph`, which throw an
 informative error telling the user to install `IGraphs.jl`.

`IGraphs.jl` then provides, for example:

struct IGraphLouvain <: Graphs.IGraphAlgorithm end
Graphs.community_detection_igraph(g::AbstractGraph, ::IGraphLouvain) =
   community_detection_igraph(to_igraph(g), IGraphLouvain())

where `to_igraph(::AbstractGraph)` converts (copy or zero-copy view) a
`Graphs.jl` graph to the C `igraph_t` structure, preserving directedness,
vertex numbering (`1:n`), and edge multiplicities as documented in `IGraphs.jl`.

## Conformance

`IGraph` graph types must satisfy the full `Graphs.jl` `AbstractGraph`
interface and are validated with `GraphsInterfaceChecker.jl` in the
`IGraphs.jl` test suite:

using Graphs, GraphsInterfaceChecker, IGraphs
@test test_graph(IGraphGraph(SimpleGraph(4, 3)))

See `src/igraphs.jl` for the stub definitions and docstrings.
