"""
    is_chordal(g)

Check whether a graph is chordal.

A graph is said to be *chordal* if every cycle of length `≥ 4` has a chord
(i.e., an edge between two vertices not adjacent in the cycle).

### Performance
This algorithm is linear in the number of vertices and edges of the graph (i.e.,
it runs in `O(nv(g) + ne(g))` time).

### Implementation Notes
`g` is chordal if and only if it admits a perfect elimination ordering—that is,
an ordering of the vertices of `g` such that for every vertex `v`, the set of
all neighbors of `v` that come later in the ordering forms a complete graph.
This is precisely the condition checked by the maximum cardinality search
algorithm [1], implemented herein.

We take heavy inspiration here from the existing Python implementation in [2].

Not implemented for directed graphs, graphs with self-loops, or graphs with
parallel edges.

### References
[1] Tarjan, Robert E. and Mihalis Yannakakis. "Simple Linear-Time Algorithms to
    Test Chordality of Graphs, Test Acyclicity of Hypergraphs, and Selectively
    Reduce Acyclic Hypergraphs." *SIAM Journal on Computing* 13, no. 3 (1984):
    566–79. https://doi.org/10.1137/0213035.
[2] NetworkX Developers. "is_chordal." NetworkX 3.5 documentation. NetworkX,
    May 29, 2025. Accessed June 2, 2025.
    https://networkx.org/documentation/stable/reference/algorithms/generated/networkx.algorithms.chordal.is_chordal.html.

### Examples
```jldoctest
julia> using Graphs

julia> is_chordal(cycle_graph(3))
true

julia> is_chordal(cycle_graph(4))
false

julia> g = SimpleGraph(4); add_edge!(g, 1, 2); add_edge!(g, 2, 3); add_edge!(g, 3, 4); add_edge!(g, 4, 1); add_edge!(g, 1, 3);

julia> is_chordal(g)
true

```
"""
function is_chordal end

@traitfn function is_chordal(g::AG::(!IsDirected)) where {AG<:AbstractGraph}
    # The `AbstractGraph` interface does not support parallel edges, so no need to check
    if has_self_loops(g)
        throw(ArgumentError("Graph must not have self-loops"))
    end

    # Every graph of order `< 4` has no cycles of length `≥ 4` and thus is trivially chordal
    if nv(g) < 4
        return true
    end

    unnumbered = Set(vertices(g))
    start_vertex = pop!(unnumbered) # The search can start from any arbitrary vertex
    numbered = Set(start_vertex)

    #= Searching by maximum cardinality ensures that in any possible perfect elimination
    ordering of `g`, `subsequent_neighbors` is precisely the set of neighbors of `v` that
    come later in the ordering. Therefore, if the subgraph induced by `subsequent_neighbors`
    in any iteration is not complete, `g` cannot be chordal. =#
    while !isempty(unnumbered)
        # `v` is the vertex in `unnumbered` with the most neighbors in `numbered`
        v = _max_cardinality_vertex(g, unnumbered, numbered)
        delete!(unnumbered, v)
        push!(numbered, v)
        subsequent_neighbors = filter(in(numbered), collect(neighbors(g, v)))

        if !_induces_clique(subsequent_neighbors, g)
            return false
        end
    end

    #= A perfect elimination ordering is an "if and only if" condition for chordality, so if
    every `subsequent_neighbors` set induced a complete subgraph, `g` must be chordal. =#
    return true
end

function _max_cardinality_vertex(
    g::AbstractGraph{T}, unnumbered::Set{T}, numbered::Set{T}
) where {T}
    return argmax(v -> count(in(numbered), neighbors(g, v)), unnumbered)
end

function _induces_clique(vertex_subset::Vector{T}, g::AbstractGraph{T}) where {T}
    for (i, u) in enumerate(vertex_subset), v in Iterators.drop(vertex_subset, i)
        if !has_edge(g, u, v)
            return false
        end
    end

    return true
end
