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

# Examples
TODO: Add examples
"""
function is_chordal(g::AbstractGraph)
    # The `AbstractGraph` interface does not support parallel edges, so no need to check
    is_directed(g) && throw(ArgumentError("Graph must be undirected"))
    has_self_loops(g) && throw(ArgumentError("Graph must not have self-loops"))

    # Every graph of order `< 4` has no cycles of length `≥ 4` and thus is trivially chordal
    nv(g) < 4 && return true

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
        subsequent_neighbors = intersect(neighbors(g, v), numbered)

        # A complete subgraph is also called a "clique," hence the naming here
        _induces_clique(subsequent_neighbors, g) || return false
    end

    #= A perfect elimination ordering is an "if and only if" condition for chordality, so if
    every `subsequent_neighbors` set induced a complete subgraph, `g` must be chordal. =#
    return true
end

function _max_cardinality_vertex(
    g::AbstractGraph{T}, unnumbered::Set{T}, numbered::Set{T}
) where {T}
    cardinality(v::T) = count(in(numbered), neighbors(g, v))
    return argmax(cardinality, unnumbered)
end

function _induces_clique(vertex_subset::Vector{T}, g::AbstractGraph{T}) where {T}
    for (i, u) in enumerate(vertex_subset), v in Iterators.drop(vertex_subset, i)
        has_edge(g, u, v) || return false
    end

    return true
end
