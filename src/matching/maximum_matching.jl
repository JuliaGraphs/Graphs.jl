include("hopcroft_karp.jl")

"""
    AbstractMaximumMatchingAlgorithm

Abstract type for maximum cardinality matching algorithms
"""
abstract type AbstractMaximumMatchingAlgorithm end

"""
    HopcroftKarpAlgorithm

The [Hopcroft-Karp algorithm](https://en.wikipedia.org/wiki/Hopcroft-Karp_algorithm)
for computing a maximum cardinality matching of a bipartite graph.
"""
struct HopcroftKarpAlgorithm <: AbstractMaximumMatchingAlgorithm end

"""
    maximum_cardinality_matching(
        graph::AbstractGraph,
        algorithm::AbstractMaximumMatchingAlgorithm,
    )::Dict{Int, Int}

Compute a maximum-cardinality matching.

The return type is a dict mapping nodes to nodes. All matched nodes are included
as keys. For example, if `i` is matched with `j`, `i => j` and `j => i` are both
included in the returned dict.

### Arguments

* `graph`: The `Graph` for which a maximum matching is computed

* `algorithm`: The algorithm to use to compute the matching. Default is
  `HopcroftKarpAlgorithm`.

### Algorithms
Currently implemented algorithms are:

* Hopcroft-Karp

### Exceptions

* `ArgumentError`: The provided graph is not bipartite but an algorithm that
  only applies to bipartite graphs, e.g. Hopcroft-Karp, was chosen

### Example
```jldoctest
julia> using Graphs

julia> g = path_graph(6)
{6, 5} undirected simple Int64 graph

julia> maximum_cardinality_matching(g)
Dict{Int64, Int64} with 6 entries:
  5 => 6
  4 => 3
  6 => 5
  2 => 1
  3 => 4
  1 => 2

```
"""
function maximum_cardinality_matching(
    graph::AbstractGraph{T};
    algorithm::AbstractMaximumMatchingAlgorithm = HopcroftKarpAlgorithm(),
)::Dict{T, T} where {T <: Integer}
    return maximum_cardinality_matching(graph, algorithm)
end

function maximum_cardinality_matching(
    graph::AbstractGraph{T},
    algorithm::HopcroftKarpAlgorithm,
)::Dict{T, T} where {T <: Integer}
    return hopcroft_karp_matching(graph)
end
