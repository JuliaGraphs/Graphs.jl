# Graph construction

_Graphs.jl_ provides a number of methods for creating a graph. These include tools for building and modifying graph objects, a wide array of graph generator functions, and the ability to read and write graphs from files (using [GraphIO.jl](https://github.com/JuliaGraphs/GraphIO.jl)).

## Creating graphs

### Standard generators

_Graphs.jl_ implements numerous graph generators, including random graph generators, constructors for classic graphs, numerous small graphs with familiar topologies, and random and static graphs embedded in Euclidean space. An empty simple Graph can be constructed using `g = SimpleGraph()` and similary `g = SimpleDiGraph()` for directed graphs.
See [Generators for common graphs](@ref) for a complete list of available templates.

### Datasets

Other notorious graphs and integration with the `MatrixDepot.jl` package are available in the `Datasets` submodule of the companion package [LightGraphsExtras.jl](https://github.com/JuliaGraphs/LightGraphsExtras.jl).
Selected graphs from the [Stanford Large Network Dataset Collection](https://snap.stanford.edu/data/index.html) may be found in the [SNAPDatasets.jl](https://github.com/JuliaGraphs/SNAPDatasets.jl) package.


## Modifying graphs

Starting from a (possibly empty) graph `g`, one can modify it using the following functions:

- `add_vertex!(g)` adds one vertex to `g`
- `add_vertices!(g, n)` adds `n` vertices to `g`
- `add_edge!(g, s, d)` adds the edge `(s, d)` to `g`
- `rem_vertex!(g, v)` removes vertex `v` from `g`
- `rem_edge!(g, s, d)` removes edge `(s, d)` from `g`

If an iterator of edges `edgelist` is available, then one can directly use `SimpleGraphFromIterator(edgelist)` or `SimpleDiGraphFromIterator(edgelist)`.

In addition to these core functions, more advanced operators can be found in [Operators](@ref).
